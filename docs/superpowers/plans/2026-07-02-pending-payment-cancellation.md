# Pending Payment Cancellation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let an authenticated customer cancel their own pending Stripe Checkout Session from order history and release reserved stock safely.

**Architecture:** Reuse the existing Stripe expiration, payment reconciliation, ownership query, and transactional reservation release. Add one authenticated orchestration method to `CheckoutService` and one Repeater postback action to order history; do not create another cancellation endpoint or expose the stored token hash.

**Tech Stack:** ASP.NET Web Forms, C#/.NET Framework 4.8, Stripe Checkout Sessions, PostgreSQL/Npgsql, PowerShell regression checks.

---

### Task 1: Add the failing cancellation-flow check

**Files:**
- Create: `tests/PendingPaymentCancellation.Tests.ps1`
- Inspect: `customer_page/onyx_order_history.aspx`
- Inspect: `customer_page/onyx_order_history.aspx.cs`
- Inspect: `Services/CheckoutService.cs`

- [ ] **Step 1: Write the failing source-contract check**

```powershell
$root = Split-Path $PSScriptRoot -Parent
$markup = Get-Content "$root\customer_page\onyx_order_history.aspx" -Raw
$page = Get-Content "$root\customer_page\onyx_order_history.aspx.cs" -Raw
$service = Get-Content "$root\Services\CheckoutService.cs" -Raw

$requirements = [ordered]@{
    'Repeater dispatches server-side commands' = $markup -match 'OnItemCommand="rptRecentOrders_ItemCommand"'
    'Pending order has a cancel command' = $markup -match 'CommandName="CancelPayment"'
    'Cancellation requires confirmation' = $markup -match 'return confirm\('
    'Page handles cancellation postback' = $page -match 'rptRecentOrders_ItemCommand'
    'Service owns cancellation orchestration' = $service -match 'CancelPendingPayment\s*\('
    'Service verifies order ownership' = $service -match 'GetPendingOrderForCancellation\s*\(orderId, userId\)'
    'Service confirms Stripe expiration' = $service -match 'TryExpireCheckoutSessionConfirmed'
    'Service reconciles final state' = $service -match 'ReconcileForUser'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing cancellation requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Pending payment cancellation source contract passes.'
```

- [ ] **Step 2: Run the check and verify RED**

Run:

```powershell
& .\tests\PendingPaymentCancellation.Tests.ps1
```

Expected: FAIL listing the missing Repeater command, handler, and service method.

- [ ] **Step 3: Commit the failing check**

```powershell
git add tests/PendingPaymentCancellation.Tests.ps1
git commit -m "test: define pending payment cancellation flow"
```

### Task 2: Add authenticated cancellation orchestration

**Files:**
- Modify: `Services/CheckoutService.cs`
- Test: `tests/PendingPaymentCancellation.Tests.ps1`

- [ ] **Step 1: Add the service method after `GetPendingOrderForCancellation`**

```csharp
public PaymentReconciliationResult CancelPendingPayment(long orderId, long userId)
{
    if (orderId <= 0 || userId <= 0)
    {
        throw new InvalidOperationException("A valid pending order and user are required.");
    }

    Order order = _checkoutRepository.GetPendingOrderForCancellation(orderId, userId);
    if (order == null || string.IsNullOrWhiteSpace(order.StripeCheckoutSessionId))
    {
        throw new InvalidOperationException("The pending payment was not found.");
    }

    var stripe = new StripePaymentService();
    if (!stripe.TryExpireCheckoutSessionConfirmed(order.StripeCheckoutSessionId))
    {
        throw new InvalidOperationException(
            "Stripe could not confirm cancellation. Refresh the order before retrying.");
    }

    PaymentReconciliationResult result =
        new PaymentCompletionService().ReconcileForUser(order.StripeCheckoutSessionId, userId);
    if (!string.Equals(result.OrderStatus, OrderStatuses.Cancelled, StringComparison.OrdinalIgnoreCase))
    {
        throw new InvalidOperationException("The payment was not cancelled.");
    }

    return result;
}
```

The existing repository query supplies the ownership and `pending_payment` checks. `PaymentCompletionService` performs the existing transactional cancellation and reservation release.

- [ ] **Step 2: Run the source-contract check**

Run:

```powershell
& .\tests\PendingPaymentCancellation.Tests.ps1
```

Expected: still FAIL because the UI command and handler are not implemented yet; the service-related failures disappear.

- [ ] **Step 3: Compile the service change**

Run:

```powershell
dotnet msbuild ONYX_DDAC.csproj /t:CoreCompile /p:Configuration=Debug /p:VSToolsPath='C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\v17.0' /p:UseSharedCompilation=false /m:1 /nr:false /nologo /verbosity:minimal
```

Expected: exit code 0.

- [ ] **Step 4: Commit the service change**

```powershell
git add Services/CheckoutService.cs
git commit -m "feat: cancel authenticated pending payments"
```

### Task 3: Add the order-history cancel action

**Files:**
- Modify: `customer_page/onyx_order_history.aspx`
- Modify: `customer_page/onyx_order_history.aspx.cs`
- Test: `tests/PendingPaymentCancellation.Tests.ps1`

- [ ] **Step 1: Wire the Repeater command**

Change the Repeater opening tag to:

```aspx
<asp:Repeater ID="rptRecentOrders" runat="server" OnItemCommand="rptRecentOrders_ItemCommand">
```

Add this beside the existing **Continue Payment** placeholder:

```aspx
<asp:PlaceHolder runat="server" Visible='<%# IsPendingPayment(Eval("Status")) %>'>
    <asp:LinkButton
        ID="btnCancelPayment"
        runat="server"
        CssClass="onyx-profile-ghost"
        CommandName="CancelPayment"
        CommandArgument='<%# Eval("Id") %>'
        CausesValidation="false"
        OnClientClick="return confirm('Cancel this payment and release its reserved stock?');">Cancel Payment</asp:LinkButton>
</asp:PlaceHolder>
```

- [ ] **Step 2: Add the page helper and command handler**

Add to `onyx_order_history.aspx.cs`:

```csharp
protected bool IsPendingPayment(object status)
{
    return string.Equals(
        Convert.ToString(status),
        OrderStatuses.PendingPayment,
        StringComparison.Ordinal);
}

protected void rptRecentOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
{
    if (!string.Equals(e.CommandName, "CancelPayment", StringComparison.Ordinal))
    {
        return;
    }

    if (!TryGetCurrentUserId(out long userId))
    {
        Response.Redirect("~/auth_page/onyx_login.aspx?profile=true");
        return;
    }

    currentFilter = NormalizeFilter(Request.QueryString["status"]);
    string message;
    if (!long.TryParse(Convert.ToString(e.CommandArgument), out long orderId) || orderId <= 0)
    {
        message = "The pending payment could not be identified.";
    }
    else
    {
        try
        {
            new CheckoutService().CancelPendingPayment(orderId, userId);
            new CartService().RefreshCurrentUserCartFromDatabase();
            message = "Payment was cancelled and reserved stock was released.";
        }
        catch (Exception ex)
        {
            System.Diagnostics.Trace.TraceError(
                "Order-history cancellation failed for order {0}: {1}",
                orderId,
                ex);
            message = "The payment could not be cancelled safely. Refresh and try again.";
        }
    }

    BindOrders(userId);
    litOrderMessage.Text = "<p class=\"onyx-order-notice\">" +
        Server.HtmlEncode(message) + "</p>";
}
```

Add this import:

```csharp
using System.Web.UI.WebControls;
```

- [ ] **Step 3: Run the source-contract check and verify GREEN**

Run:

```powershell
& .\tests\PendingPaymentCancellation.Tests.ps1
```

Expected: `Pending payment cancellation source contract passes.`

- [ ] **Step 4: Compile the complete change**

Run:

```powershell
dotnet msbuild ONYX_DDAC.csproj /t:CoreCompile /p:Configuration=Debug /p:VSToolsPath='C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Microsoft\VisualStudio\v17.0' /p:UseSharedCompilation=false /m:1 /nr:false /nologo /verbosity:minimal
```

Expected: exit code 0.

- [ ] **Step 5: Check the touched files**

Run:

```powershell
git diff --check -- Services/CheckoutService.cs customer_page/onyx_order_history.aspx customer_page/onyx_order_history.aspx.cs tests/PendingPaymentCancellation.Tests.ps1
rg -n "^(<<<<<<<|=======|>>>>>>>)" Services/CheckoutService.cs customer_page/onyx_order_history.aspx customer_page/onyx_order_history.aspx.cs tests/PendingPaymentCancellation.Tests.ps1
```

Expected: no whitespace errors and no conflict markers.

- [ ] **Step 6: Commit the UI change**

```powershell
git add customer_page/onyx_order_history.aspx customer_page/onyx_order_history.aspx.cs tests/PendingPaymentCancellation.Tests.ps1
git commit -m "feat: cancel pending payments from order history"
```

### Task 4: Manual Stripe smoke test

**Files:**
- Verify only; no source changes expected.

- [ ] **Step 1: Start a test-mode checkout**

Create a pending order through the application and return to order history. Confirm **Continue Payment** and **Cancel Payment** are both visible.

- [ ] **Step 2: Cancel the pending payment**

Choose **Cancel Payment**, accept the confirmation prompt, and confirm the success message appears.

- [ ] **Step 3: Verify external and local state**

Confirm the Stripe Checkout Session reports `expired`, the ONYX order reports `cancelled`, and its active `stock_reservations` rows report `released`.

- [ ] **Step 4: Verify idempotent behavior**

Refresh order history. Confirm the cancel action is gone and no second stock release occurs.

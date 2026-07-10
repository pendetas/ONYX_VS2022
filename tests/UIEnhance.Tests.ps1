$root = Split-Path $PSScriptRoot -Parent
$registerPage = Get-Content "$root\auth_page\onyx_register.aspx" -Raw
$registerCode = Get-Content "$root\auth_page\onyx_register.aspx.cs" -Raw
$registerDesigner = Get-Content "$root\auth_page\onyx_register.aspx.designer.cs" -Raw
$checkoutPage = Get-Content "$root\customer_page\onyx_checkout.aspx" -Raw
$profileCode = Get-Content "$root\customer_page\onyx_profile.aspx.cs" -Raw
$masterCode = Get-Content "$root\customer_page\onyx_user.Master.cs" -Raw
$personalizationCode = Get-Content "$root\customer_page\onyx_personalization.aspx.cs" -Raw
$cartService = Get-Content "$root\Services\CartService.cs" -Raw

$requirements = [ordered]@{
    'Register page no longer renders an address textbox' =
        $registerPage -notmatch 'txtAddress' -and
        $registerPage -notmatch 'Shipping Address'
    'Register code no longer reads address input' =
        $registerCode -notmatch 'txtAddress'
    'Register designer no longer declares address control' =
        $registerDesigner -notmatch 'txtAddress'
    'Manual registration still passes a blank address value' =
        $registerCode -match 'RegisterCustomer\([\s\S]*null,\s*phoneNumber\)'
    'Checkout still collects shipping address' =
        $checkoutPage -match 'txtShippingAddress' -and
        $checkoutPage -match 'Shipping Address'
    'Profile still handles an empty address' =
        $profileCode -match 'GetValueOrFallback\(user\.Address,\s*string\.Empty\)'
    'Customer master caches completed personalization in session' =
        $masterCode -match 'PersonalizationCompletedSessionKey' -and
        $masterCode -match 'PersonalizationCompletedUserIdSessionKey'
    'Personalization save marks completion cache' =
        $personalizationCode -match 'PersonalizationCompletedSessionKey' -and
        $personalizationCode -match 'PersonalizationCompletedUserIdSessionKey'
    'Logged-in cart reads from session before loading persisted cart' =
        $cartService -match 'CartUserIdSessionKey' -and
        $cartService -match 'TryGetSessionCartUserId' -and
        $cartService -match 'return cachedCart;'
}

$failures = @($requirements.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing UI-Enhance requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'UI-Enhance source contract passes.'

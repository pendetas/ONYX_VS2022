<%@ Page Title="Invoice" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_invoice.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_invoice" %>
<%@ Import Namespace="ONYX_DDAC.Helpers" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Content/onyx-commerce.css") %>" />
</asp:Content>

<asp:Content ID="InvoiceContent" ContentPlaceHolderID="MainContent" runat="server">


    <section class="onyx-invoice-page">
        <asp:Panel ID="pnlInvoice" runat="server" Visible="false">
            <article class="onyx-invoice-paper">
                <div class="onyx-invoice-brand">ONYX.</div>
                <div class="onyx-invoice-subtitle">Official Digital Receipt</div>

                <div class="onyx-invoice-row">
                    <div>
                        <span class="onyx-invoice-label">Customer Details</span>
                        <div class="onyx-invoice-value">
                            <asp:Literal ID="litCustomerName" runat="server" />
                        </div>
                        <div class="onyx-invoice-muted">
                            <asp:Literal ID="litCustomerContact" runat="server" />
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <span class="onyx-invoice-label">Order Reference</span>
                        <div class="onyx-invoice-value">
                            <asp:Literal ID="litOrderId" runat="server" />
                        </div>
                        <div class="onyx-invoice-muted">
                            <asp:Literal ID="litOrderDate" runat="server" />
                        </div>
                    </div>
                </div>

                <div class="onyx-invoice-boxes">
                    <div class="onyx-invoice-box">
                        <span class="onyx-invoice-label">Shipping Address</span>
                        <div class="onyx-invoice-muted">
                            <asp:Literal ID="litShippingAddress" runat="server" />
                        </div>
                        <span class="onyx-invoice-label onyx-invoice-label-spaced">Delivery Method</span>
                        <div class="onyx-invoice-muted">
                            <asp:Literal ID="litDeliveryMethod" runat="server" />
                        </div>
                    </div>
                    <div class="onyx-invoice-box">
                        <span class="onyx-invoice-label">Payment Statement</span>
                        <div class="onyx-invoice-payment">
                            <span class="onyx-payment-dot"></span>
                            <asp:Literal ID="litPaymentMethod" runat="server" />
                        </div>
                    </div>
                </div>

                <table class="onyx-invoice-table">
                    <thead>
                        <tr>
                            <th>Item Description</th>
                            <th class="right">Qty</th>
                            <th class="right">Subtotal</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptInvoiceItems" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td>
                                        <%# Server.HtmlEncode(Convert.ToString(Eval("ProductName"))) %>
                                        <span class="onyx-invoice-product-sub">Unit Price <%# CurrencyHelper.FormatMyr((decimal)Eval("UnitPrice")) %></span>
                                    </td>
                                    <td class="right"><%# Eval("Quantity") %></td>
                                    <td class="right"><%# CurrencyHelper.FormatMyr((decimal)Eval("Subtotal")) %></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>

                <div class="onyx-invoice-total">
                    <span>Grand Total Paid</span>
                    <strong><asp:Literal ID="litGrandTotal" runat="server" /></strong>
                </div>

                <div class="onyx-invoice-thanks">Thank you for choosing ONYX.</div>
                <div class="onyx-invoice-signature">ONYX Experience.</div>
            </article>

            <div class="onyx-invoice-actions">
                <a class="onyx-invoice-back" href="onyx_catalog.aspx">Back to Catalog</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlInvoiceError" runat="server" Visible="false" CssClass="onyx-invoice-error">
            <h2>Invoice unavailable</h2>
            <asp:Literal ID="litInvoiceError" runat="server" />
            <div class="onyx-invoice-actions">
                <a class="onyx-invoice-back" href="onyx_catalog.aspx">Back to Catalog</a>
            </div>
        </asp:Panel>
    </section>
</asp:Content>

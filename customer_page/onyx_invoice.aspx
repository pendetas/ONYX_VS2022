<%@ Page Title="Invoice" Language="C#" MasterPageFile="~/customer_page/onyx_user.Master" AutoEventWireup="true" CodeBehind="onyx_invoice.aspx.cs" Inherits="ONYX_DDAC.customer_page.onyx_invoice" %>
<%@ Import Namespace="ONYX_DDAC.Helpers" %>

<asp:Content ID="InvoiceContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .onyx-invoice-page {
            background: #050505;
            color: #050505;
            min-height: 100vh;
            padding: 170px 24px 80px;
        }

        .onyx-invoice-paper {
            background: #fff;
            border: 1px solid #e8e8e8;
            box-shadow: 0 18px 60px rgba(0, 0, 0, 0.08);
            margin: 0 auto;
            max-width: 620px;
            padding: 42px 46px;
        }

        .onyx-invoice-brand {
            font-family: Syne, sans-serif;
            font-size: 1.45rem;
            font-weight: 800;
            letter-spacing: 0.02em;
            line-height: 1;
            text-align: center;
            text-transform: uppercase;
        }

        .onyx-invoice-subtitle {
            color: #6b7280;
            font-size: 0.62rem;
            font-weight: 800;
            letter-spacing: 0.12em;
            margin-top: 5px;
            text-align: center;
            text-transform: uppercase;
        }

        .onyx-invoice-row {
            display: grid;
            gap: 24px;
            grid-template-columns: 1fr auto;
            margin-top: 34px;
        }

        .onyx-invoice-label {
            color: #8a8a8a;
            display: block;
            font-size: 0.56rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            margin-bottom: 6px;
            text-transform: uppercase;
        }

        .onyx-invoice-value {
            font-size: 0.72rem;
            font-weight: 800;
            line-height: 1.55;
            text-transform: uppercase;
        }

        .onyx-invoice-muted {
            color: #6b7280;
            font-size: 0.68rem;
            line-height: 1.6;
            text-transform: none;
        }

        .onyx-invoice-boxes {
            display: grid;
            gap: 18px;
            grid-template-columns: 1fr 1fr;
            margin-top: 28px;
        }

        .onyx-invoice-box {
            background: #f7f7f7;
            padding: 16px;
        }

        .onyx-invoice-payment {
            align-items: center;
            display: flex;
            gap: 8px;
            font-size: 0.72rem;
            font-weight: 800;
        }

        .onyx-payment-dot {
            background: #2f6df6;
            border-radius: 2px;
            display: inline-block;
            height: 8px;
            width: 12px;
        }

        .onyx-invoice-table {
            border-collapse: collapse;
            margin-top: 30px;
            width: 100%;
        }

        .onyx-invoice-table th {
            border-bottom: 1px solid #050505;
            color: #777;
            font-size: 0.56rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            padding: 0 0 10px;
            text-align: left;
            text-transform: uppercase;
        }

        .onyx-invoice-table td {
            border-bottom: 1px solid #050505;
            font-size: 0.7rem;
            font-weight: 800;
            padding: 14px 0;
            vertical-align: top;
        }

        .onyx-invoice-table .right {
            text-align: right;
        }

        .onyx-invoice-product-sub {
            color: #777;
            display: block;
            font-size: 0.56rem;
            font-weight: 700;
            margin-top: 3px;
        }

        .onyx-invoice-total {
            align-items: baseline;
            display: flex;
            gap: 18px;
            justify-content: flex-end;
            margin-top: 26px;
        }

        .onyx-invoice-total span {
            font-size: 0.58rem;
            font-weight: 800;
            letter-spacing: 0.08em;
            text-transform: uppercase;
        }

        .onyx-invoice-total strong {
            font-size: 1.35rem;
            font-weight: 900;
        }

        .onyx-invoice-thanks {
            border-top: 1px solid #ededed;
            color: #8a8a8a;
            font-size: 0.58rem;
            font-weight: 800;
            letter-spacing: 0.1em;
            margin-top: 34px;
            padding-top: 22px;
            text-align: center;
            text-transform: uppercase;
        }

        .onyx-invoice-signature {
            font-family: Syne, sans-serif;
            font-size: 0.7rem;
            font-weight: 800;
            margin-top: 10px;
            text-align: center;
            text-transform: uppercase;
        }

        .onyx-invoice-actions {
            margin-top: 34px;
            text-align: center;
        }

        .onyx-invoice-back {
            background: #050505;
            color: #fff;
            display: inline-block;
            font-size: 0.68rem;
            font-weight: 900;
            letter-spacing: 0.08em;
            padding: 14px 28px;
            text-decoration: none;
            text-transform: uppercase;
        }

        .onyx-invoice-error {
            background: #fff;
            border: 1px solid #e5e5e5;
            margin: 0 auto;
            max-width: 560px;
            padding: 32px;
            text-align: center;
        }

        @media (max-width: 640px) {
            .onyx-invoice-paper {
                padding: 30px 22px;
            }

            .onyx-invoice-row,
            .onyx-invoice-boxes {
                grid-template-columns: 1fr;
            }
        }
    </style>

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
                        <span class="onyx-invoice-label">Delivery Method / Address</span>
                        <div class="onyx-invoice-muted">
                            <asp:Literal ID="litShippingAddress" runat="server" />
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
                                        <%# Eval("ProductName") %>
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
                <a class="onyx-invoice-back hover-trigger" href="onyx_catalog.aspx">Back to Catalog</a>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlInvoiceError" runat="server" Visible="false" CssClass="onyx-invoice-error">
            <h2>Invoice unavailable</h2>
            <asp:Literal ID="litInvoiceError" runat="server" />
            <div class="onyx-invoice-actions">
                <a class="onyx-invoice-back hover-trigger" href="onyx_catalog.aspx">Back to Catalog</a>
            </div>
        </asp:Panel>
    </section>
</asp:Content>

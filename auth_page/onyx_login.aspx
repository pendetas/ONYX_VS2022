<%@ Page Title="Login" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_login.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row justify-content-center">
        <div class="col-md-5">
            <div class="onyx-card">
                <h1 class="h3 mb-4">Login</h1>
                <asp:Panel ID="MessagePanel" runat="server" CssClass="alert alert-warning" Visible="false">
                    <asp:Literal ID="MessageLiteral" runat="server" />
                </asp:Panel>
                <div class="mb-3">
                    <asp:Label ID="EmailLabel" runat="server" AssociatedControlID="EmailTextBox" CssClass="form-label" Text="Email" />
                    <asp:TextBox ID="EmailTextBox" runat="server" CssClass="form-control onyx-input" TextMode="Email" />
                </div>
                <div class="mb-3">
                    <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="PasswordTextBox" CssClass="form-label" Text="Password" />
                    <asp:TextBox ID="PasswordTextBox" runat="server" CssClass="form-control onyx-input" TextMode="Password" />
                </div>
                <asp:Button ID="LoginButton" runat="server" CssClass="btn onyx-btn w-100" Text="Login" OnClick="LoginButton_Click" />
            </div>
        </div>
    </div>
</asp:Content>

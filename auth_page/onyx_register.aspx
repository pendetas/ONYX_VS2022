<%@ Page Title="Register" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master" AutoEventWireup="true" CodeBehind="onyx_register.aspx.cs" Inherits="ONYX_DDAC.auth_page.onyx_register" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row justify-content-center">
        <div class="col-md-7">
            <div class="onyx-card">
                <h1 class="h3 mb-4">Create Account</h1>
                <div class="row g-3">
                    <div class="col-md-6"><asp:TextBox ID="FullnameTextBox" runat="server" CssClass="form-control onyx-input" placeholder="Full name" /></div>
                    <div class="col-md-6"><asp:TextBox ID="UsernameTextBox" runat="server" CssClass="form-control onyx-input" placeholder="Username" /></div>
                    <div class="col-md-6"><asp:TextBox ID="EmailTextBox" runat="server" CssClass="form-control onyx-input" TextMode="Email" placeholder="Email" /></div>
                    <div class="col-md-6"><asp:TextBox ID="PhoneTextBox" runat="server" CssClass="form-control onyx-input" placeholder="Phone number" /></div>
                    <div class="col-md-6"><asp:TextBox ID="DobTextBox" runat="server" CssClass="form-control onyx-input" TextMode="Date" /></div>
                    <div class="col-md-6"><asp:TextBox ID="PasswordTextBox" runat="server" CssClass="form-control onyx-input" TextMode="Password" placeholder="Password" /></div>
                    <div class="col-12"><asp:TextBox ID="AddressTextBox" runat="server" CssClass="form-control onyx-input" TextMode="MultiLine" Rows="3" placeholder="Address" /></div>
                    <div class="col-12"><asp:Button ID="RegisterButton" runat="server" CssClass="btn onyx-btn" Text="Register" /></div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

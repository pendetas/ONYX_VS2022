<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_dashboard.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h1 class="h3 mb-4">Dashboard</h1>
    <div class="row g-4">
        <div class="col-md-3"><div class="admin-panel"><div class="admin-metric">RM 0.00</div><div>Total Revenue</div></div></div>
        <div class="col-md-3"><div class="admin-panel"><div class="admin-metric">0</div><div>Total Orders</div></div></div>
        <div class="col-md-3"><div class="admin-panel"><div class="admin-metric">0</div><div>Total Users</div></div></div>
        <div class="col-md-3"><div class="admin-panel"><div class="admin-metric">0</div><div>Low Stock</div></div></div>
    </div>
</asp:Content>

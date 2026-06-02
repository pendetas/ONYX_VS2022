<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin_page/admin.Master" AutoEventWireup="true" CodeBehind="onyx_admin_dashboard.aspx.cs" Inherits="ONYX_DDAC.admin_page.onyx_admin_dashboard" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .user-profile {
            display: flex;
            align-items: center;
            gap: 15px;
            background: var(--card-dark);
            padding: 8px 16px;
            border-radius: 30px;
        }

        .user-avatar {
            width: 35px;
            height: 35px;
            border-radius: 50%;
            background-color: var(--accent-green);
            display: flex;
            align-items: center;
            justify-content: center;
            color: #000;
            font-weight: 700;
        }

        /* 4-Column Grid for Pastel Cards */
        .metric-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 30px;
        }

        .pastel-card {
            border-radius: 24px;
            padding: 25px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            color: #111; /* Dark text for pastel contrast */
            gap: 10px;
            height: 150px;
        }

        .pastel-card i {
            margin-bottom: 5px;
            opacity: 0.8;
        }

        .card-label {
            font-size: 13px;
            font-weight: 500;
            opacity: 0.7;
        }

        .card-value {
            font-size: 28px;
            font-weight: 700;
        }

        /* Specific Pastel Colors */
        .bg-yellow { background-color: var(--pastel-yellow); }
        .bg-purple { background-color: var(--pastel-purple); }
        .bg-pink { background-color: var(--pastel-pink); }
        .bg-blue { background-color: var(--pastel-blue); }

        /* Secondary Grid for Dark Cards */
        .secondary-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 20px;
        }

        .dark-card {
            background-color: var(--card-dark);
            border-radius: 24px;
            padding: 25px;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .dark-card i {
            color: var(--text-muted);
            margin-bottom: 15px;
        }
        
        .dark-label {
            font-size: 13px;
            color: var(--text-muted);
            margin-bottom: 8px;
        }

        .dark-value {
            font-size: 20px;
            font-weight: 600;
        }
        
        .trend-up {
            color: var(--accent-green);
            font-size: 12px;
            margin-top: 10px;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        
        .trend-down {
            color: #ff4444;
            font-size: 12px;
            margin-top: 10px;
            display: flex;
            align-items: center;
            gap: 4px;
        }
    </style>

    <div class="top-bar">
        <div style="display: flex; align-items: center; gap: 8px; color: var(--text-muted); font-size: 14px;">
            <i data-lucide="map-pin" style="width: 16px;"></i> Kuala Lumpur, Malaysia
        </div>
        
        <div class="user-profile">
            <i data-lucide="bell" style="width: 18px; color: var(--text-muted);"></i>
            <div class="user-avatar">AD</div>
        </div>
    </div>

    <!-- Top Pastel Metric Cards -->
    <div class="metric-grid">
        <div class="pastel-card bg-yellow">
            <i data-lucide="dollar-sign"></i>
            <div class="card-label">Total Revenue</div>
            <div class="card-value">RM 0.00</div>
        </div>
        
        <div class="pastel-card bg-purple">
            <i data-lucide="shopping-bag"></i>
            <div class="card-label">Total Orders</div>
            <div class="card-value">0</div>
        </div>

        <div class="pastel-card bg-pink">
            <i data-lucide="users"></i>
            <div class="card-label">Total Users</div>
            <div class="card-value">0</div>
        </div>

        <div class="pastel-card bg-blue">
            <i data-lucide="alert-circle"></i>
            <div class="card-label">Low Stock Items</div>
            <div class="card-value">0</div>
        </div>
    </div>

    <!-- Bottom Secondary Dark Cards -->
    <div class="secondary-grid">
        <div class="dark-card">
            <i data-lucide="trending-up"></i>
            <div class="dark-label">Conversion Rate</div>
            <div class="dark-value">3.4%</div>
            <div class="trend-up"><i data-lucide="chevron-up" style="width:14px; margin:0; color:inherit;"></i> 1.2%</div>
        </div>
        
        <div class="dark-card">
            <i data-lucide="clock"></i>
            <div class="dark-label">Avg. Dispatch Time</div>
            <div class="dark-value">24h 15m</div>
            <div class="trend-down"><i data-lucide="chevron-down" style="width:14px; margin:0; color:inherit;"></i> 5m</div>
        </div>

        <div class="dark-card">
            <i data-lucide="activity"></i>
            <div class="dark-label">Active Sessions</div>
            <div class="dark-value">1,345</div>
            <div class="trend-up"><i data-lucide="chevron-up" style="width:14px; margin:0; color:inherit;"></i> 12%</div>
        </div>
    </div>
</asp:Content>
<%@ Page Title="Promotions" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_promos.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_promos" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background-color: #0d0d0d !important; }

        .admin-panel {
            background: #1a1a1a;
            border: 1px solid #2b2b2b;
            border-radius: 0;
        }

        .page-title   { font-size: 22px; font-weight: 700; color: #ffffff; margin-bottom: 0; }
        .page-subtitle { font-size: 13px; color: #9c9ca4; margin-top: 4px; }

        /* ── ADD PROMO BUTTON ────────────────────────────────────── */
        .btn-onyx {
            background: #00ff87;
            color: #000000;
            border: none;
            border-radius: 0;
            font-weight: 700;
            font-size: 13px;
            padding: 10px 22px;
            font-family: 'Inter', sans-serif;
            display: inline-flex;
            align-items: center;
            gap: 7px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .btn-onyx:hover { background: #00e077; color: #000; }

        /* ── STAT STRIP ──────────────────────────────────────────── */
        .stat-strip {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 1px;
            background: #2b2b2b;
            border: 1px solid #2b2b2b;
            margin-bottom: 20px;
        }

        .stat-box {
            background: #1a1a1a;
            padding: 18px 22px;
            text-align: center;
        }

        .stat-value { font-size: 22px; font-weight: 700; color: #ffffff; }
        .stat-label { font-size: 12px; color: #9c9ca4; margin-top: 4px; }

        /* ── PROMOS TABLE ────────────────────────────────────────── */
        .promos-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 14px;
        }

        .promos-table thead th {
            background: #141414;
            color: #9c9ca4;
            font-size: 11px;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.6px;
            padding: 13px 20px;
            border-bottom: 1px solid #2b2b2b;
            white-space: nowrap;
        }

        .promos-table tbody td {
            padding: 15px 20px;
            border-bottom: 1px solid #202020;
            color: #ffffff;
            vertical-align: middle;
        }

        .promos-table tbody tr:last-child td { border-bottom: none; }
        .promos-table tbody tr:hover td      { background: rgba(255,255,255,0.02); }

        /* Promo code chip */
        .promo-code {
            font-family: 'Courier New', monospace;
            font-size: 13px;
            font-weight: 700;
            color: #00ff87;
            background: rgba(0, 255, 135, 0.07);
            padding: 4px 10px;
            border: 1px solid rgba(0, 255, 135, 0.2);
            letter-spacing: 1px;
        }

        /* Discount chip */
        .discount-chip {
            display: inline-block;
            background: rgba(167, 139, 250, 0.10);
            color: #a78bfa;
            font-size: 12px;
            font-weight: 600;
            padding: 3px 10px;
        }

        /* Status badges */
        .status-badge {
            display: inline-block;
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.3px;
        }

        .status-active  { background: rgba(0,   255, 135, 0.12); color: #00ff87; }
        .status-expired { background: rgba(255, 68,  68,  0.12); color: #ff4444; }
        .status-paused  { background: rgba(251, 191, 36,  0.12); color: #fbbf24; }

        /* Expiry cell colours */
        .expiry-warning { color: #fbbf24; font-size: 13px; }
        .expiry-normal  { color: #9c9ca4; font-size: 13px; }
        .expiry-expired { color: #ff4444; font-size: 13px; }

        /* Action icon buttons */
        .btn-icon {
            background: transparent;
            border: 1px solid #2b2b2b;
            color: #9c9ca4;
            padding: 5px 9px;
            border-radius: 0;
            cursor: pointer;
            transition: all 0.2s;
            font-family: 'Inter', sans-serif;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
        }

        .btn-icon:hover              { border-color: #00ff87; color: #00ff87; }
        .btn-icon.btn-delete:hover   { border-color: #ff4444; color: #ff4444; }

        /* Usage bar */
        .usage-bar {
            height: 4px;
            background: #2b2b2b;
            margin-top: 6px;
            border-radius: 2px;
            overflow: hidden;
        }

        .usage-fill {
            height: 100%;
            background: #00ff87;
            border-radius: 2px;
        }

        /* ── ADD PROMO MODAL ─────────────────────────────────────── */
        .modal-overlay {
            display: none;
            position: fixed;
            inset: 0;
            background: rgba(0, 0, 0, 0.72);
            z-index: 9000;
            align-items: center;
            justify-content: center;
        }

        .modal-overlay.open { display: flex; }

        .modal-panel {
            background: #1a1a1a;
            border: 1px solid #2b2b2b;
            padding: 30px 32px;
            width: 480px;
            max-width: 95vw;
        }

        .modal-title { font-size: 17px; font-weight: 700; color: #ffffff; margin-bottom: 22px; }

        .modal-label {
            font-size: 13px;
            color: #9c9ca4;
            margin-bottom: 6px;
            display: block;
            font-weight: 500;
        }

        .modal-input,
        .modal-select {
            width: 100%;
            background: #0d0d0d;
            border: 1px solid #2b2b2b;
            border-radius: 0;
            color: #ffffff;
            padding: 9px 12px;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            box-sizing: border-box;
            margin-bottom: 16px;
        }

        .modal-input:focus, .modal-select:focus { outline: none; border-color: #00ff87; }
        .modal-input::placeholder { color: #484848; }
        .modal-select option { background: #1a1a1a; }

        .btn-cancel-modal {
            background: transparent;
            border: 1px solid #2b2b2b;
            color: #9c9ca4;
            padding: 10px 20px;
            border-radius: 0;
            cursor: pointer;
            font-family: 'Inter', sans-serif;
            font-size: 13px;
            transition: all 0.2s;
        }

        .btn-cancel-modal:hover { border-color: #555; color: #fff; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ======================================================
         PAGE HEADER
    ====================================================== --%>
    <div class="d-flex justify-content-between align-items-start mb-4">
        <div>
            <h1 class="page-title">Promotions &amp; Coupons</h1>
            <p class="page-subtitle">Create and manage discount codes for your customers.</p>
        </div>
        <button class="btn-onyx" onclick="openModal()">
            <i data-lucide="plus" style="width:15px;height:15px;"></i> Add Promo
        </button>
    </div>

    <%-- ======================================================
         STAT STRIP
    ====================================================== --%>
    <div class="stat-strip mb-4">
        <div class="stat-box">
            <div class="stat-value" style="color:#00ff87;">
                <asp:Literal ID="litActiveCount" runat="server" Text="0" />
            </div>
            <div class="stat-label">Active Codes</div>
        </div>
        <div class="stat-box">
            <div class="stat-value">
                <asp:Literal ID="litTotalUses" runat="server" Text="0" />
            </div>
            <div class="stat-label">Total Redemptions</div>
        </div>
        <div class="stat-box">
            <div class="stat-value" style="color:#a78bfa;">
                <asp:Literal ID="litSavingsGiven" runat="server" Text="RM 0" />
            </div>
            <div class="stat-label">Total Savings Given</div>
        </div>
    </div>

    <%-- ======================================================
         PROMOS TABLE
    ====================================================== --%>
    <div class="admin-panel">
        <table class="promos-table">
            <thead>
                <tr>
                    <th>Promo Code</th>
                    <th>Discount</th>
                    <th>Type</th>
                    <th>Usage / Limit</th>
                    <th>Expiry Date</th>
                    <th>Status</th>
                    <th></th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="PromosRepeater" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td><span class="promo-code"><%# Eval("Code") %></span></td>
                            <td><span class="discount-chip"><%# Eval("Discount") %></span></td>
                            <td style="color:#9c9ca4; font-size:13px;"><%# Eval("Type") %></td>
                            <td>
                                <div style="font-size:13px;">
                                    <strong><%# Eval("Uses") %></strong>
                                    <span style="color:#555;"> / <%# Eval("Limit") %></span>
                                </div>
                                <div class="usage-bar">
                                    <div class="usage-fill" style="width:<%# Eval("UsagePct") %>%;"></div>
                                </div>
                            </td>
                            <td><span class="<%# Eval("ExpiryClass") %>"><%# Eval("Expiry") %></span></td>
                            <td>
                                <span class="status-badge status-<%# Eval("StatusKey") %>">
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td>
                                <div style="display:flex; gap:6px;">
                                    <a href="#" class="btn-icon" title="Edit promo">
                                        <i data-lucide="edit-2" style="width:13px;height:13px;"></i>
                                    </a>
                                    <a href="#" class="btn-icon btn-delete" title="Delete promo">
                                        <i data-lucide="trash-2" style="width:13px;height:13px;"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>

    <%-- ======================================================
         ADD PROMO MODAL
    ====================================================== --%>
    <div id="addPromoModal" class="modal-overlay" onclick="handleOverlayClick(event)">
        <div class="modal-panel" onclick="event.stopPropagation()">
            <div class="d-flex justify-content-between align-items-center mb-1">
                <div class="modal-title">New Promo Code</div>
                <button onclick="closeModal()"
                        style="background:none;border:none;color:#9c9ca4;cursor:pointer;font-size:22px;line-height:1;">&times;</button>
            </div>
            <p style="font-size:13px;color:#9c9ca4;margin-bottom:20px;">
                Create a new discount code for your customers.
            </p>

            <label class="modal-label">Promo Code <span style="color:#ff4444;">*</span></label>
            <input type="text" class="modal-input" id="newPromoCode"
                   placeholder="e.g. SUMMER30" style="text-transform:uppercase;">

            <label class="modal-label">Discount Type</label>
            <select class="modal-select" id="newPromoType">
                <option value="percentage">Percentage (%)</option>
                <option value="fixed">Fixed Amount (RM)</option>
                <option value="shipping">Free Shipping</option>
            </select>

            <label class="modal-label">Discount Value <span style="color:#ff4444;">*</span></label>
            <input type="text" class="modal-input" id="newPromoValue"
                   placeholder="e.g. 20 (for 20%) or 50 (for RM50)">

            <label class="modal-label">Expiry Date <span style="color:#ff4444;">*</span></label>
            <input type="date" class="modal-input" id="newPromoExpiry">

            <label class="modal-label">Usage Limit</label>
            <input type="number" class="modal-input" id="newPromoLimit"
                   placeholder="Leave blank for unlimited">

            <div class="d-flex gap-3 mt-1">
                <button class="btn-onyx" onclick="submitPromo()">
                    <i data-lucide="check" style="width:14px;height:14px;"></i> Create Promo
                </button>
                <button class="btn-cancel-modal" onclick="closeModal()">Cancel</button>
            </div>
        </div>
    </div>

    <script>
        function openModal()  { document.getElementById('addPromoModal').classList.add('open'); }
        function closeModal() { document.getElementById('addPromoModal').classList.remove('open'); }
        function handleOverlayClick(e) { if (e.target === e.currentTarget) closeModal(); }

        function submitPromo() {
            var code = document.getElementById('newPromoCode').value.trim().toUpperCase();
            if (!code) { alert('Please enter a promo code.'); return; }
            // TODO: POST to server when backend is ready.
            closeModal();
            alert('Promo code "' + code + '" created successfully! (UI-only — connect to backend to persist.)');
        }
    </script>

</asp:Content>

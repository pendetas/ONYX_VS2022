<%@ Page Title="Product Form" Language="C#" MasterPageFile="~/admin_page/admin.Master"
    AutoEventWireup="true" CodeBehind="onyx_admin_products_form.aspx.cs"
    Inherits="ONYX_DDAC.admin_page.onyx_admin_products_form"
    MaintainScrollPositionOnPostback="true" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
<style>
    /* ── Page header ─────────────────────────────── */
    .form-header {
        display: flex; align-items: flex-start; justify-content: space-between;
        margin-bottom: 44px;
    }
    .page-title    { font-size: 22px; font-weight: 600; color: #fff; letter-spacing: -0.02em; margin: 0; }
    .page-subtitle { font-size: 12px; color: rgba(255,255,255,0.58); margin-top: 5px; font-weight: 400; letter-spacing: 0.02em; }

    .back-link {
        display: inline-flex; align-items: center; gap: 6px; font-size: 13px;
        color: rgba(255,255,255,0.28); text-decoration: none; transition: color 0.15s;
        flex-shrink: 0; margin-top: 4px;
    }
    .back-link:hover { color: rgba(255,255,255,0.68); text-decoration: none; }
    .back-link i { width: 14px; height: 14px; }

    /* ── Alert ───────────────────────────────────── */
    .alert-panel { padding: 12px 16px; margin-bottom: 32px; font-size: 13px; line-height: 1.5; }
    .alert-success-dark { border: 1px solid rgba(255,255,255,0.20); background: rgba(255,255,255,0.04); color: rgba(255,255,255,0.82); }
    .alert-error-dark   { border: 1px solid rgba(255,68,68,0.42); background: rgba(255,68,68,0.06); color: #ff8a8a; }

    /* ── Form body ───────────────────────────────── */
    .form-body { max-width: 960px; width: 100%; }

    /* ── Section ─────────────────────────────────── */
    .form-section { margin-bottom: 40px; }
    .section-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.14em; text-transform: uppercase;
        color: rgba(255,255,255,0.18); margin-bottom: 22px;
        padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.05);
    }

    /* ── Field rows ──────────────────────────────── */
    .field-row { display: grid; gap: 28px 36px; margin-bottom: 26px; }
    .field-row:last-child { margin-bottom: 0; }
    .fr-2 { grid-template-columns: 1fr 1fr; }
    .fr-1 { grid-template-columns: 1fr; }
    .field-group { display: flex; flex-direction: column; min-width: 0; }

    .field-label {
        font-size: 10px; font-weight: 600; letter-spacing: 0.10em; text-transform: uppercase;
        color: rgba(255,255,255,0.62); margin-bottom: 10px;
    }
    .req { color: rgba(255,68,68,0.75); margin-left: 3px; }

    /* ── Underline inputs ────────────────────────── */
    .field-input, .field-select, .field-textarea {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 14px; font-weight: 400;
        padding: 8px 0; width: 100%; outline: none;
        transition: border-color 0.18s; font-family: inherit;
    }
    .field-input::placeholder, .field-textarea::placeholder { color: rgba(255,255,255,0.46); }
    .field-input:focus, .field-select:focus, .field-textarea:focus { border-bottom-color: rgba(255,255,255,0.40); }
    .field-input:disabled { opacity: 0.40; cursor: not-allowed; }
    .field-input[readonly] { color: rgba(255,255,255,0.72); cursor: default; }

    .field-select {
        appearance: none; -webkit-appearance: none; cursor: pointer;
        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(255,255,255,0.25)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
        background-repeat: no-repeat; background-position: right 2px center; padding-right: 22px;
        color: rgba(255,255,255,0.85);
    }
    .field-select option { background-color: #111113; color: #fff; }

    .field-textarea { resize: vertical; min-height: 96px; line-height: 1.65; border-bottom: 1px solid rgba(255,255,255,0.10); }

    .field-hint { font-size: 11px; color: rgba(255,255,255,0.52); margin-top: 7px; line-height: 1.5; }
    .field-hint.managed { color: rgba(255,255,255,0.58); font-style: italic; }

    .category-wrap { max-width: 260px; }

    .campaign-toggle {
        display: inline-flex; align-items: center; gap: 10px;
        color: rgba(255,255,255,0.76); font-size: 13px; font-weight: 600;
    }
    .campaign-toggle input { width: 16px; height: 16px; accent-color: #fff; }
    .campaign-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 28px 36px; }
    .campaign-grid .field-group.full { grid-column: 1 / -1; }
    .campaign-builder-actions {
        display: grid; grid-template-columns: minmax(220px, 1fr) auto;
        gap: 14px; align-items: end; margin-top: 24px;
    }
    .campaign-add-btn, .campaign-block-btn {
        border: 1px solid rgba(255,255,255,0.14); background: rgba(255,255,255,0.04);
        color: rgba(255,255,255,0.82); border-radius: 6px; padding: 10px 14px;
        font-size: 12px; font-weight: 700; letter-spacing: 0.05em; text-transform: uppercase; cursor: pointer;
    }
    .campaign-add-btn:hover, .campaign-block-btn:hover,
    .campaign-add-btn:focus-visible, .campaign-block-btn:focus-visible {
        background: rgba(255,255,255,0.10); border-color: rgba(255,255,255,0.34); color: #fff; outline: none;
    }
    .campaign-block-btn { padding: 8px 10px; font-size: 10px; }
    .campaign-block-btn.danger { border-color: rgba(255,68,68,0.26); color: #ff7777; }
    .campaign-block-list { display: grid; gap: 16px; margin-top: 20px; }
    .campaign-block-card {
        border: 1px solid rgba(255,255,255,0.08); border-radius: 8px;
        padding: 18px; background: rgba(255,255,255,0.025); min-width: 0;
    }
    .campaign-block-head {
        display: flex; align-items: center; justify-content: space-between; gap: 12px;
        margin-bottom: 16px;
    }
    .campaign-block-title { color: rgba(255,255,255,0.84); font-size: 13px; font-weight: 700; }
    .campaign-block-meta { color: rgba(255,255,255,0.34); font-size: 11px; margin-top: 4px; }
    .campaign-block-actions { display: flex; flex-wrap: wrap; gap: 8px; justify-content: flex-end; }
    .campaign-block-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 18px 22px; }
    .campaign-block-fields .field-group.full { grid-column: 1 / -1; }
    .campaign-block-card[data-block-type="TextSection"] .campaign-field--media,
    .campaign-block-card[data-block-type="TextSection"] .campaign-field--json,
    .campaign-block-card[data-block-type="HeroMedia"] .campaign-field--json,
    .campaign-block-card[data-block-type="TextImageSection"] .campaign-field--json,
    .campaign-block-card[data-block-type="MediaSection"] .campaign-field--json,
    .campaign-block-card[data-block-type="VideoSection"] .campaign-field--json,
    .campaign-block-card[data-block-type="TechSpecs"] .campaign-field--media,
    .campaign-block-card[data-block-type="FeatureCards"] .campaign-field--media,
    .campaign-block-card[data-block-type="CTASection"] .campaign-field--media,
    .campaign-block-card[data-block-type="SpacerSection"] .campaign-field--text,
    .campaign-block-card[data-block-type="SpacerSection"] .campaign-field--media,
    .campaign-block-card[data-block-type="SpacerSection"] .campaign-field--json {
        display: none;
    }
    .campaign-media-preview {
        display: grid; grid-template-columns: 84px 1fr; gap: 12px; align-items: center;
        margin-bottom: 10px; padding: 10px; border: 1px solid rgba(255,255,255,0.07);
        border-radius: 6px; background: rgba(255,255,255,0.025);
    }
    .campaign-media-preview img,
    .campaign-media-preview video {
        width: 84px; height: 64px; object-fit: cover; border-radius: 5px; background: #08080a;
    }
    .campaign-media-preview span { color: rgba(255,255,255,0.34); font-size: 11px; word-break: break-all; }
    .campaign-media-upload { display: grid; gap: 10px; }
    .campaign-file-input {
        width: 100%; border: 1px dashed rgba(255,255,255,0.12); border-radius: 6px;
        padding: 10px; color: rgba(255,255,255,0.58); background: rgba(255,255,255,0.02);
        font-size: 12px;
    }
    .campaign-empty {
        border: 1px dashed rgba(255,255,255,0.12); border-radius: 8px;
        padding: 18px; color: rgba(255,255,255,0.24); font-size: 12px; margin-top: 18px;
    }

    @media (max-width: 760px) {
        .form-header { flex-direction: column; gap: 16px; margin-bottom: 30px; }
        .field-row, .campaign-grid, .campaign-block-fields, .campaign-builder-actions,
        .create-color-choices { grid-template-columns: 1fr; gap: 18px; }
        .campaign-grid .field-group.full, .campaign-block-fields .field-group.full { grid-column: auto; }
        .campaign-block-card { padding: 14px; }
        .campaign-block-head { align-items: stretch; flex-direction: column; }
        .campaign-block-actions { justify-content: flex-start; }
        .campaign-block-btn { min-height: 40px; }
        .campaign-media-preview { grid-template-columns: 1fr; }
        .campaign-media-preview img, .campaign-media-preview video { height: auto; max-height: 220px; width: 100%; }
        .form-actions { align-items: stretch; bottom: 10px; flex-direction: column; margin-left: -8px; margin-right: -8px; }
        .form-actions .form-actions__main { display: grid; grid-template-columns: 1fr 1fr; width: 100%; }
        .btn-save, .btn-delete, .btn-cancel { box-sizing: border-box; justify-content: center; min-height: 42px; text-align: center; width: 100%; }
        .btn-delete { margin-left: 0; }
        .required-note { margin-left: 0; text-align: center; }
        .cv-table { display: block; overflow-x: auto; }
    }

    /* ── Product images ──────────────────────────── */
    .media-helper {
        margin: -4px 0 16px; color: rgba(255,255,255,0.24);
        font-size: 12px; line-height: 1.6;
    }
    .image-file-input {
        width: 100%; padding: 12px; border: 1px dashed rgba(255,255,255,0.12);
        border-radius: 6px; background: rgba(255,255,255,0.025); color: rgba(255,255,255,0.62);
        font-size: 12px;
    }
    .product-image-manager {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(142px, 1fr));
        gap: 12px; margin-top: 16px;
    }
    .product-image-card {
        position: relative; min-width: 0; border: 1px solid rgba(255,255,255,0.08);
        border-radius: 8px; background: rgba(255,255,255,0.025); overflow: hidden;
    }
    .product-image-card.dragging { opacity: 0.52; border-color: rgba(255,255,255,0.35); }
    .product-image-thumb {
        width: 100%; aspect-ratio: 1 / 1; background: rgba(255,255,255,0.035);
        object-fit: cover; display: block;
    }
    .product-image-meta { padding: 10px; }
    .product-image-name {
        color: rgba(255,255,255,0.70); font-size: 11px; line-height: 1.35;
        white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .product-image-badge {
        position: absolute; top: 8px; left: 8px; padding: 3px 7px;
        border-radius: 999px; background: rgba(255,255,255,0.88); color: #111113;
        font-size: 9px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase;
    }
    .product-image-actions {
        display: grid; grid-template-columns: 28px 28px 1fr; gap: 6px; margin-top: 10px;
    }
    .image-action-btn {
        min-height: 28px; border: 1px solid rgba(255,255,255,0.10);
        border-radius: 5px; background: transparent; color: rgba(255,255,255,0.60);
        font-size: 11px; font-family: inherit; cursor: pointer;
    }
    .image-action-btn:hover, .image-action-btn:focus {
        border-color: rgba(255,255,255,0.28); color: rgba(255,255,255,0.92); outline: none;
    }
    .image-action-btn:disabled { opacity: 0.28; cursor: not-allowed; }
    .image-remove-btn { color: #ff6a6a; }
    .product-image-empty {
        margin-top: 16px; min-height: 96px; border: 1px dashed rgba(255,255,255,0.08);
        border-radius: 6px; display: flex; align-items: center; justify-content: center;
        gap: 8px; color: rgba(255,255,255,0.16); font-size: 11px; letter-spacing: 0.08em;
        text-transform: uppercase;
    }
    .product-image-empty i { width: 16px; height: 16px; }
    .product-image-validation {
        display: none; margin-top: 12px; padding: 10px 12px; border-left: 2px solid rgba(255,68,68,0.55);
        background: rgba(255,68,68,0.05); color: #ff6a6a; font-size: 12px; line-height: 1.45;
    }

    /* ── Colors section ──────────────────────────── */
    .color-hint {
        font-size: 12px; color: rgba(255,255,255,0.22); margin-bottom: 18px; line-height: 1.6;
    }

    .create-color-choices {
        display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 10px 12px; margin-top: 14px;
    }
    .create-color-choices input { position: absolute; opacity: 0; pointer-events: none; }
    .create-color-choices label {
        display: flex; align-items: center; justify-content: space-between;
        min-height: 42px; padding: 0 14px; border-radius: 6px;
        border: 1px solid rgba(255,255,255,0.10);
        background: rgba(255,255,255,0.015); color: rgba(255,255,255,0.58);
        font-size: 12px; font-weight: 600; cursor: pointer;
        transition: border-color 0.16s, color 0.16s, background 0.16s;
    }
    .create-color-choices label:hover {
        border-color: rgba(255,255,255,0.24); color: rgba(255,255,255,0.88);
    }
    .create-color-choices input:checked + label {
        border-color: rgba(255,255,255,0.72);
        background: rgba(255,255,255,0.08); color: #fff;
    }

    /* Color chip swatches */
    .color-swatches { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 24px; }

    .swatch-chip {
        display: inline-flex; align-items: center; gap: 7px;
        padding: 6px 14px 6px 8px; border-radius: 20px;
        border: 1px solid rgba(255,255,255,0.08);
        background: transparent; color: rgba(255,255,255,0.42);
        font-size: 12px; font-weight: 500; font-family: 'Inter', sans-serif;
        cursor: pointer; text-decoration: none;
        transition: border-color 0.15s, color 0.15s, background 0.15s;
        white-space: nowrap;
    }
    .swatch-chip:hover { border-color: rgba(255,255,255,0.22); color: rgba(255,255,255,0.75); }

    .swatch-dot {
        width: 11px; height: 11px; border-radius: 50%; flex-shrink: 0;
        border: 1px solid rgba(255,255,255,0.12);
    }

    .swatch-chip.active {
        border-color: rgba(255,255,255,0.30);
        background: rgba(255,255,255,0.06);
        color: rgba(255,255,255,0.88);
    }
    .swatch-chip.active:hover { background: rgba(255,255,255,0.09); }

    .swatch-stock {
        font-size: 10px; color: rgba(255,255,255,0.35);
        background: rgba(255,255,255,0.08); padding: 1px 6px; border-radius: 10px;
        margin-left: 2px;
    }

    /* Color variants table */
    .cv-table { width: 100%; border-collapse: collapse; }
    .cv-table th {
        text-align: left; font-size: 10px; font-weight: 600; letter-spacing: 0.08em;
        text-transform: uppercase; color: rgba(255,255,255,0.22);
        padding-bottom: 10px; border-bottom: 1px solid rgba(255,255,255,0.06);
    }
    .cv-table td { padding: 11px 0; border-bottom: 1px solid rgba(255,255,255,0.04); vertical-align: middle; }
    .cv-table tr:last-child td { border-bottom: none; }
    .cv-table tbody tr:hover td { background: rgba(255,255,255,0.015); }

    .cv-color-cell { display: flex; align-items: center; gap: 9px; }
    .cv-dot { width: 12px; height: 12px; border-radius: 50%; border: 1px solid rgba(255,255,255,0.15); flex-shrink: 0; }
    .cv-name { font-size: 13px; font-weight: 500; color: rgba(255,255,255,0.80); }

    .cv-input {
        background: transparent; border: none;
        border-bottom: 1px solid rgba(255,255,255,0.10);
        color: #fff; font-size: 13px; font-family: 'Inter', sans-serif;
        padding: 4px 0; width: 90px; outline: none; transition: border-color 0.15s;
    }
    .cv-input:focus { border-bottom-color: rgba(255,255,255,0.40); }

    .cv-save-btn {
        background: rgba(255,255,255,0.88); color: #0d0d0f;
        border: none; border-radius: 5px; font-size: 11px; font-weight: 600;
        padding: 5px 14px; cursor: pointer; font-family: 'Inter', sans-serif; transition: opacity 0.12s;
    }
    .cv-save-btn:hover { opacity: 0.80; }

    /* ── Action bar ──────────────────────────────── */
    .form-actions {
        position: sticky; bottom: 18px; z-index: 20;
        display: flex; align-items: center; gap: 10px;
        margin: 34px -18px 0; padding: 12px 14px;
        border: 1px solid rgba(255,255,255,0.10); border-top-color: rgba(255,255,255,0.18);
        border-radius: 9px; background: rgba(12,12,15,0.88);
        box-shadow: 0 18px 46px rgba(0,0,0,0.34);
        backdrop-filter: blur(16px); -webkit-backdrop-filter: blur(16px);
    }
    .form-actions__main { display: flex; align-items: center; gap: 10px; }
    .btn-save, .btn-delete, .btn-cancel {
        min-height: 42px; display: inline-flex; align-items: center; justify-content: center;
        border-radius: 6px; font-family: inherit; font-size: 11px; font-weight: 750;
        letter-spacing: 0.09em; line-height: 1; text-decoration: none; text-transform: uppercase;
        transition: transform 140ms ease, background 140ms ease, border-color 140ms ease, color 140ms ease;
    }
    .btn-save { padding: 0 24px; border: 1px solid #fff; background: #fff; color: #08080a; cursor: pointer; }
    .btn-save:hover { transform: translateY(-1px); background: #e8e8ea; border-color: #e8e8ea; }
    .btn-save:disabled { cursor: wait; opacity: 0.58; transform: none; }
    .btn-delete {
        margin-left: 8px; padding: 0 17px;
        background: rgba(255,68,68,0.08); color: #ff6b6b; border: 1px solid rgba(255,68,68,0.28);
        cursor: pointer;
    }
    .btn-delete:hover { transform: translateY(-1px); background: rgba(255,68,68,0.14); border-color: rgba(255,68,68,0.45); }
    .btn-cancel { padding: 0 18px; border: 1px solid rgba(255,255,255,0.14); color: rgba(255,255,255,0.68); }
    .btn-cancel:hover { transform: translateY(-1px); border-color: rgba(255,255,255,0.32); color: #fff; text-decoration: none; }
    .btn-save:focus-visible, .btn-delete:focus-visible, .btn-cancel:focus-visible {
        outline: 2px solid #fff; outline-offset: 3px;
    }
    .required-note { margin-left: auto; font-size: 10px; color: rgba(255,255,255,0.28); letter-spacing: 0.08em; text-transform: uppercase; }

    @media (prefers-reduced-motion: reduce) {
        .btn-save, .btn-delete, .btn-cancel { transition: none; }
    }

    /* ── Light mode ──────────────────────────────── */
    html[data-theme="light"] .page-title    { color: #0d0d0f; }
    html[data-theme="light"] .page-subtitle { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .section-label { color: rgba(0,0,0,0.22); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .field-label   { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .field-input, html[data-theme="light"] .field-select, html[data-theme="light"] .field-textarea { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .field-input:focus, html[data-theme="light"] .field-select:focus, html[data-theme="light"] .field-textarea:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .field-input::placeholder, html[data-theme="light"] .field-textarea::placeholder { color: rgba(0,0,0,0.18); }
    html[data-theme="light"] .field-input[readonly] { color: rgba(0,0,0,0.62); }
    html[data-theme="light"] .field-hint   { color: rgba(0,0,0,0.22); }
    html[data-theme="light"] .campaign-toggle { color: rgba(0,0,0,0.72); }
    html[data-theme="light"] .field-select { background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='11' height='11' viewBox='0 0 24 24' fill='none' stroke='rgba(0,0,0,0.30)' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E"); color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .field-select option { background: #fff; color: #0d0d0f; }
    html[data-theme="light"] .media-helper { color: rgba(0,0,0,0.35); }
    html[data-theme="light"] .image-file-input { border-color: rgba(0,0,0,0.12); background: rgba(0,0,0,0.018); color: rgba(0,0,0,0.62); }
    html[data-theme="light"] .product-image-card { border-color: rgba(0,0,0,0.09); background: rgba(0,0,0,0.018); }
    html[data-theme="light"] .product-image-thumb { background: rgba(0,0,0,0.04); }
    html[data-theme="light"] .product-image-name { color: rgba(0,0,0,0.66); }
    html[data-theme="light"] .product-image-badge { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .image-action-btn { border-color: rgba(0,0,0,0.10); color: rgba(0,0,0,0.58); }
    html[data-theme="light"] .image-action-btn:hover, html[data-theme="light"] .image-action-btn:focus { border-color: rgba(0,0,0,0.28); color: rgba(0,0,0,0.88); }
    html[data-theme="light"] .product-image-empty { border-color: rgba(0,0,0,0.08); color: rgba(0,0,0,0.18); }
    html[data-theme="light"] .product-image-validation { background: rgba(196,42,42,0.06); color: #c42a2a; }
    html[data-theme="light"] .form-actions { background: rgba(255,255,255,0.90); border-color: rgba(0,0,0,0.10); border-top-color: rgba(0,0,0,0.18); box-shadow: 0 18px 46px rgba(16,16,20,0.12); }
    html[data-theme="light"] .btn-save     { background: #0d0d0f; color: #fff; }
    html[data-theme="light"] .btn-save:hover { background: #2a2a2a; border-color: #2a2a2a; }
    html[data-theme="light"] .btn-delete { background: rgba(196,42,42,0.05); color: #c42a2a; border-color: rgba(196,42,42,0.28); }
    html[data-theme="light"] .btn-delete:hover { background: rgba(196,42,42,0.10); border-color: rgba(196,42,42,0.42); }
    html[data-theme="light"] .btn-cancel   { border-color: rgba(0,0,0,0.14); color: rgba(0,0,0,0.58); }
    html[data-theme="light"] .btn-cancel:hover { border-color: rgba(0,0,0,0.32); color: rgba(0,0,0,0.90); }
    html[data-theme="light"] .btn-save:focus-visible, html[data-theme="light"] .btn-delete:focus-visible, html[data-theme="light"] .btn-cancel:focus-visible { outline-color: #0d0d0f; }
    html[data-theme="light"] .required-note { color: rgba(0,0,0,0.20); }
    html[data-theme="light"] .color-hint   { color: rgba(0,0,0,0.30); }
    html[data-theme="light"] .create-color-choices label { border-color: rgba(0,0,0,0.10); background: rgba(0,0,0,0.015); color: rgba(0,0,0,0.50); }
    html[data-theme="light"] .create-color-choices label:hover { border-color: rgba(0,0,0,0.25); color: rgba(0,0,0,0.80); }
    html[data-theme="light"] .create-color-choices input:checked + label { border-color: rgba(0,0,0,0.70); background: rgba(0,0,0,0.06); color: #0d0d0f; }
    html[data-theme="light"] .swatch-chip  { border-color: rgba(0,0,0,0.10); color: rgba(0,0,0,0.45); }
    html[data-theme="light"] .swatch-chip:hover { border-color: rgba(0,0,0,0.25); color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .swatch-chip.active { border-color: rgba(0,0,0,0.30); background: rgba(0,0,0,0.05); color: rgba(0,0,0,0.80); }
    html[data-theme="light"] .swatch-dot   { border-color: rgba(0,0,0,0.12); }
    html[data-theme="light"] .swatch-stock { color: rgba(0,0,0,0.38); background: rgba(0,0,0,0.06); }
    html[data-theme="light"] .cv-table th  { color: rgba(0,0,0,0.22); border-bottom-color: rgba(0,0,0,0.06); }
    html[data-theme="light"] .cv-table td  { border-bottom-color: rgba(0,0,0,0.04); }
    html[data-theme="light"] .cv-name  { color: rgba(0,0,0,0.75); }
    html[data-theme="light"] .cv-dot   { border-color: rgba(0,0,0,0.12); }
    html[data-theme="light"] .cv-input { color: #0d0d0f; border-bottom-color: rgba(0,0,0,0.10); }
    html[data-theme="light"] .cv-input:focus { border-bottom-color: rgba(0,0,0,0.38); }
    html[data-theme="light"] .cv-save-btn { background: #0d0d0f; color: #fff; }
</style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="form-header">
        <div>
            <h1 class="page-title"><asp:Literal ID="litPageTitle" runat="server" Text="Add New Product" /></h1>
            <p class="page-subtitle"><asp:Literal ID="litPageSubtitle" runat="server" Text="Fill in the details below to add a new product." /></p>
        </div>
        <asp:HyperLink ID="lnkBack" runat="server" CssClass="back-link" NavigateUrl="onyx_admin_products.aspx">
            <i data-lucide="arrow-left"></i> Back
        </asp:HyperLink>
    </div>

    <asp:Panel ID="pnlAlert" runat="server" Visible="false" role="status" aria-live="polite">
        <asp:Literal ID="litAlertMessage" runat="server" />
    </asp:Panel>

    <div class="form-body">

        <%-- Product Info --%>
        <div class="form-section">
            <div class="section-label">Product Info</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <label class="field-label">Name <span class="req">*</span></label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="field-input" placeholder="e.g. Viper V2 Pro" MaxLength="100" />
                    <div class="field-hint">Max 100 characters.</div>
                </div>
                <div class="field-group">
                    <label class="field-label">Brand</label>
                    <asp:TextBox ID="txtBrand" runat="server" CssClass="field-input" Text="ONYX" ReadOnly="true" MaxLength="50" />
                    <div class="field-hint managed">Locked to ONYX for every product.</div>
                </div>
            </div>
            <div class="field-row fr-1">
                <div class="field-group category-wrap">
                    <label class="field-label">Category <span class="req">*</span></label>
                    <asp:DropDownList ID="ddlCategory" runat="server" CssClass="field-select">
                        <asp:ListItem Value=""         Text="Select category" />
                        <asp:ListItem Value="Mouse"    Text="Mouse" />
                        <asp:ListItem Value="Keyboard" Text="Keyboard" />
                        <asp:ListItem Value="Headset"  Text="Headset" />
                        <asp:ListItem Value="Monitor"  Text="Monitor" />
                        <asp:ListItem Value="Chair"    Text="Chair" />
                        <asp:ListItem Value="Mic" Text="Mic" />
                        <asp:ListItem Value="Monitor Extension" Text="Monitor Extension" />
                        <asp:ListItem Value="Accessory" Text="Accessory" />
                        <asp:ListItem Value="Mousepad" Text="Mousepad" />
                        <asp:ListItem Value="Cable" Text="Cable" />
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <%-- Pricing & Inventory --%>
        <div class="form-section">
            <div class="section-label">Pricing &amp; Inventory</div>
            <div class="field-row fr-2">
                <div class="field-group">
                    <label class="field-label">Price (RM) <span class="req">*</span></label>
                    <asp:TextBox ID="txtPrice" runat="server" CssClass="field-input" placeholder="0.00" TextMode="Number" />
                    <div class="field-hint">Malaysian Ringgit (MYR).</div>
                </div>
                <div class="field-group">
                    <label class="field-label">Stock Qty <span class="req">*</span></label>
                    <asp:TextBox ID="txtStock" runat="server" CssClass="field-input" placeholder="0" TextMode="Number" />
                    <asp:Label ID="lblStockHint" runat="server" CssClass="field-hint" Text="Set 0 to mark as out of stock." />
                </div>
            </div>
        </div>

        <%-- Colors — edit mode only (wrapped in UpdatePanel so chip clicks don't scroll to top) --%>
        <asp:UpdatePanel ID="upColors" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="true">
        <ContentTemplate>
        <asp:Panel ID="pnlCreateColors" runat="server" Visible="false">
            <div class="form-section">
                <div class="section-label">Launch colors</div>
                <p class="color-hint">
                    Choose the colors available when this product launches. ONYX will append them as product variants after saving.
                </p>
                <asp:CheckBoxList ID="CreateColorChoices" runat="server" CssClass="create-color-choices" RepeatLayout="Flow" />
                <div class="field-hint">Selected colors use the base price. Entered stock is distributed across the chosen colors.</div>
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlColors" runat="server" Visible="false">
            <div class="form-section">
                <div class="section-label">Colors</div>
                <p class="color-hint">
                    Click a color to add it as a variant. Click an active color to remove it.<br />
                    Set the stock per color in the table below.
                </p>

                <%-- Color chip row --%>
                <div class="color-swatches">
                    <asp:Repeater ID="ColorSwatchRepeater" runat="server"
                        OnItemCommand="ColorSwatchRepeater_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandName="ToggleColor"
                                CommandArgument='<%# Eval("Name") %>'
                                CssClass='<%# "swatch-chip " + ((bool)Eval("IsActive") ? "active" : "") %>'
                                CausesValidation="false">
                                <span class="swatch-dot" style='<%# "background:" + Eval("Hex") %>'></span>
                                <%# Eval("Name") %>
                                <%# (bool)Eval("IsActive") ? "<span class=\"swatch-stock\">" + Eval("StockQty") + "</span>" : "" %>
                            </asp:LinkButton>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <%-- Active color variants — stock editing --%>
                <asp:Panel ID="pnlColorVariants" runat="server" Visible="false">
                    <asp:Repeater ID="ColorVariantsRepeater" runat="server"
                        OnItemCommand="ColorVariantsRepeater_ItemCommand">
                        <HeaderTemplate>
                            <table class="cv-table">
                                <thead><tr>
                                    <th>Color</th>
                                    <th style="width:130px">Price (RM)</th>
                                    <th style="width:110px">Stock</th>
                                    <th style="width:80px"></th>
                                </tr></thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="cv-color-cell">
                                        <span class="cv-dot" style='<%# "background:" + GetColorHex(Eval("VariantValue").ToString()) %>'></span>
                                        <span class="cv-name"><%# Server.HtmlEncode(Eval("VariantValue").ToString()) %></span>
                                    </div>
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCvPrice" runat="server"
                                        Text='<%# string.Format("{0:N2}", Eval("VariantPrice")) %>'
                                        CssClass="cv-input" data-gramm="false" data-gramm_editor="false" />
                                </td>
                                <td>
                                    <asp:TextBox ID="txtCvStock" runat="server"
                                        Text='<%# Eval("StockQty") %>'
                                        CssClass="cv-input" data-gramm="false" data-gramm_editor="false" />
                                </td>
                                <td>
                                    <asp:Button ID="btnSaveCv" runat="server"
                                        CommandName="SaveColor"
                                        CommandArgument='<%# Eval("ProductVariantId") %>'
                                        Text="Save" CssClass="cv-save-btn" CausesValidation="false" />
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>
                </asp:Panel>

            </div>
        </asp:Panel>
        </ContentTemplate>
        </asp:UpdatePanel>

        <%-- Details --%>
        <div class="form-section">
            <div class="section-label">Details</div>
            <div class="field-group">
                <label class="field-label">Description</label>
                <asp:TextBox ID="txtDescription" runat="server" CssClass="field-textarea"
                    TextMode="MultiLine" Rows="5"
                    placeholder="Key features, compatibility, materials..."
                    MaxLength="2000" />
                <div class="field-hint">Max 2,000 characters. Plain text only.</div>
            </div>
        </div>

        <%-- Product campaign --%>
        <div class="form-section">
            <div class="section-label">Product Campaign</div>
            <label class="campaign-toggle">
                <asp:CheckBox ID="chkCampaignEnabled" runat="server" />
                Show long-form campaign layout on the product page
            </label>
            <div class="field-hint">Leave disabled for products that should use only the standard product details layout.</div>

            <div class="section-label" style="margin-top:28px;">Product Campaign Builder</div>
            <div class="field-hint">Add reusable blocks in any order. The same block type can be added multiple times; SortOrder controls rendering.</div>
            <div class="campaign-builder-actions">
                <div class="field-group">
                    <label class="field-label">Block type</label>
                    <asp:DropDownList ID="ddlCampaignBlockType" runat="server" CssClass="field-select">
                        <asp:ListItem Value="HeroMedia">Hero + media</asp:ListItem>
                        <asp:ListItem Value="TextSection">Text section</asp:ListItem>
                        <asp:ListItem Value="TextImageSection">Text + image</asp:ListItem>
                        <asp:ListItem Value="MediaSection">Media section</asp:ListItem>
                        <asp:ListItem Value="VideoSection">Video section</asp:ListItem>
                        <asp:ListItem Value="FeatureCards">Feature cards</asp:ListItem>
                        <asp:ListItem Value="TechSpecs">Technical specifications</asp:ListItem>
                        <asp:ListItem Value="CTASection">Call to action</asp:ListItem>
                        <asp:ListItem Value="SpacerSection">Spacing</asp:ListItem>
                    </asp:DropDownList>
                </div>
                <asp:Button ID="btnAddCampaignBlock" runat="server" Text="Add Block"
                    CssClass="campaign-add-btn" CausesValidation="false" OnClick="btnAddCampaignBlock_Click" />
            </div>

            <asp:Repeater ID="rptCampaignBlocks" runat="server" OnItemCommand="rptCampaignBlocks_ItemCommand">
                <HeaderTemplate><div class="campaign-block-list"></HeaderTemplate>
                <ItemTemplate>
                    <div class="campaign-block-card" data-campaign-block data-block-type='<%# Eval("BlockType") %>'>
                        <div class="campaign-block-head">
                            <div>
                                <div class="campaign-block-title">
                                    #<%# Eval("SortOrder") %> · <%# Server.HtmlEncode(Eval("BlockType").ToString()) %>
                                </div>
                                <div class="campaign-block-meta"><%# Server.HtmlEncode(GetCampaignBlockLabel(Container.DataItem)) %></div>
                            </div>
                            <div class="campaign-block-actions">
                                <asp:LinkButton ID="btnMoveCampaignBlockUp" runat="server" CssClass="campaign-block-btn"
                                    CommandName="MoveUp" CommandArgument='<%# Eval("Id") %>' CausesValidation="false">Move Up</asp:LinkButton>
                                <asp:LinkButton ID="btnMoveCampaignBlockDown" runat="server" CssClass="campaign-block-btn"
                                    CommandName="MoveDown" CommandArgument='<%# Eval("Id") %>' CausesValidation="false">Move Down</asp:LinkButton>
                                <asp:LinkButton ID="btnSaveCampaignBlock" runat="server" CssClass="campaign-block-btn"
                                    CommandName="SaveBlock" CommandArgument='<%# Eval("Id") %>' CausesValidation="false">Save Block</asp:LinkButton>
                                <asp:LinkButton ID="btnDeleteCampaignBlock" runat="server" CssClass="campaign-block-btn danger"
                                    CommandName="DeleteBlock" CommandArgument='<%# Eval("Id") %>' CausesValidation="false"
                                    OnClientClick="return confirm('Delete this campaign block?');">Delete</asp:LinkButton>
                            </div>
                        </div>
                        <asp:HiddenField ID="hfCampaignBlockId" runat="server" Value='<%# Eval("Id") %>' />
                        <asp:HiddenField ID="hfCampaignBlockType" runat="server" Value='<%# Eval("BlockType") %>' />
                        <div class="campaign-block-fields">
                            <div class="field-group">
                                <label class="campaign-toggle">
                                    <asp:CheckBox ID="chkBlockEnabled" runat="server" Checked='<%# (bool)Eval("IsEnabled") %>' />
                                    Enabled
                                </label>
                            </div>
                            <div class="field-group campaign-field--text">
                                <label class="field-label">Eyebrow</label>
                                <asp:TextBox ID="txtBlockEyebrow" runat="server" CssClass="field-input" MaxLength="100" Text='<%# Eval("Eyebrow") %>' />
                            </div>
                            <div class="field-group full campaign-field--text">
                                <label class="field-label">Headline</label>
                                <asp:TextBox ID="txtBlockHeadline" runat="server" CssClass="field-input" MaxLength="200" Text='<%# Eval("Headline") %>' />
                            </div>
                            <div class="field-group full campaign-field--text">
                                <label class="field-label">Body</label>
                                <asp:TextBox ID="txtBlockBody" runat="server" CssClass="field-textarea" TextMode="MultiLine" Rows="3" MaxLength="4000" Text='<%# Eval("Body") %>' />
                            </div>
                            <div class="field-group campaign-field--media">
                                <label class="field-label">Media type</label>
                                <asp:TextBox ID="txtBlockMediaType" runat="server" CssClass="field-input" MaxLength="20" Text='<%# Eval("MediaType") %>' placeholder="image, gif, or mp4" />
                            </div>
                            <div class="field-group campaign-field--media">
                                <label class="field-label">Media URL</label>
                                <asp:TextBox ID="txtBlockMediaUrl" runat="server" CssClass="field-input" MaxLength="1000" Text='<%# Eval("MediaUrl") %>' placeholder="/Content/..." />
                            </div>
                            <div class="field-group full campaign-field--media">
                                <asp:Panel ID="pnlBlockMediaPreview" runat="server" CssClass="campaign-media-preview" Visible='<%# !string.IsNullOrWhiteSpace((Eval("MediaUrl") ?? "").ToString()) %>'>
                                    <%# GetCampaignBlockMediaPreview(Container.DataItem) %>
                                </asp:Panel>
                                <div class="campaign-media-upload">
                                    <asp:FileUpload ID="CampaignBlockMediaUpload" runat="server" CssClass="campaign-file-input" accept=".jpg,.jpeg,.png,.webp,.gif,.mp4,image/jpeg,image/png,image/webp,image/gif,video/mp4" />
                                    <label class="campaign-toggle">
                                        <asp:CheckBox ID="chkRemoveBlockMedia" runat="server" />
                                        Remove media
                                    </label>
                                </div>
                                <div class="field-hint">Upload JPG, PNG, WEBP, GIF, or MP4 up to 20 MB. Uploading replaces the media URL.</div>
                            </div>
                            <div class="field-group full campaign-field--media">
                                <label class="field-label">Media alt / title</label>
                                <asp:TextBox ID="txtBlockMediaAlt" runat="server" CssClass="field-input" MaxLength="200" Text='<%# Eval("MediaAlt") %>' />
                            </div>
                            <div class="field-group">
                                <label class="field-label">Layout variant</label>
                                <asp:TextBox ID="txtBlockLayoutVariant" runat="server" CssClass="field-input" MaxLength="50" Text='<%# Eval("LayoutVariant") %>' placeholder="contained, split, image-left..." />
                            </div>
                            <div class="field-group">
                                <label class="field-label">Background variant</label>
                                <asp:TextBox ID="txtBlockBackgroundVariant" runat="server" CssClass="field-input" MaxLength="50" Text='<%# Eval("BackgroundVariant") %>' placeholder="light or dark" />
                            </div>
                            <div class="field-group full campaign-field--json">
                                <label class="field-label">Structured line content</label>
                                <asp:TextBox ID="txtBlockJsonContent" runat="server" CssClass="field-textarea" TextMode="MultiLine" Rows="5" Text='<%# Eval("JsonContent") %>'
                                    MaxLength="8000"
                                    placeholder="FeatureCards: Title|Body|ImageUrl&#10;TechSpecs: Label|Value&#10;CTASection: Label|Url|Style" />
                                <div class="field-hint">Line-based content is stored directly and HTML encoded on the customer page.</div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
                <FooterTemplate></div></FooterTemplate>
            </asp:Repeater>
            <asp:Panel ID="pnlCampaignBlocksEmpty" runat="server" CssClass="campaign-empty" Visible="false">
                No campaign blocks yet. Add a block to start building the long-form page.
            </asp:Panel>
        </div>

        <%-- Media --%>
        <div class="form-section">
            <div class="section-label">Media</div>
            <div class="field-group">
                <asp:HiddenField ID="ExistingProductImagesJson" runat="server" />
                <asp:HiddenField ID="ProductImageOrder" runat="server" />
                <asp:HiddenField ID="RemovedProductImages" runat="server" />
                <asp:HiddenField ID="ProductImageManagerTouched" runat="server" />

                <asp:Label ID="lblProductImages" runat="server" AssociatedControlID="ProductImageUpload" CssClass="field-label">
                    Product photos
                </asp:Label>
                <p class="media-helper">Upload multiple product photos. Drag to reorder. The first image will be used as the main product image.</p>
                <asp:FileUpload ID="ProductImageUpload" runat="server" CssClass="image-file-input" AllowMultiple="true" accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp" />
                <div class="field-hint">Only JPG, JPEG, PNG, and WEBP files up to 5 MB each are accepted.</div>

                <div id="productImageManager" class="product-image-manager" aria-live="polite"></div>
                <div id="productImageEmpty" class="product-image-empty">
                    <i data-lucide="image"></i>
                    No product photos selected
                </div>
                <div id="productImageValidation" class="product-image-validation" role="alert"></div>

                <label class="field-label" style="margin-top:22px;">Image URL</label>
                <asp:TextBox ID="txtImageUrl" runat="server" CssClass="field-input"
                    placeholder="https://..." />
                <div class="field-hint">Optional fallback URL. The saved primary product photo keeps this field synchronized.</div>
            </div>
        </div>

        <%-- Actions --%>
        <div class="form-actions" data-admin-product-actions>
            <div class="form-actions__main">
                <asp:Button ID="btnSave" runat="server" Text="Save product →"
                    CssClass="btn-save" OnClick="btnSave_Click" OnClientClick="return validateAndPrepareProductSave(this);" />
                <a href="onyx_admin_products.aspx" class="btn-cancel">Cancel</a>
            </div>
            <asp:Button ID="btnDelete" runat="server" Text="Delete Product"
                CssClass="btn-delete" OnClick="btnDelete_Click" CausesValidation="false"
                OnClientClick="return confirm('Delete this product? This cannot be undone.');" />
            <span class="required-note"><span class="req">*</span> Required fields</span>
        </div>

    </div>

    <script>
        // Product image manager
        (function () {
            var input = document.getElementById('<%= ProductImageUpload.ClientID %>');
            var existingJson = document.getElementById('<%= ExistingProductImagesJson.ClientID %>');
            var orderField = document.getElementById('<%= ProductImageOrder.ClientID %>');
            var removedField = document.getElementById('<%= RemovedProductImages.ClientID %>');
            var touchedField = document.getElementById('<%= ProductImageManagerTouched.ClientID %>');
            var manager = document.getElementById('productImageManager');
            var empty = document.getElementById('productImageEmpty');
            var validation = document.getElementById('productImageValidation');
            var MaxProductImageBytes = 5 * 1024 * 1024;
            var MaxProductUploadBytes = 50 * 1024 * 1024;
            var allowedExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
            var items = [];
            var removedIds = [];

            function parseExistingImages() {
                try {
                    var existing = JSON.parse(existingJson && existingJson.value ? existingJson.value : '[]');
                    items = existing.map(function (image) {
                        return {
                            token: 'existing:' + image.Id,
                            type: 'existing',
                            id: image.Id,
                            url: image.Url,
                            name: image.Label || 'Existing image'
                        };
                    });
                } catch (ex) {
                    items = [];
                }
            }

            function syncHiddenFields() {
                if (orderField) orderField.value = items.map(function (item) { return item.token; }).join(',');
                if (removedField) removedField.value = removedIds.join(',');
            }

            function showValidationMessage(message) {
                if (validation) {
                    validation.textContent = message;
                    validation.style.display = 'block';
                    validation.scrollIntoView({ block: 'nearest' });
                } else {
                    alert(message);
                }
            }

            function clearValidationMessage() {
                if (!validation) return;
                validation.textContent = '';
                validation.style.display = 'none';
            }

            function formatMegabytes(bytes) {
                return Math.round(bytes / 1024 / 1024);
            }

            function getExtension(fileName) {
                var dotIndex = (fileName || '').lastIndexOf('.');
                return dotIndex >= 0 ? fileName.substring(dotIndex).toLowerCase() : '';
            }

            function validateProductImagesBeforeSubmit() {
                clearValidationMessage();

                var totalBytes = 0;
                for (var i = 0; i < items.length; i++) {
                    var item = items[i];
                    if (item.type !== 'new' || !item.file) continue;

                    var extension = getExtension(item.name);
                    if (allowedExtensions.indexOf(extension) < 0) {
                        showValidationMessage('Only JPG, JPEG, PNG, and WEBP product images are allowed.');
                        return false;
                    }

                    if (item.file.size > MaxProductImageBytes) {
                        showValidationMessage('Each product image must be 5 MB or smaller.');
                        return false;
                    }

                    totalBytes += item.file.size;
                }

                if (totalBytes > MaxProductUploadBytes) {
                    showValidationMessage('Selected product images total ' + formatMegabytes(totalBytes) + ' MB. Keep the total upload size at 50 MB or less.');
                    return false;
                }

                return true;
            }

            window.validateProductImagesBeforeSubmit = validateProductImagesBeforeSubmit;

            window.validateAndPrepareProductSave = function (button) {
                if (!validateProductImagesBeforeSubmit()) return false;

                window.setTimeout(function () {
                    button.disabled = true;
                    button.value = 'Saving…';
                    button.setAttribute('aria-disabled', 'true');
                    var form = button.closest('form');
                    if (form) form.setAttribute('aria-busy', 'true');
                }, 0);

                return true;
            };

            function moveItem(fromIndex, toIndex) {
                if (toIndex < 0 || toIndex >= items.length || fromIndex === toIndex) return;
                if (touchedField) touchedField.value = 'true';
                var moved = items.splice(fromIndex, 1)[0];
                items.splice(toIndex, 0, moved);
                render();
            }

            function removeItem(index) {
                var item = items[index];
                if (!item) return;
                if (touchedField) touchedField.value = 'true';
                if (item.type === 'existing' && removedIds.indexOf(item.id) < 0) removedIds.push(item.id);
                items.splice(index, 1);
                render();
                validateProductImagesBeforeSubmit();
            }

            function render() {
                manager.innerHTML = '';
                empty.style.display = items.length ? 'none' : 'flex';

                items.forEach(function (item, index) {
                    var card = document.createElement('div');
                    card.className = 'product-image-card';
                    card.draggable = true;
                    card.setAttribute('data-index', index);

                    card.addEventListener('dragstart', function (event) {
                        card.classList.add('dragging');
                        event.dataTransfer.setData('text/plain', String(index));
                    });
                    card.addEventListener('dragend', function () { card.classList.remove('dragging'); });
                    card.addEventListener('dragover', function (event) { event.preventDefault(); });
                    card.addEventListener('drop', function (event) {
                        event.preventDefault();
                        var from = parseInt(event.dataTransfer.getData('text/plain'), 10);
                        moveItem(from, index);
                    });

                    var img = document.createElement('img');
                    img.className = 'product-image-thumb';
                    img.src = item.url;
                    img.alt = item.type === 'existing' ? 'Existing product image preview' : 'Selected product image preview for ' + item.name;
                    card.appendChild(img);

                    if (index === 0) {
                        var badge = document.createElement('div');
                        badge.className = 'product-image-badge';
                        badge.textContent = 'Primary';
                        card.appendChild(badge);
                    }

                    var meta = document.createElement('div');
                    meta.className = 'product-image-meta';

                    var name = document.createElement('div');
                    name.className = 'product-image-name';
                    name.textContent = item.name;
                    meta.appendChild(name);

                    var actions = document.createElement('div');
                    actions.className = 'product-image-actions';

                    var left = document.createElement('button');
                    left.type = 'button';
                    left.className = 'image-action-btn';
                    left.textContent = '<';
                    left.disabled = index === 0;
                    left.setAttribute('aria-label', 'Move left ' + item.name);
                    left.addEventListener('click', function () { moveItem(index, index - 1); });
                    actions.appendChild(left);

                    var right = document.createElement('button');
                    right.type = 'button';
                    right.className = 'image-action-btn';
                    right.textContent = '>';
                    right.disabled = index === items.length - 1;
                    right.setAttribute('aria-label', 'Move right ' + item.name);
                    right.addEventListener('click', function () { moveItem(index, index + 1); });
                    actions.appendChild(right);

                    var remove = document.createElement('button');
                    remove.type = 'button';
                    remove.className = 'image-action-btn image-remove-btn';
                    remove.textContent = 'Remove';
                    remove.setAttribute('aria-label', 'Remove ' + item.name);
                    remove.addEventListener('click', function () { removeItem(index); });
                    actions.appendChild(remove);

                    meta.appendChild(actions);
                    card.appendChild(meta);
                    manager.appendChild(card);
                });

                syncHiddenFields();
            }

            if (input) {
                input.addEventListener('change', function () {
                    if (touchedField) touchedField.value = 'true';
                    items = items.filter(function (item) { return item.type !== 'new'; });
                    Array.prototype.slice.call(input.files || []).forEach(function (file, index) {
                        items.push({
                            token: 'new:' + index,
                            type: 'new',
                            url: URL.createObjectURL(file),
                            name: file.name || 'Selected image',
                            file: file
                        });
                    });
                    render();
                    validateProductImagesBeforeSubmit();
                });
            }

            parseExistingImages();
            render();
        })();
    </script>

</asp:Content>

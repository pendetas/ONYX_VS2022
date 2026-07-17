using System;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_promos : Page
    {
        private readonly VoucherService _voucherService = new VoucherService();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ddlStatusFilter.SelectedValue = "all";
                BindPage();
            }
        }

        protected void btnApplyFilters_Click(object sender, EventArgs e)
        {
            BindPage();
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            BindPage();
        }

        protected void rptVouchers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            lblMessage.Visible = false;

            long voucherId;
            if (!long.TryParse(Convert.ToString(e.CommandArgument, CultureInfo.InvariantCulture), NumberStyles.Integer, CultureInfo.InvariantCulture, out voucherId))
            {
                ShowError("The selected voucher could not be identified.");
                BindPage();
                return;
            }

            try
            {
                if (string.Equals(e.CommandName, "Toggle", StringComparison.OrdinalIgnoreCase))
                {
                    Voucher voucher = _voucherService.GetAll().FirstOrDefault(item => item != null && item.Id == voucherId);
                    if (voucher == null)
                    {
                        ShowError("The selected voucher could not be found.");
                        BindPage();
                        return;
                    }

                    _voucherService.SetActive(voucherId, !voucher.IsActive);
                }
                else if (string.Equals(e.CommandName, "Archive", StringComparison.OrdinalIgnoreCase))
                {
                    _voucherService.Archive(voucherId);
                }

                BindPage();
            }
            catch (InvalidOperationException ex)
            {
                ShowError(ex.Message);
                BindPage();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Voucher loyalty action failed: {0}", ex);
                ShowError("The voucher action could not be completed. Please refresh and try again.");
                BindPage();
            }
        }

        private void BindPage()
        {
            try
            {
                VoucherAdminMetrics metrics = _voucherService.GetMetrics();
                litActiveCount.Text = metrics.ActiveVoucherCount.ToString("N0", CultureInfo.InvariantCulture);
                litRedeemedCount.Text = metrics.RedeemedCount.ToString("N0", CultureInfo.InvariantCulture);
                litSavingsGiven.Text = CurrencyHelper.FormatMyr(metrics.RedeemedSavings);

                var vouchers = _voucherService.GetAll(txtSearch.Text, ddlStatusFilter.SelectedValue).ToList();
                rptVouchers.DataSource = vouchers;
                rptVouchers.DataBind();

                pnlEmptyState.Visible = vouchers.Count == 0;
                litEmptyStateText.Text = Server.HtmlEncode("No vouchers match the current filters.");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Voucher loyalty list load failed: {0}", ex);
                litActiveCount.Text = "0";
                litRedeemedCount.Text = "0";
                litSavingsGiven.Text = CurrencyHelper.FormatMyr(0m);
                rptVouchers.DataSource = Enumerable.Empty<Voucher>();
                rptVouchers.DataBind();
                pnlEmptyState.Visible = true;
                litEmptyStateText.Text = Server.HtmlEncode("The loyalty list is temporarily unavailable.");
                ShowError("The loyalty list is temporarily unavailable.");
            }
        }

        private void ShowError(string message)
        {
            lblMessage.Text = Server.HtmlEncode(message ?? "The voucher action could not be completed.");
            lblMessage.Visible = true;
        }

        public string GetDiscountText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return string.Empty;
            }

            if (string.Equals(voucher.DiscountType, VoucherDiscountTypes.Percentage, StringComparison.OrdinalIgnoreCase))
            {
                string text = voucher.DiscountValue.ToString("0.##", CultureInfo.InvariantCulture) + "% off";
                if (voucher.MaximumDiscountAmount.HasValue)
                {
                    text += " (cap " + CurrencyHelper.FormatMyr(voucher.MaximumDiscountAmount.Value) + ")";
                }

                return text;
            }

            return CurrencyHelper.FormatMyr(voucher.DiscountValue) + " off";
        }

        public string GetEligibilityText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return string.Empty;
            }

            if (voucher.AppliesToAllCategories || voucher.Categories == null || voucher.Categories.Count == 0)
            {
                return "All categories";
            }

            return string.Join(", ", voucher.Categories);
        }

        public string GetMinimumText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return string.Empty;
            }

            return voucher.MinimumPurchaseAmount > 0m
                ? CurrencyHelper.FormatMyr(voucher.MinimumPurchaseAmount)
                : "No minimum";
        }

        public string GetUsageText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return string.Empty;
            }

            return voucher.TotalUsageLimit.HasValue
                ? voucher.PendingAndRedeemedUses.ToString("N0", CultureInfo.InvariantCulture) + " / " + voucher.TotalUsageLimit.Value.ToString("N0", CultureInfo.InvariantCulture)
                : voucher.PendingAndRedeemedUses.ToString("N0", CultureInfo.InvariantCulture) + " used";
        }

        public string GetValidityText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return string.Empty;
            }

            return voucher.ValidFrom.UtcDateTime.ToString("dd MMM yyyy", CultureInfo.InvariantCulture)
                + " - "
                + voucher.ExpiresAt.UtcDateTime.ToString("dd MMM yyyy", CultureInfo.InvariantCulture);
        }

        public string GetStatusKey(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return "paused";
            }

            return VoucherService.GetStatusKey(voucher, DateTimeOffset.UtcNow);
        }

        public string GetStatusText(object dataItem)
        {
            string statusKey = GetStatusKey(dataItem);
            return char.ToUpperInvariant(statusKey[0]) + statusKey.Substring(1);
        }

        public string GetToggleText(object dataItem)
        {
            Voucher voucher = dataItem as Voucher;
            if (voucher == null)
            {
                return "Pause";
            }

            return voucher.IsActive ? "Pause" : "Resume";
        }
    }
}

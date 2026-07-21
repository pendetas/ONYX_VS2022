using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_voucher_form : Page
    {
        private readonly VoucherService _voucherService = new VoucherService();
        private const string EditIdViewStateKey = "VoucherEditId";
        private const string ApplicationTimeZoneId = "Singapore Standard Time";
        private static readonly Regex MixedInvariantNumberPattern = new Regex(@"^[+-]?\d{1,3}(,\d{3})+(\.\d+)?$", RegexOptions.Compiled);
        private static readonly Regex InvariantThousandsPattern = new Regex(@"^[+-]?\d{1,3}(,\d{3})+$", RegexOptions.Compiled);
        private static readonly Regex InvariantCommaDecimalPattern = new Regex(@"^[+-]?\d+,\d+$", RegexOptions.Compiled);

        private long EditId
        {
            get { return ViewState[EditIdViewStateKey] == null ? 0L : (long)ViewState[EditIdViewStateKey]; }
            set { ViewState[EditIdViewStateKey] = value; }
        }

        private bool IsEditMode { get { return EditId > 0L; } }

        protected void Page_Init(object sender, EventArgs e)
        {
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
            AuthHelper.RequireAdmin(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadEditId();
            }

            ConfigurePageChrome();

            if (!IsPostBack)
            {
                BindCategories();
                if (IsEditMode)
                {
                    LoadVoucher(EditId);
                }
                else
                {
                    SeedDefaults();
                }
            }
            else
            {
                ApplyCategorySelectionState();

                if (IsEditMode)
                {
                    Voucher voucher = _voucherService.GetById(EditId);
                    if (voucher != null && voucher.HasRedemptions)
                    {
                        ApplyImmutableFieldLockdown();
                    }
                }
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            lblMessage.Visible = false;

            try
            {
                Voucher existingVoucher = null;
                if (IsEditMode)
                {
                    existingVoucher = _voucherService.GetById(EditId);
                    if (existingVoucher == null)
                    {
                        Response.Redirect("onyx_admin_promos.aspx", false);
                        Context.ApplicationInstance.CompleteRequest();
                        return;
                    }
                }

                decimal discountValue = ParseRequiredDecimal(txtDiscountValue.Text, "Enter a valid discount value.");
                decimal? maximumDiscount = ParseOptionalDecimal(txtMaximumDiscount.Text, "Enter a valid maximum discount amount.");
                decimal minimumPurchase = ParseRequiredDecimal(txtMinimumPurchase.Text, "Enter a valid minimum purchase amount.");
                DateTimeOffset validFrom = ParseRequiredDateTimeOffset(txtValidFrom.Text, "Enter a valid start date.");
                DateTimeOffset expiresAt = ParseRequiredDateTimeOffset(txtExpiresAt.Text, "Enter a valid expiry date.");
                int? totalLimit = ParseOptionalInt32(txtTotalLimit.Text, "Enter a valid total usage limit.");
                int perUserLimit = ParseRequiredInt32(txtPerUserLimit.Text, "Enter a valid per-customer limit.");

                var voucher = new Voucher
                {
                    Id = EditId,
                    Name = txtName.Text.Trim(),
                    Code = txtCode.Text,
                    DiscountType = ddlDiscountType.SelectedValue,
                    DiscountValue = discountValue,
                    MaximumDiscountAmount = maximumDiscount,
                    MinimumPurchaseAmount = minimumPurchase,
                    AppliesToAllCategories = chkAllCategories.Checked,
                    ValidFrom = validFrom,
                    ExpiresAt = expiresAt,
                    TotalUsageLimit = totalLimit,
                    PerUserUsageLimit = perUserLimit,
                    IsActive = chkIsActive.Checked,
                    TermsAndConditions = txtTerms.Text.Trim(),
                    Categories = cblCategories.Items.Cast<ListItem>().Where(item => item.Selected).Select(item => item.Value).ToList()
                };

                if (voucher.AppliesToAllCategories)
                {
                    voucher.Categories = new List<string>();
                }

                if (existingVoucher != null && existingVoucher.HasRedemptions)
                {
                    PreserveImmutableFields(existingVoucher, voucher);
                }

                if (IsEditMode)
                {
                    _voucherService.Update(voucher);
                }
                else
                {
                    _voucherService.Create(voucher, GetAdminUserId());
                }

                Response.Redirect("onyx_admin_promos.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }
            catch (InvalidOperationException ex)
            {
                System.Diagnostics.Trace.TraceError("Admin voucher save failed: {0}", ex);
                ShowMessage(ex.Message, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin voucher save failed: {0}", ex);
                ShowMessage("The voucher could not be saved. Please review the values and try again.", true);
            }
        }

        private void BindCategories()
        {
            cblCategories.DataSource = _voucherService.GetAvailableCategories();
            cblCategories.DataBind();
        }

        private void LoadEditId()
        {
            long id;
            if (long.TryParse(Request.QueryString["id"], NumberStyles.Integer, CultureInfo.InvariantCulture, out id) && id > 0)
            {
                EditId = id;
            }
        }

        private void ConfigurePageChrome()
        {
            litPageTitle.Text = IsEditMode ? "Edit Voucher" : "Create Voucher";
            litPageSubtitle.Text = "Voucher Details for secure create and edit management.";
            btnSave.Text = IsEditMode ? "Save changes" : "Create voucher";
        }

        private void SeedDefaults()
        {
            DateTimeOffset now = TimeZoneInfo.ConvertTime(DateTimeOffset.UtcNow, GetApplicationTimeZone());
            txtValidFrom.Text = ToDateTimeLocalValue(now);
            txtExpiresAt.Text = ToDateTimeLocalValue(now.AddDays(7));
            chkAllCategories.Checked = true;
            chkIsActive.Checked = true;
            txtMinimumPurchase.Text = "0";
            txtPerUserLimit.Text = "1";
            ApplyCategorySelectionState();
        }

        private void LoadVoucher(long id)
        {
            Voucher voucher = _voucherService.GetById(id);
            if (voucher == null)
            {
                Response.Redirect("onyx_admin_promos.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            txtName.Text = voucher.Name ?? string.Empty;
            txtCode.Text = voucher.Code ?? string.Empty;

            if (ddlDiscountType.Items.FindByValue(voucher.DiscountType) != null)
            {
                ddlDiscountType.SelectedValue = voucher.DiscountType;
            }

            txtDiscountValue.Text = voucher.DiscountValue.ToString("0.##", CultureInfo.InvariantCulture);
            txtMaximumDiscount.Text = voucher.MaximumDiscountAmount.HasValue
                ? voucher.MaximumDiscountAmount.Value.ToString("0.##", CultureInfo.InvariantCulture)
                : string.Empty;
            txtMinimumPurchase.Text = voucher.MinimumPurchaseAmount.ToString("0.##", CultureInfo.InvariantCulture);
            chkAllCategories.Checked = voucher.AppliesToAllCategories;
            txtValidFrom.Text = ToDateTimeLocalValue(voucher.ValidFrom);
            txtExpiresAt.Text = ToDateTimeLocalValue(voucher.ExpiresAt);
            txtTotalLimit.Text = voucher.TotalUsageLimit.HasValue
                ? voucher.TotalUsageLimit.Value.ToString(CultureInfo.InvariantCulture)
                : string.Empty;
            txtPerUserLimit.Text = voucher.PerUserUsageLimit.ToString(CultureInfo.InvariantCulture);
            chkIsActive.Checked = voucher.IsActive;
            txtTerms.Text = voucher.TermsAndConditions ?? string.Empty;

            if (!voucher.AppliesToAllCategories)
            {
                foreach (ListItem item in cblCategories.Items)
                {
                    item.Selected = voucher.Categories != null
                        && voucher.Categories.Any(category => string.Equals(category, item.Value, StringComparison.OrdinalIgnoreCase));
                }
            }

            ApplyCategorySelectionState();

            if (voucher.HasRedemptions)
            {
                ApplyImmutableFieldLockdown();
            }
        }

        private void ApplyCategorySelectionState()
        {
            bool allowSpecificCategories = !chkAllCategories.Checked && chkAllCategories.Enabled;
            cblCategories.Enabled = allowSpecificCategories;

            foreach (ListItem item in cblCategories.Items)
            {
                item.Enabled = allowSpecificCategories;
            }

            string cssClass = "category-grid";
            if (!allowSpecificCategories)
            {
                cssClass += " disabled";
            }

            cblCategories.CssClass = cssClass;
        }

        private void ApplyImmutableFieldLockdown()
        {
            pnlRedemptionLock.Visible = true;
            txtCode.ReadOnly = true;
            txtDiscountValue.ReadOnly = true;
            txtMaximumDiscount.ReadOnly = true;
            txtMinimumPurchase.ReadOnly = true;
            txtValidFrom.ReadOnly = true;
            ddlDiscountType.Enabled = false;
            chkAllCategories.Enabled = false;
            ApplyCategorySelectionState();
        }

        private static void PreserveImmutableFields(Voucher existingVoucher, Voucher updatedVoucher)
        {
            updatedVoucher.Code = existingVoucher.Code;
            updatedVoucher.DiscountType = existingVoucher.DiscountType;
            updatedVoucher.DiscountValue = existingVoucher.DiscountValue;
            updatedVoucher.MaximumDiscountAmount = existingVoucher.MaximumDiscountAmount;
            updatedVoucher.MinimumPurchaseAmount = existingVoucher.MinimumPurchaseAmount;
            updatedVoucher.ValidFrom = existingVoucher.ValidFrom;
            updatedVoucher.AppliesToAllCategories = existingVoucher.AppliesToAllCategories;
            updatedVoucher.Categories = existingVoucher.Categories == null
                ? new List<string>()
                : existingVoucher.Categories.ToList();
        }

        private decimal ParseRequiredDecimal(string rawValue, string errorMessage)
        {
            decimal parsedValue;
            if (!TryParseInvariantDecimal(rawValue, out parsedValue))
            {
                throw new InvalidOperationException(errorMessage);
            }

            return parsedValue;
        }

        private decimal? ParseOptionalDecimal(string rawValue, string errorMessage)
        {
            if (string.IsNullOrWhiteSpace(rawValue))
            {
                return null;
            }

            return ParseRequiredDecimal(rawValue, errorMessage);
        }

        private int ParseRequiredInt32(string rawValue, string errorMessage)
        {
            int parsedValue;
            if (!int.TryParse(rawValue == null ? string.Empty : rawValue.Trim(), NumberStyles.Integer, CultureInfo.InvariantCulture, out parsedValue))
            {
                throw new InvalidOperationException(errorMessage);
            }

            return parsedValue;
        }

        private int? ParseOptionalInt32(string rawValue, string errorMessage)
        {
            if (string.IsNullOrWhiteSpace(rawValue))
            {
                return null;
            }

            return ParseRequiredInt32(rawValue, errorMessage);
        }

        private DateTimeOffset ParseRequiredDateTimeOffset(string rawValue, string errorMessage)
        {
            DateTime localDateTime;
            if (!DateTime.TryParseExact(
                rawValue == null ? string.Empty : rawValue.Trim(),
                new[] { "yyyy-MM-ddTHH:mm", "yyyy-MM-ddTHH:mm:ss" },
                CultureInfo.InvariantCulture,
                DateTimeStyles.None,
                out localDateTime))
            {
                throw new InvalidOperationException(errorMessage);
            }

            localDateTime = DateTime.SpecifyKind(localDateTime, DateTimeKind.Unspecified);
            TimeZoneInfo applicationTimeZone = GetApplicationTimeZone();
            TimeSpan offset = applicationTimeZone.GetUtcOffset(localDateTime);
            return new DateTimeOffset(localDateTime, offset).ToUniversalTime();
        }

        private long? GetAdminUserId()
        {
            object rawUserId = Session["UserId"];
            if (rawUserId == null)
            {
                return null;
            }

            long parsedUserId;
            return long.TryParse(Convert.ToString(rawUserId, CultureInfo.InvariantCulture), NumberStyles.Integer, CultureInfo.InvariantCulture, out parsedUserId)
                ? (long?)parsedUserId
                : null;
        }

        private void ShowMessage(string message, bool isError)
        {
            lblMessage.Text = Server.HtmlEncode(message ?? "The voucher form could not be processed.");
            lblMessage.CssClass = isError ? "message-banner" : "message-banner success";
            lblMessage.Visible = true;
        }

        private static bool TryParseInvariantDecimal(string rawValue, out decimal parsedValue)
        {
            parsedValue = 0m;

            string normalized;
            if (!TryNormalizeInvariantNumericInput(rawValue, out normalized))
            {
                return false;
            }

            return decimal.TryParse(normalized, NumberStyles.Number, CultureInfo.InvariantCulture, out parsedValue);
        }

        private static bool TryNormalizeInvariantNumericInput(string rawValue, out string normalized)
        {
            normalized = rawValue == null ? string.Empty : rawValue.Trim();
            if (string.IsNullOrWhiteSpace(normalized))
            {
                return false;
            }

            bool containsComma = normalized.IndexOf(',') >= 0;
            bool containsDot = normalized.IndexOf('.') >= 0;

            if (containsComma && containsDot)
            {
                if (!MixedInvariantNumberPattern.IsMatch(normalized))
                {
                    return false;
                }

                normalized = normalized.Replace(",", string.Empty);
                return true;
            }

            if (containsComma)
            {
                if (InvariantThousandsPattern.IsMatch(normalized))
                {
                    return true;
                }

                if (InvariantCommaDecimalPattern.IsMatch(normalized))
                {
                    normalized = normalized.Replace(',', '.');
                    return true;
                }

                return false;
            }

            return true;
        }

        private static string ToDateTimeLocalValue(DateTimeOffset value)
        {
            DateTime localDateTime = TimeZoneInfo.ConvertTime(value, GetApplicationTimeZone()).DateTime;
            return localDateTime.ToString("yyyy-MM-ddTHH:mm", CultureInfo.InvariantCulture);
        }

        private static TimeZoneInfo GetApplicationTimeZone()
        {
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById(ApplicationTimeZoneId);
            }
            catch (TimeZoneNotFoundException)
            {
                return TimeZoneInfo.Local;
            }
            catch (InvalidTimeZoneException)
            {
                return TimeZoneInfo.Local;
            }
        }
    }
}

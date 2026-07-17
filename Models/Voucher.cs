using System;
using System.Collections.Generic;

namespace ONYX_DDAC.Models
{
    public static class VoucherDiscountTypes
    {
        public const string Percentage = "percentage";
        public const string Fixed = "fixed";
    }

    public static class VoucherRedemptionStatuses
    {
        public const string Pending = "pending";
        public const string Redeemed = "redeemed";
        public const string Released = "released";
    }

    public class Voucher
    {
        public Voucher()
        {
            Categories = new List<string>();
            PerUserUsageLimit = 1;
            IsActive = true;
            AppliesToAllCategories = true;
        }

        public long Id { get; set; }

        public string Name { get; set; }

        public string Code { get; set; }

        public string DiscountType { get; set; }

        public decimal DiscountValue { get; set; }

        public decimal? MaximumDiscountAmount { get; set; }

        public decimal MinimumPurchaseAmount { get; set; }

        public bool AppliesToAllCategories { get; set; }

        public IList<string> Categories { get; set; }

        public DateTimeOffset ValidFrom { get; set; }

        public DateTimeOffset ExpiresAt { get; set; }

        public int? TotalUsageLimit { get; set; }

        public int PerUserUsageLimit { get; set; }

        public bool IsActive { get; set; }

        public string TermsAndConditions { get; set; }

        public DateTimeOffset? ArchivedAt { get; set; }

        public int PendingAndRedeemedUses { get; set; }

        public int RedeemedUses { get; set; }

        public decimal RedeemedSavings { get; set; }

        public bool HasRedemptions { get; set; }
    }
}

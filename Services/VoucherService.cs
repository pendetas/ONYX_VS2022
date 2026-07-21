using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class VoucherService
    {
        private readonly VoucherRepository _repository;

        public VoucherService()
        {
            _repository = new VoucherRepository();
        }

        public IList<Voucher> GetAll() { return _repository.GetAll(); }

        public IList<Voucher> GetAll(string searchTerm, string statusFilter)
        {
            IEnumerable<Voucher> vouchers = _repository.GetAll() ?? new List<Voucher>();
            string normalizedSearch = (searchTerm ?? string.Empty).Trim();
            if (!string.IsNullOrWhiteSpace(normalizedSearch))
            {
                vouchers = vouchers.Where(voucher =>
                    (!string.IsNullOrWhiteSpace(voucher.Name) &&
                     voucher.Name.IndexOf(normalizedSearch, StringComparison.OrdinalIgnoreCase) >= 0) ||
                    (!string.IsNullOrWhiteSpace(voucher.Code) &&
                     voucher.Code.IndexOf(normalizedSearch, StringComparison.OrdinalIgnoreCase) >= 0));
            }

            string normalizedStatus = NormalizeStatusFilter(statusFilter);
            if (!string.Equals(normalizedStatus, "all", StringComparison.Ordinal))
            {
                DateTimeOffset now = DateTimeOffset.UtcNow;
                vouchers = vouchers.Where(voucher => string.Equals(
                    GetStatusKey(voucher, now),
                    normalizedStatus,
                    StringComparison.Ordinal));
            }

            return vouchers.ToList();
        }

        public Voucher GetById(long id) { return _repository.GetById(id); }

        public VoucherAdminMetrics GetMetrics() { return _repository.GetMetrics(DateTimeOffset.UtcNow); }

        public IList<string> GetAvailableCategories() { return _repository.GetAvailableCategories(); }

        public long Create(Voucher voucher, long? adminUserId)
        {
            ValidateForSave(voucher);
            voucher.Code = NormalizeCode(voucher.Code);
            return _repository.Create(voucher, adminUserId);
        }

        public void Update(Voucher voucher)
        {
            ValidateForSave(voucher);
            voucher.Code = NormalizeCode(voucher.Code);
            _repository.Update(voucher);
        }

        public void SetActive(long id, bool active) { _repository.SetActive(id, active); }

        public void Archive(long id) { _repository.Archive(id); }

        public VoucherQuote GetCheckoutQuote(long userId, string code, IEnumerable<CartItem> items)
        {
            if (userId <= 0) throw new VoucherValidationException("Sign in to use a voucher.");
            Voucher voucher = _repository.GetByCode(NormalizeCode(code));
            var lines = (items ?? Enumerable.Empty<CartItem>()).Select(item => new VoucherCartLine
            {
                Category = item.Category,
                UnitPrice = item.Price,
                Quantity = item.Quantity
            });
            return VoucherCalculator.Calculate(
                voucher,
                lines,
                DateTimeOffset.UtcNow,
                voucher == null ? 0 : _repository.CountTotalActiveUses(voucher.Id),
                voucher == null ? 0 : _repository.CountUserActiveUses(voucher.Id, userId));
        }

        public static string NormalizeCode(string code)
        {
            return (code ?? string.Empty).Trim().ToUpper(CultureInfo.InvariantCulture);
        }

        public static void ValidateForSave(Voucher voucher)
        {
            if (voucher == null) throw new InvalidOperationException("Voucher details are required.");
            string normalizedCode = NormalizeCode(voucher.Code);
            if (string.IsNullOrWhiteSpace(voucher.Name) || voucher.Name.Trim().Length > 120) throw new InvalidOperationException("Voucher name must be between 1 and 120 characters.");
            if (!System.Text.RegularExpressions.Regex.IsMatch(normalizedCode, "^[A-Z0-9_-]{3,40}$")) throw new InvalidOperationException("Voucher code must be 3 to 40 letters, numbers, underscores, or hyphens.");
            if (voucher.DiscountType != VoucherDiscountTypes.Percentage && voucher.DiscountType != VoucherDiscountTypes.Fixed) throw new InvalidOperationException("Select a valid discount type.");
            if (voucher.DiscountValue <= 0) throw new InvalidOperationException("Discount value must be greater than zero.");
            if (voucher.DiscountType == VoucherDiscountTypes.Percentage && voucher.DiscountValue > 100) throw new InvalidOperationException("Percentage discount cannot exceed 100%.");
            if (voucher.DiscountType == VoucherDiscountTypes.Fixed && voucher.MaximumDiscountAmount.HasValue) throw new InvalidOperationException("Fixed vouchers cannot have a maximum discount cap.");
            if (voucher.MaximumDiscountAmount.HasValue && voucher.MaximumDiscountAmount.Value <= 0) throw new InvalidOperationException("Maximum discount must be greater than zero.");
            if (voucher.MinimumPurchaseAmount < 0) throw new InvalidOperationException("Minimum purchase cannot be negative.");
            if (voucher.ExpiresAt <= voucher.ValidFrom) throw new InvalidOperationException("Expiry must be later than the valid-from date.");
            if (!voucher.AppliesToAllCategories && (voucher.Categories == null || voucher.Categories.Count == 0)) throw new InvalidOperationException("Select at least one eligible category.");
            if (voucher.TotalUsageLimit.HasValue && voucher.TotalUsageLimit.Value <= 0) throw new InvalidOperationException("Total usage limit must be greater than zero.");
            if (voucher.PerUserUsageLimit <= 0) throw new InvalidOperationException("Per-customer limit must be at least one.");
            if (string.IsNullOrWhiteSpace(voucher.TermsAndConditions)) throw new InvalidOperationException("Terms and conditions are required.");
            if (voucher.TermsAndConditions.Length > 8000) throw new InvalidOperationException("Terms and conditions cannot exceed 8000 characters.");
        }

        public static string GetStatusKey(Voucher voucher, DateTimeOffset now)
        {
            if (voucher == null)
            {
                return "paused";
            }

            if (voucher.ArchivedAt.HasValue)
            {
                return "archived";
            }

            if (voucher.ExpiresAt <= now)
            {
                return "expired";
            }

            if (voucher.TotalUsageLimit.HasValue && voucher.PendingAndRedeemedUses >= voucher.TotalUsageLimit.Value)
            {
                return "exhausted";
            }

            if (!voucher.IsActive)
            {
                return "paused";
            }

            if (voucher.ValidFrom > now)
            {
                return "upcoming";
            }

            return "active";
        }

        private static string NormalizeStatusFilter(string statusFilter)
        {
            string value = (statusFilter ?? string.Empty).Trim().ToLowerInvariant();
            switch (value)
            {
                case "active":
                case "upcoming":
                case "paused":
                case "expired":
                case "exhausted":
                case "archived":
                    return value;
                default:
                    return "all";
            }
        }
    }
}

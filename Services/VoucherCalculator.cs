using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class VoucherValidationException : InvalidOperationException
    {
        public VoucherValidationException(string message) : base(message)
        {
        }
    }

    public static class VoucherCalculator
    {
        public static VoucherQuote Calculate(
            Voucher voucher,
            IEnumerable<VoucherCartLine> cartLines,
            DateTimeOffset now,
            int totalUsed,
            int userUsed)
        {
            if (voucher == null || voucher.ArchivedAt.HasValue)
            {
                throw new VoucherValidationException("This voucher code is invalid.");
            }

            if (!voucher.IsActive)
            {
                throw new VoucherValidationException("This voucher is currently paused.");
            }

            if (now < voucher.ValidFrom)
            {
                throw new VoucherValidationException("This voucher is not active yet.");
            }

            if (now >= voucher.ExpiresAt)
            {
                throw new VoucherValidationException("This voucher has expired.");
            }

            if (voucher.TotalUsageLimit.HasValue && totalUsed >= voucher.TotalUsageLimit.Value)
            {
                throw new VoucherValidationException("This voucher has reached its usage limit.");
            }

            if (userUsed >= voucher.PerUserUsageLimit)
            {
                throw new VoucherValidationException("You have already used this voucher.");
            }

            List<VoucherCartLine> lines = (cartLines ?? Enumerable.Empty<VoucherCartLine>()).ToList();
            if (lines.Count == 0)
            {
                throw new VoucherValidationException("Your cart is empty.");
            }

            if (lines.Any(line => line == null || line.Quantity <= 0 || line.UnitPrice < 0m))
            {
                throw new VoucherValidationException("Your cart contains an invalid item.");
            }

            decimal subtotal = lines.Sum(line => line.UnitPrice * line.Quantity);
            if (subtotal < voucher.MinimumPurchaseAmount)
            {
                throw new VoucherValidationException("Your cart does not meet this voucher's minimum purchase.");
            }

            HashSet<string> categories = new HashSet<string>(
                (voucher.Categories ?? Enumerable.Empty<string>()).Where(category => !string.IsNullOrWhiteSpace(category)),
                StringComparer.OrdinalIgnoreCase);

            decimal eligibleSubtotal = lines
                .Where(line => voucher.AppliesToAllCategories || categories.Contains(line.Category ?? string.Empty))
                .Sum(line => line.UnitPrice * line.Quantity);

            if (eligibleSubtotal <= 0m)
            {
                throw new VoucherValidationException("Your cart has no products eligible for this voucher.");
            }

            decimal discount;
            if (string.Equals(voucher.DiscountType, VoucherDiscountTypes.Percentage, StringComparison.Ordinal))
            {
                discount = RoundMoney(eligibleSubtotal * voucher.DiscountValue / 100m);
                if (voucher.MaximumDiscountAmount.HasValue)
                {
                    discount = Math.Min(discount, voucher.MaximumDiscountAmount.Value);
                }
            }
            else if (string.Equals(voucher.DiscountType, VoucherDiscountTypes.Fixed, StringComparison.Ordinal))
            {
                discount = voucher.DiscountValue;
            }
            else
            {
                throw new VoucherValidationException("This voucher has an invalid discount type.");
            }

            discount = Math.Min(Math.Max(RoundMoney(discount), 0m), eligibleSubtotal);

            return new VoucherQuote
            {
                VoucherId = voucher.Id,
                Code = voucher.Code,
                Name = voucher.Name,
                TermsAndConditions = voucher.TermsAndConditions,
                Subtotal = subtotal,
                EligibleSubtotal = eligibleSubtotal,
                DiscountAmount = discount,
                TotalAmount = subtotal - discount
            };
        }

        private static decimal RoundMoney(decimal value)
        {
            return Math.Round(value, 2, MidpointRounding.AwayFromZero);
        }
    }
}

using System;
using System.Collections.Generic;
using System.Data.Common;
using System.Linq;
using Npgsql;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.DAL
{
    public class VoucherRepository
    {
        public IList<Voucher> GetAll()
        {
            var vouchers = new List<Voucher>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            v.id,
                            v.name,
                            v.code,
                            v.discount_type,
                            v.discount_value,
                            v.maximum_discount_amount,
                            v.minimum_purchase_amount,
                            v.applies_to_all_categories,
                            v.valid_from,
                            v.expires_at,
                            v.total_usage_limit,
                            v.per_user_usage_limit,
                            v.is_active,
                            v.terms_and_conditions,
                            v.archived_at,
                            COALESCE(active_usage.active_count, 0) AS pending_and_redeemed_uses,
                            COALESCE(redeemed_usage.redeemed_count, 0) AS redeemed_uses,
                            COALESCE(redeemed_usage.redeemed_savings, 0) AS redeemed_savings,
                            EXISTS (
                                SELECT 1
                                FROM voucher_redemptions vr_any
                                WHERE vr_any.voucher_id = v.id
                            ) AS has_redemptions
                        FROM vouchers v
                        LEFT JOIN (
                            SELECT voucher_id, COUNT(*) AS active_count
                            FROM voucher_redemptions
                            WHERE status IN (@PendingStatus, @RedeemedStatus)
                            GROUP BY voucher_id
                        ) active_usage ON active_usage.voucher_id = v.id
                        LEFT JOIN (
                            SELECT
                                voucher_id,
                                COUNT(*) AS redeemed_count,
                                COALESCE(SUM(discount_amount), 0) AS redeemed_savings
                            FROM voucher_redemptions
                            WHERE status = @RedeemedStatus
                            GROUP BY voucher_id
                        ) redeemed_usage ON redeemed_usage.voucher_id = v.id
                        ORDER BY
                            CASE WHEN v.archived_at IS NULL THEN 0 ELSE 1 END,
                            v.created_at DESC,
                            v.id DESC";
                    cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                    cmd.Parameters.Add(new NpgsqlParameter("@RedeemedStatus", VoucherRedemptionStatuses.Redeemed));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            vouchers.Add(ReadVoucher(reader));
                        }
                    }
                }

                HydrateCategories(conn, null, vouchers);
            }

            return vouchers;
        }

        public Voucher GetById(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                return LoadVoucherById(conn, null, id, false);
            }
        }

        public Voucher GetByCode(string normalizedCode)
        {
            if (string.IsNullOrWhiteSpace(normalizedCode))
            {
                return null;
            }

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                return LoadVoucherByCode(conn, null, normalizedCode, false);
            }
        }

        public VoucherAdminMetrics GetMetrics(DateTimeOffset now)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT
                            COALESCE(SUM(
                                CASE
                                    WHEN v.archived_at IS NULL
                                     AND v.is_active = TRUE
                                     AND v.valid_from <= @Now
                                     AND v.expires_at > @Now
                                     AND (v.total_usage_limit IS NULL OR COALESCE(active_usage.active_count, 0) < v.total_usage_limit)
                                    THEN 1
                                    ELSE 0
                                END
                            ), 0) AS active_voucher_count,
                            COALESCE(SUM(COALESCE(redeemed_usage.redeemed_count, 0)), 0) AS redeemed_count,
                            COALESCE(SUM(COALESCE(redeemed_usage.redeemed_savings, 0)), 0) AS redeemed_savings
                        FROM vouchers v
                        LEFT JOIN (
                            SELECT voucher_id, COUNT(*) AS active_count
                            FROM voucher_redemptions
                            WHERE status IN (@PendingStatus, @RedeemedStatus)
                            GROUP BY voucher_id
                        ) active_usage ON active_usage.voucher_id = v.id
                        LEFT JOIN (
                            SELECT
                                voucher_id,
                                COUNT(*) AS redeemed_count,
                                COALESCE(SUM(discount_amount), 0) AS redeemed_savings
                            FROM voucher_redemptions
                            WHERE status = @RedeemedStatus
                            GROUP BY voucher_id
                        ) redeemed_usage ON redeemed_usage.voucher_id = v.id";
                    cmd.Parameters.Add(new NpgsqlParameter("@Now", now));
                    cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                    cmd.Parameters.Add(new NpgsqlParameter("@RedeemedStatus", VoucherRedemptionStatuses.Redeemed));

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        if (!reader.Read())
                        {
                            return new VoucherAdminMetrics();
                        }

                        return new VoucherAdminMetrics
                        {
                            ActiveVoucherCount = ReadInt32(reader, "active_voucher_count"),
                            RedeemedCount = ReadInt32(reader, "redeemed_count"),
                            RedeemedSavings = reader.GetDecimal(reader.GetOrdinal("redeemed_savings"))
                        };
                    }
                }
            }
        }

        public IList<string> GetAvailableCategories()
        {
            var categories = new List<string>();

            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        SELECT DISTINCT category
                        FROM products
                        WHERE category IS NOT NULL
                          AND btrim(category) <> ''
                        ORDER BY category";

                    using (DbDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            categories.Add(reader.GetString(0));
                        }
                    }
                }
            }

            return categories;
        }

        public long Create(Voucher voucher, long? adminUserId)
        {
            if (voucher == null)
            {
                throw new InvalidOperationException("Voucher details are required.");
            }

            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
                {
                    conn.Open();
                    using (DbTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            long id;
                            using (DbCommand cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    INSERT INTO vouchers
                                        (name, code, discount_type, discount_value, maximum_discount_amount, minimum_purchase_amount,
                                         applies_to_all_categories, valid_from, expires_at, total_usage_limit, per_user_usage_limit,
                                         is_active, terms_and_conditions, created_by_user_id)
                                    VALUES
                                        (@Name, @Code, @DiscountType, @DiscountValue, @MaximumDiscountAmount, @MinimumPurchaseAmount,
                                         @AppliesToAllCategories, @ValidFrom, @ExpiresAt, @TotalUsageLimit, @PerUserUsageLimit,
                                         @IsActive, @TermsAndConditions, @CreatedByUserId)
                                    RETURNING id";
                                AddVoucherParameters(cmd, voucher, adminUserId);
                                id = Convert.ToInt64(cmd.ExecuteScalar());
                            }

                            SaveCategories(conn, tx, id, voucher);
                            tx.Commit();
                            return id;
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (PostgresException exception) when (exception.SqlState == PostgresErrorCodes.UniqueViolation)
            {
                throw new InvalidOperationException("Voucher code already exists.");
            }
        }

        public void Update(Voucher voucher)
        {
            if (voucher == null)
            {
                throw new InvalidOperationException("Voucher details are required.");
            }

            try
            {
                using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
                {
                    conn.Open();
                    using (DbTransaction tx = conn.BeginTransaction())
                    {
                        try
                        {
                            Voucher existing = LoadVoucherById(conn, tx, voucher.Id, true);
                            if (existing == null)
                            {
                                throw new InvalidOperationException("Voucher could not be found.");
                            }

                            if (HasAnyRedemptions(conn, tx, voucher.Id))
                            {
                                EnsureRedemptionSafeUpdate(existing, voucher);
                            }

                            using (DbCommand cmd = conn.CreateCommand())
                            {
                                cmd.Transaction = tx;
                                cmd.CommandText = @"
                                    UPDATE vouchers
                                    SET name = @Name,
                                        code = @Code,
                                        discount_type = @DiscountType,
                                        discount_value = @DiscountValue,
                                        maximum_discount_amount = @MaximumDiscountAmount,
                                        minimum_purchase_amount = @MinimumPurchaseAmount,
                                        applies_to_all_categories = @AppliesToAllCategories,
                                        valid_from = @ValidFrom,
                                        expires_at = @ExpiresAt,
                                        total_usage_limit = @TotalUsageLimit,
                                        per_user_usage_limit = @PerUserUsageLimit,
                                        is_active = @IsActive,
                                        terms_and_conditions = @TermsAndConditions,
                                        updated_at = now()
                                    WHERE id = @Id";
                                AddVoucherParameters(cmd, voucher, null);
                                cmd.Parameters.Add(new NpgsqlParameter("@Id", voucher.Id));

                                if (cmd.ExecuteNonQuery() != 1)
                                {
                                    throw new InvalidOperationException("Voucher could not be updated.");
                                }
                            }

                            SaveCategories(conn, tx, voucher.Id, voucher);
                            tx.Commit();
                        }
                        catch
                        {
                            tx.Rollback();
                            throw;
                        }
                    }
                }
            }
            catch (PostgresException exception) when (exception.SqlState == PostgresErrorCodes.UniqueViolation)
            {
                throw new InvalidOperationException("Voucher code already exists.");
            }
        }

        public void SetActive(long id, bool isActive)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        UPDATE vouchers
                        SET is_active = @IsActive,
                            updated_at = now()
                        WHERE id = @Id";
                    cmd.Parameters.Add(new NpgsqlParameter("@Id", id));
                    cmd.Parameters.Add(new NpgsqlParameter("@IsActive", isActive));

                    if (cmd.ExecuteNonQuery() != 1)
                    {
                        throw new InvalidOperationException("Voucher could not be updated.");
                    }
                }
            }
        }

        public void Archive(long id)
        {
            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        Voucher existing = LoadVoucherById(conn, tx, id, true);
                        if (existing == null)
                        {
                            throw new InvalidOperationException("Voucher could not be found.");
                        }

                        if (HasPendingRedemption(conn, tx, id))
                        {
                            throw new InvalidOperationException("This voucher has a pending redemption and cannot be archived.");
                        }

                        using (DbCommand cmd = conn.CreateCommand())
                        {
                            cmd.Transaction = tx;
                            cmd.CommandText = @"
                                UPDATE vouchers
                                SET is_active = FALSE,
                                    archived_at = COALESCE(archived_at, now()),
                                    updated_at = now()
                                WHERE id = @Id";
                            cmd.Parameters.Add(new NpgsqlParameter("@Id", id));

                            if (cmd.ExecuteNonQuery() != 1)
                            {
                                throw new InvalidOperationException("Voucher could not be archived.");
                            }
                        }

                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        public int CountTotalActiveUses(long voucherId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                return CountTotalActiveUses(conn, null, voucherId);
            }
        }

        public int CountUserActiveUses(long voucherId, long userId)
        {
            using (DbConnection conn = DbConnectionFactory.CreateReadConnection())
            {
                conn.Open();
                return CountUserActiveUses(conn, null, voucherId, userId);
            }
        }

        internal static Voucher LockByCode(DbConnection conn, DbTransaction tx, string normalizedCode)
        {
            if (string.IsNullOrWhiteSpace(normalizedCode))
            {
                return null;
            }

            Voucher voucher = null;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT
                        v.id,
                        v.name,
                        v.code,
                        v.discount_type,
                        v.discount_value,
                        v.maximum_discount_amount,
                        v.minimum_purchase_amount,
                        v.applies_to_all_categories,
                        v.valid_from,
                        v.expires_at,
                        v.total_usage_limit,
                        v.per_user_usage_limit,
                        v.is_active,
                        v.terms_and_conditions,
                        v.archived_at,
                        0 AS pending_and_redeemed_uses,
                        0 AS redeemed_uses,
                        0::numeric AS redeemed_savings,
                        EXISTS (
                            SELECT 1
                            FROM voucher_redemptions vr_any
                            WHERE vr_any.voucher_id = v.id
                        ) AS has_redemptions
                    FROM vouchers v
                    WHERE LOWER(v.code) = LOWER(@Code)
                    LIMIT 1
                    FOR UPDATE";
                cmd.Parameters.Add(new NpgsqlParameter("@Code", normalizedCode));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        voucher = ReadVoucher(reader);
                    }
                }
            }

            if (voucher != null)
            {
                HydrateCategories(conn, tx, new[] { voucher });
            }

            return voucher;
        }

        internal static int CountTotalActiveUses(DbConnection conn, DbTransaction tx, long voucherId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT COUNT(*)
                    FROM voucher_redemptions
                    WHERE voucher_id = @VoucherId
                      AND status IN (@PendingStatus, @RedeemedStatus)";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                cmd.Parameters.Add(new NpgsqlParameter("@RedeemedStatus", VoucherRedemptionStatuses.Redeemed));
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        internal static int CountUserActiveUses(DbConnection conn, DbTransaction tx, long voucherId, long userId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT COUNT(*)
                    FROM voucher_redemptions
                    WHERE voucher_id = @VoucherId
                      AND user_id = @UserId
                      AND status IN (@PendingStatus, @RedeemedStatus)";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                cmd.Parameters.Add(new NpgsqlParameter("@RedeemedStatus", VoucherRedemptionStatuses.Redeemed));
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        internal static void ReserveRedemption(DbConnection conn, DbTransaction tx, long voucherId, long userId, long orderId, VoucherQuote quote)
        {
            if (quote == null || quote.VoucherId != voucherId || quote.DiscountAmount <= 0m)
            {
                throw new InvalidOperationException("A valid voucher quote is required to reserve redemption.");
            }

            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    INSERT INTO voucher_redemptions
                        (voucher_id, user_id, order_id, eligible_subtotal, discount_amount, status)
                    VALUES
                        (@VoucherId, @UserId, @OrderId, @EligibleSubtotal, @DiscountAmount, @PendingStatus)";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@EligibleSubtotal", quote.EligibleSubtotal));
                cmd.Parameters.Add(new NpgsqlParameter("@DiscountAmount", quote.DiscountAmount));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                cmd.ExecuteNonQuery();
            }
        }

        internal static void RedeemForOrder(DbConnection conn, DbTransaction tx, long orderId)
        {
            int affectedRows;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    UPDATE voucher_redemptions
                    SET status = @RedeemedStatus, redeemed_at = now(), released_at = NULL
                    WHERE order_id = @OrderId AND status = @PendingStatus;";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                cmd.Parameters.Add(new NpgsqlParameter("@RedeemedStatus", VoucherRedemptionStatuses.Redeemed));
                affectedRows = cmd.ExecuteNonQuery();
            }

            EnsureTerminalTransition(conn, tx, orderId, affectedRows, VoucherRedemptionStatuses.Pending, "redeem");
        }

        internal static void ReleaseForOrder(DbConnection conn, DbTransaction tx, long orderId)
        {
            int affectedRows;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    UPDATE voucher_redemptions
                    SET status = @ReleasedStatus, released_at = now()
                    WHERE order_id = @OrderId AND status = @PendingStatus;";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                cmd.Parameters.Add(new NpgsqlParameter("@ReleasedStatus", VoucherRedemptionStatuses.Released));
                affectedRows = cmd.ExecuteNonQuery();
            }

            EnsureTerminalTransition(conn, tx, orderId, affectedRows, VoucherRedemptionStatuses.Pending, "release");
        }

        private static Voucher LoadVoucherById(DbConnection conn, DbTransaction tx, long id, bool forUpdate)
        {
            Voucher voucher = null;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                if (forUpdate)
                {
                    cmd.CommandText = @"
                        SELECT
                            v.id,
                            v.name,
                            v.code,
                            v.discount_type,
                            v.discount_value,
                            v.maximum_discount_amount,
                            v.minimum_purchase_amount,
                            v.applies_to_all_categories,
                            v.valid_from,
                            v.expires_at,
                            v.total_usage_limit,
                            v.per_user_usage_limit,
                            v.is_active,
                            v.terms_and_conditions,
                            v.archived_at,
                            0 AS pending_and_redeemed_uses,
                            0 AS redeemed_uses,
                            0::numeric AS redeemed_savings,
                            EXISTS (
                                SELECT 1
                                FROM voucher_redemptions vr_any
                                WHERE vr_any.voucher_id = v.id
                            ) AS has_redemptions
                        FROM vouchers v
                        WHERE v.id = @Id
                        LIMIT 1
                        FOR UPDATE";
                }
                else
                {
                    cmd.CommandText = @"
                        SELECT
                            v.id,
                            v.name,
                            v.code,
                            v.discount_type,
                            v.discount_value,
                            v.maximum_discount_amount,
                            v.minimum_purchase_amount,
                            v.applies_to_all_categories,
                            v.valid_from,
                            v.expires_at,
                            v.total_usage_limit,
                            v.per_user_usage_limit,
                            v.is_active,
                            v.terms_and_conditions,
                            v.archived_at,
                            0 AS pending_and_redeemed_uses,
                            0 AS redeemed_uses,
                            0::numeric AS redeemed_savings,
                            EXISTS (
                                SELECT 1
                                FROM voucher_redemptions vr_any
                                WHERE vr_any.voucher_id = v.id
                            ) AS has_redemptions
                        FROM vouchers v
                        WHERE v.id = @Id
                        LIMIT 1";
                }

                cmd.Parameters.Add(new NpgsqlParameter("@Id", id));
                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        voucher = ReadVoucher(reader);
                    }
                }
            }

            if (voucher != null)
            {
                HydrateCategories(conn, tx, new[] { voucher });
            }

            return voucher;
        }

        private static Voucher LoadVoucherByCode(DbConnection conn, DbTransaction tx, string normalizedCode, bool forUpdate)
        {
            Voucher voucher = null;
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                if (forUpdate)
                {
                    cmd.CommandText = @"
                        SELECT
                            v.id,
                            v.name,
                            v.code,
                            v.discount_type,
                            v.discount_value,
                            v.maximum_discount_amount,
                            v.minimum_purchase_amount,
                            v.applies_to_all_categories,
                            v.valid_from,
                            v.expires_at,
                            v.total_usage_limit,
                            v.per_user_usage_limit,
                            v.is_active,
                            v.terms_and_conditions,
                            v.archived_at,
                            0 AS pending_and_redeemed_uses,
                            0 AS redeemed_uses,
                            0::numeric AS redeemed_savings,
                            EXISTS (
                                SELECT 1
                                FROM voucher_redemptions vr_any
                                WHERE vr_any.voucher_id = v.id
                            ) AS has_redemptions
                        FROM vouchers v
                        WHERE LOWER(v.code) = LOWER(@Code)
                        LIMIT 1
                        FOR UPDATE";
                }
                else
                {
                    cmd.CommandText = @"
                        SELECT
                            v.id,
                            v.name,
                            v.code,
                            v.discount_type,
                            v.discount_value,
                            v.maximum_discount_amount,
                            v.minimum_purchase_amount,
                            v.applies_to_all_categories,
                            v.valid_from,
                            v.expires_at,
                            v.total_usage_limit,
                            v.per_user_usage_limit,
                            v.is_active,
                            v.terms_and_conditions,
                            v.archived_at,
                            0 AS pending_and_redeemed_uses,
                            0 AS redeemed_uses,
                            0::numeric AS redeemed_savings,
                            EXISTS (
                                SELECT 1
                                FROM voucher_redemptions vr_any
                                WHERE vr_any.voucher_id = v.id
                            ) AS has_redemptions
                        FROM vouchers v
                        WHERE LOWER(v.code) = LOWER(@Code)
                        LIMIT 1";
                }

                cmd.Parameters.Add(new NpgsqlParameter("@Code", normalizedCode));
                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        voucher = ReadVoucher(reader);
                    }
                }
            }

            if (voucher != null)
            {
                HydrateCategories(conn, tx, new[] { voucher });
            }

            return voucher;
        }

        private static void AddVoucherParameters(DbCommand cmd, Voucher voucher, long? adminUserId)
        {
            cmd.Parameters.Add(new NpgsqlParameter("@Name", voucher.Name == null ? string.Empty : voucher.Name.Trim()));
            cmd.Parameters.Add(new NpgsqlParameter("@Code", voucher.Code));
            cmd.Parameters.Add(new NpgsqlParameter("@DiscountType", voucher.DiscountType));
            cmd.Parameters.Add(new NpgsqlParameter("@DiscountValue", voucher.DiscountValue));
            cmd.Parameters.Add(new NpgsqlParameter("@MaximumDiscountAmount", voucher.MaximumDiscountAmount.HasValue ? (object)voucher.MaximumDiscountAmount.Value : DBNull.Value));
            cmd.Parameters.Add(new NpgsqlParameter("@MinimumPurchaseAmount", voucher.MinimumPurchaseAmount));
            cmd.Parameters.Add(new NpgsqlParameter("@AppliesToAllCategories", voucher.AppliesToAllCategories));
            cmd.Parameters.Add(new NpgsqlParameter("@ValidFrom", voucher.ValidFrom));
            cmd.Parameters.Add(new NpgsqlParameter("@ExpiresAt", voucher.ExpiresAt));
            cmd.Parameters.Add(new NpgsqlParameter("@TotalUsageLimit", voucher.TotalUsageLimit.HasValue ? (object)voucher.TotalUsageLimit.Value : DBNull.Value));
            cmd.Parameters.Add(new NpgsqlParameter("@PerUserUsageLimit", voucher.PerUserUsageLimit));
            cmd.Parameters.Add(new NpgsqlParameter("@IsActive", voucher.IsActive));
            cmd.Parameters.Add(new NpgsqlParameter("@TermsAndConditions", voucher.TermsAndConditions));
            if (adminUserId.HasValue)
            {
                cmd.Parameters.Add(new NpgsqlParameter("@CreatedByUserId", adminUserId.Value));
            }
            else if (cmd.CommandText.Contains("@CreatedByUserId"))
            {
                cmd.Parameters.Add(new NpgsqlParameter("@CreatedByUserId", DBNull.Value));
            }
        }

        private static void SaveCategories(DbConnection conn, DbTransaction tx, long voucherId, Voucher voucher)
        {
            using (DbCommand delete = conn.CreateCommand())
            {
                delete.Transaction = tx;
                delete.CommandText = "DELETE FROM voucher_categories WHERE voucher_id = @VoucherId";
                delete.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                delete.ExecuteNonQuery();
            }

            if (voucher == null || voucher.AppliesToAllCategories)
            {
                return;
            }

            foreach (string category in NormalizeCategories(voucher))
            {
                using (DbCommand insert = conn.CreateCommand())
                {
                    insert.Transaction = tx;
                    insert.CommandText = @"
                        INSERT INTO voucher_categories (voucher_id, category)
                        VALUES (@VoucherId, @Category)";
                    insert.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                    insert.Parameters.Add(new NpgsqlParameter("@Category", category));
                    insert.ExecuteNonQuery();
                }
            }
        }

        private static void HydrateCategories(DbConnection conn, DbTransaction tx, IEnumerable<Voucher> vouchers)
        {
            List<Voucher> voucherList = (vouchers ?? Enumerable.Empty<Voucher>()).Where(voucher => voucher != null).ToList();
            if (voucherList.Count == 0)
            {
                return;
            }

            Dictionary<long, List<string>> categoriesByVoucherId = voucherList.ToDictionary(voucher => voucher.Id, voucher => new List<string>());
            long[] voucherIds = voucherList.Select(voucher => voucher.Id).Distinct().ToArray();
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT voucher_id, category
                    FROM voucher_categories
                    WHERE voucher_id = ANY(@VoucherIds)
                    ORDER BY voucher_id, category";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherIds", voucherIds));

                using (DbDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        long voucherId = reader.GetInt64(reader.GetOrdinal("voucher_id"));
                        if (!categoriesByVoucherId.ContainsKey(voucherId))
                        {
                            continue;
                        }

                        categoriesByVoucherId[voucherId].Add(reader.GetString(reader.GetOrdinal("category")));
                    }
                }
            }

            foreach (Voucher voucher in voucherList)
            {
                voucher.Categories = categoriesByVoucherId.ContainsKey(voucher.Id)
                    ? categoriesByVoucherId[voucher.Id]
                    : new List<string>();
            }
        }

        private static Voucher ReadVoucher(DbDataReader reader)
        {
            return new Voucher
            {
                Id = reader.GetInt64(reader.GetOrdinal("id")),
                Name = reader.GetString(reader.GetOrdinal("name")),
                Code = reader.GetString(reader.GetOrdinal("code")),
                DiscountType = reader.GetString(reader.GetOrdinal("discount_type")),
                DiscountValue = reader.GetDecimal(reader.GetOrdinal("discount_value")),
                MaximumDiscountAmount = ReadNullableDecimal(reader, "maximum_discount_amount"),
                MinimumPurchaseAmount = reader.GetDecimal(reader.GetOrdinal("minimum_purchase_amount")),
                AppliesToAllCategories = reader.GetBoolean(reader.GetOrdinal("applies_to_all_categories")),
                Categories = new List<string>(),
                ValidFrom = ReadDateTimeOffset(reader, "valid_from"),
                ExpiresAt = ReadDateTimeOffset(reader, "expires_at"),
                TotalUsageLimit = ReadNullableInt32(reader, "total_usage_limit"),
                PerUserUsageLimit = reader.GetInt32(reader.GetOrdinal("per_user_usage_limit")),
                IsActive = reader.GetBoolean(reader.GetOrdinal("is_active")),
                TermsAndConditions = reader.GetString(reader.GetOrdinal("terms_and_conditions")),
                ArchivedAt = ReadNullableDateTimeOffset(reader, "archived_at"),
                PendingAndRedeemedUses = ReadInt32(reader, "pending_and_redeemed_uses"),
                RedeemedUses = ReadInt32(reader, "redeemed_uses"),
                RedeemedSavings = reader.GetDecimal(reader.GetOrdinal("redeemed_savings")),
                HasRedemptions = reader.GetBoolean(reader.GetOrdinal("has_redemptions"))
            };
        }

        private static decimal? ReadNullableDecimal(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? (decimal?)null : reader.GetDecimal(ordinal);
        }

        private static int? ReadNullableInt32(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            return reader.IsDBNull(ordinal) ? (int?)null : reader.GetInt32(ordinal);
        }

        private static int ReadInt32(DbDataReader reader, string columnName)
        {
            return Convert.ToInt32(reader.GetValue(reader.GetOrdinal(columnName)));
        }

        private static DateTimeOffset? ReadNullableDateTimeOffset(DbDataReader reader, string columnName)
        {
            int ordinal = reader.GetOrdinal(columnName);
            if (reader.IsDBNull(ordinal))
            {
                return null;
            }

            return ReadDateTimeOffset(reader, columnName);
        }

        private static DateTimeOffset ReadDateTimeOffset(DbDataReader reader, string columnName)
        {
            object value = reader.GetValue(reader.GetOrdinal(columnName));
            if (value is DateTimeOffset)
            {
                return ((DateTimeOffset)value).ToUniversalTime();
            }

            DateTime dateTime = (DateTime)value;
            if (dateTime.Kind == DateTimeKind.Unspecified)
            {
                dateTime = DateTime.SpecifyKind(dateTime, DateTimeKind.Utc);
            }

            return new DateTimeOffset(dateTime).ToUniversalTime();
        }

        private static bool HasAnyRedemptions(DbConnection conn, DbTransaction tx, long voucherId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT EXISTS (
                        SELECT 1
                        FROM voucher_redemptions
                        WHERE voucher_id = @VoucherId
                    )";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                return Convert.ToBoolean(cmd.ExecuteScalar());
            }
        }

        private static bool HasPendingRedemption(DbConnection conn, DbTransaction tx, long voucherId)
        {
            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT EXISTS (
                        SELECT 1
                        FROM voucher_redemptions
                        WHERE voucher_id = @VoucherId
                          AND status = @PendingStatus
                    )";
                cmd.Parameters.Add(new NpgsqlParameter("@VoucherId", voucherId));
                cmd.Parameters.Add(new NpgsqlParameter("@PendingStatus", VoucherRedemptionStatuses.Pending));
                return Convert.ToBoolean(cmd.ExecuteScalar());
            }
        }

        private static void EnsureRedemptionSafeUpdate(Voucher existing, Voucher updated)
        {
            if (existing == null || updated == null)
            {
                throw new InvalidOperationException("Voucher details are required.");
            }

            bool changedImmutableCore =
                !string.Equals(existing.Code, updated.Code, StringComparison.Ordinal) ||
                !string.Equals(existing.DiscountType, updated.DiscountType, StringComparison.Ordinal) ||
                existing.DiscountValue != updated.DiscountValue ||
                existing.MaximumDiscountAmount != updated.MaximumDiscountAmount ||
                existing.MinimumPurchaseAmount != updated.MinimumPurchaseAmount ||
                existing.ValidFrom != updated.ValidFrom ||
                existing.AppliesToAllCategories != updated.AppliesToAllCategories ||
                !NormalizeCategories(existing).SequenceEqual(NormalizeCategories(updated), StringComparer.OrdinalIgnoreCase);

            if (changedImmutableCore)
            {
                throw new InvalidOperationException("Voucher discount rules cannot be changed after redemption has started.");
            }

            if (updated.ExpiresAt < existing.ExpiresAt)
            {
                throw new InvalidOperationException("Voucher expiry cannot be shortened after redemption has started.");
            }

            if (!IsEqualOrHigherLimit(existing.TotalUsageLimit, updated.TotalUsageLimit))
            {
                throw new InvalidOperationException("Total usage limit cannot be reduced after redemption has started.");
            }

            if (updated.PerUserUsageLimit < existing.PerUserUsageLimit)
            {
                throw new InvalidOperationException("Per-customer limit cannot be reduced after redemption has started.");
            }
        }

        private static bool IsEqualOrHigherLimit(int? currentLimit, int? updatedLimit)
        {
            if (!currentLimit.HasValue)
            {
                return !updatedLimit.HasValue;
            }

            if (!updatedLimit.HasValue)
            {
                return true;
            }

            return updatedLimit.Value >= currentLimit.Value;
        }

        private static IList<string> NormalizeCategories(Voucher voucher)
        {
            if (voucher == null || voucher.AppliesToAllCategories)
            {
                return new List<string>();
            }

            return (voucher.Categories ?? Enumerable.Empty<string>())
                .Where(category => !string.IsNullOrWhiteSpace(category))
                .Select(category => category.Trim())
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .OrderBy(category => category, StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        private static void EnsureTerminalTransition(DbConnection conn, DbTransaction tx, long orderId, int affectedRows, string expectedCurrentStatus, string action)
        {
            if (affectedRows == 1)
            {
                return;
            }

            if (affectedRows > 1)
            {
                throw new InvalidOperationException("Voucher redemption could not " + action + " cleanly.");
            }

            using (DbCommand cmd = conn.CreateCommand())
            {
                cmd.Transaction = tx;
                cmd.CommandText = @"
                    SELECT status
                    FROM voucher_redemptions
                    WHERE order_id = @OrderId";
                cmd.Parameters.Add(new NpgsqlParameter("@OrderId", orderId));
                object status = cmd.ExecuteScalar();
                if (status == null || status == DBNull.Value)
                {
                    return;
                }

                throw new InvalidOperationException(
                    "Voucher redemption must be " + expectedCurrentStatus + " before it can " + action + ".");
            }
        }
    }
}

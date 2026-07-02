using System;
using System.Data.Common;
using Npgsql;

namespace ONYX_DDAC.DAL
{
    public class ReviewRepository
    {
        public void SaveReview(long userId, long productId, short rating, string comment)
        {
            if (rating < 1 || rating > 5)
            {
                throw new ArgumentOutOfRangeException(nameof(rating), "Rating must be between 1 and 5.");
            }

            using (DbConnection conn = DbConnectionFactory.CreateDefaultConnection())
            {
                conn.Open();
                using (DbCommand cmd = conn.CreateCommand())
                {
                    cmd.CommandText = @"
                        INSERT INTO reviews (user_id, product_id, rating, comment)
                        VALUES (@UserId, @ProductId, @Rating, @Comment)
                        ON CONFLICT (user_id, product_id)
                        DO UPDATE SET
                            rating = EXCLUDED.rating,
                            comment = EXCLUDED.comment,
                            created_at = now()";
                    cmd.Parameters.Add(new NpgsqlParameter("@UserId", userId));
                    cmd.Parameters.Add(new NpgsqlParameter("@ProductId", productId));
                    cmd.Parameters.Add(new NpgsqlParameter("@Rating", rating));
                    cmd.Parameters.Add(new NpgsqlParameter("@Comment", string.IsNullOrWhiteSpace(comment) ? (object)DBNull.Value : comment));
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}

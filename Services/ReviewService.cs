using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class ReviewService
    {
        private readonly OrderRepository orderRepository;
        private readonly ReviewRepository reviewRepository;

        public ReviewService()
        {
            orderRepository = new OrderRepository();
            reviewRepository = new ReviewRepository();
        }

        public IList<Product> GetReviewableProducts(long userId)
        {
            return orderRepository.GetPurchasedProductsForUser(userId) ?? new List<Product>();
        }

        public ReviewSubmissionResult SaveReview(long userId, long productId, short rating, string comment)
        {
            if (productId <= 0)
            {
                return Failure("Choose a purchased product first.");
            }

            if (rating < 1 || rating > 5)
            {
                return Failure("Choose a rating from 1 to 5.");
            }

            if (!orderRepository.HasPurchasedProduct(userId, productId))
            {
                return Failure("Reviews are only available for purchased gear.");
            }

            string normalizedComment = (comment ?? string.Empty).Trim();
            if (normalizedComment.Length > 1200)
            {
                return Failure("Keep the review under 1200 characters.");
            }

            reviewRepository.SaveReview(userId, productId, rating, normalizedComment);
            return new ReviewSubmissionResult
            {
                Success = true,
                Message = "Review saved. Thanks for testing the gear."
            };
        }

        private static ReviewSubmissionResult Failure(string message)
        {
            return new ReviewSubmissionResult
            {
                Success = false,
                Message = message
            };
        }
    }
}

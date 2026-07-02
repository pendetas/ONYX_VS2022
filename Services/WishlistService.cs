using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class WishlistService
    {
        private readonly WishlistRepository wishlistRepository;
        private readonly CartService cartService;

        public WishlistService()
        {
            wishlistRepository = new WishlistRepository();
            cartService = new CartService();
        }

        public IList<Product> GetWishlistProducts(long userId)
        {
            return wishlistRepository.GetWishlistProducts(userId) ?? new List<Product>();
        }

        public ISet<long> GetWishlistProductIds(long userId)
        {
            return new HashSet<long>(GetWishlistProducts(userId).Select(product => product.Id));
        }

        public bool IsInWishlist(long userId, long productId)
        {
            ValidateWishlistRequest(userId, productId);
            return wishlistRepository.IsInWishlist(userId, productId);
        }

        public bool ToggleWishlistItem(long userId, long productId)
        {
            ValidateWishlistRequest(userId, productId);

            if (wishlistRepository.IsInWishlist(userId, productId))
            {
                wishlistRepository.RemoveWishlistItem(userId, productId);
                return false;
            }

            wishlistRepository.AddWishlistItem(userId, productId);
            return true;
        }

        public void RemoveWishlistItem(long userId, long productId)
        {
            ValidateWishlistRequest(userId, productId);
            wishlistRepository.RemoveWishlistItem(userId, productId);
        }

        public void MoveWishlistItemToCart(long userId, long productId)
        {
            ValidateWishlistRequest(userId, productId);
            cartService.AddToCart(productId, null, 1);
            wishlistRepository.RemoveWishlistItem(userId, productId);
        }

        private static void ValidateWishlistRequest(long userId, long productId)
        {
            if (userId <= 0)
            {
                throw new InvalidOperationException("Sign in before updating your wishlist.");
            }

            if (productId <= 0)
            {
                throw new InvalidOperationException("Choose a valid product first.");
            }
        }
    }
}

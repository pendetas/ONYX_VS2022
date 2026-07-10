using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ONYX_DDAC.Models;
using ONYX_DDAC.DAL;

namespace ONYX_DDAC.Services
{
    public class CartService
    {
        private const string CartSessionKey = "Cart";
        private const string CartUserIdSessionKey = "OnyxCartUserId";
        private readonly ProductRepository _productRepository;
        private readonly CartRepository _cartRepository;

        public CartService()
        {
            _productRepository = new ProductRepository();
            _cartRepository = new CartRepository();
        }

        // Retrieves the cart from Session, rehydrating from the temporary cart table for logged-in users.
        public List<CartItem> GetCartItems()
        {
            long? userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                var cachedCart = HttpContext.Current.Session[CartSessionKey] as List<CartItem>;
                if (cachedCart != null &&
                    TryGetSessionCartUserId(out long cachedUserId) &&
                    cachedUserId == userId.Value)
                {
                    return cachedCart;
                }

                List<CartItem> persistedCart = LoadPersistedCartForUser(userId.Value);
                StoreCartInSession(persistedCart, userId.Value);
                return persistedCart;
            }

            var cart = HttpContext.Current.Session[CartSessionKey] as List<CartItem>;
            if (cart == null)
            {
                cart = new List<CartItem>();
                StoreCartInSession(cart, null);
            }
            return cart;
        }

        // Counts UNIQUE items in the cart (for the navbar badge)
        public int GetCartItemCount()
        {
            return GetCartItems().Count;
        }

        // Adds an item or increases its quantity if it already exists
        public void AddToCart(long productId, long? variantId, int quantity)
        {
            long? userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                Product product = _productRepository.GetProductById(productId);
                if (product == null)
                {
                    return;
                }

                _cartRepository.UpsertCartItem(userId.Value, new CartItem
                {
                    ProductId = productId,
                    VariantId = variantId,
                    Quantity = quantity
                });
                RefreshCurrentUserCartFromDatabase();
                return;
            }

            var cart = GetCartItems();

            // Check if this exact product+variant is already in the cart
            var existingItem = cart.FirstOrDefault(i => i.ProductId == productId && i.VariantId == variantId);

            if (existingItem != null)
            {
                existingItem.Quantity += quantity;
            }
            else
            {
                // It's a new item, fetch details from DB
                Product product = _productRepository.GetProductById(productId);
                if (product == null) return;

                CartItem newItem = new CartItem
                {
                    ProductId = product.Id,
                    VariantId = variantId,
                    ProductName = product.Name,
                    Price = product.Price,
                    Quantity = quantity,
                    ImageUrl = product.ImageUrl
                };

                // If a variant was selected, override the base price/image/name
                if (variantId.HasValue)
                {
                    var variants = _productRepository.GetProductVariants(productId);
                    var selectedVariant = variants.FirstOrDefault(v => v.ProductVariantId == variantId.Value);

                    if (selectedVariant != null)
                    {
                        newItem.ProductName = $"{product.Name} ({selectedVariant.VariantValue})";
                        newItem.Price = selectedVariant.VariantPrice;
                        if (!string.IsNullOrWhiteSpace(selectedVariant.ImageUrl))
                        {
                            newItem.ImageUrl = selectedVariant.ImageUrl;
                        }
                    }
                }

                cart.Add(newItem);
            }

            // Save back to session
            StoreCartInSession(cart, null);
        }

        // Calculates the grand total of the cart
        public decimal CalculateTotal()
        {
            var cart = GetCartItems();
            return cart.Sum(item => item.Price * item.Quantity);
        }

        // Removes a specific item from the cart entirely
        public void RemoveFromCart(long productId, long? variantId)
        {
            long? userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                _cartRepository.RemoveCartItem(userId.Value, productId, variantId);
                RefreshCurrentUserCartFromDatabase();
                return;
            }

            var cart = GetCartItems();
            var itemToRemove = cart.FirstOrDefault(i => i.ProductId == productId && i.VariantId == variantId);

            if (itemToRemove != null)
            {
                cart.Remove(itemToRemove);
                StoreCartInSession(cart, null);
            }
        }

        // Updates the quantity of a specific item
        public void UpdateQuantity(long productId, long? variantId, int newQuantity)
        {
            if (newQuantity <= 0)
            {
                RemoveFromCart(productId, variantId);
                return;
            }

            long? userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                _cartRepository.SetCartItemQuantity(userId.Value, productId, variantId, newQuantity);
                RefreshCurrentUserCartFromDatabase();
                return;
            }

            var cart = GetCartItems();
            var item = cart.FirstOrDefault(i => i.ProductId == productId && i.VariantId == variantId);

            if (item != null)
            {
                item.Quantity = newQuantity;
                StoreCartInSession(cart, null);
            }
        }

        // Clears the temporary cart rows for the current user and resets the session cart.
        public void ClearCart()
        {
            long? userId = GetCurrentUserId();
            if (userId.HasValue)
            {
                _cartRepository.ClearCart(userId.Value);
            }

            StoreCartInSession(new List<CartItem>(), userId);
        }

        public void MergeSessionCartForUser(long userId, List<CartItem> sessionCart)
        {
            if (sessionCart == null || sessionCart.Count == 0)
            {
                StoreCartInSession(LoadPersistedCartForUser(userId), userId);
                return;
            }

            _cartRepository.MergeCartItems(userId, sessionCart);

            StoreCartInSession(LoadPersistedCartForUser(userId), userId);
        }

        public void PersistCartForCurrentUser()
        {
            long? userId = GetCurrentUserId();
            if (!userId.HasValue)
            {
                return;
            }

            // Logged-in carts are database-authoritative. Never rewrite them from
            // potentially stale session state.
            RefreshCurrentUserCartFromDatabase();
        }

        public List<CartItem> LoadPersistedCartForCurrentUser()
        {
            long? userId = GetCurrentUserId();
            return userId.HasValue
                ? LoadPersistedCartForUser(userId.Value)
                : new List<CartItem>();
        }

        public List<CartItem> RefreshCurrentUserCartFromDatabase()
        {
            long? userId = GetCurrentUserId();
            List<CartItem> cart = userId.HasValue
                ? LoadPersistedCartForUser(userId.Value)
                : new List<CartItem>();
            StoreCartInSession(cart, userId);
            return cart;
        }

        private List<CartItem> LoadPersistedCartForUser(long userId)
        {
            return _cartRepository.GetCartItems(userId).ToList();
        }

        private static void StoreCartInSession(List<CartItem> cart, long? userId)
        {
            HttpContext.Current.Session[CartSessionKey] = cart;
            if (userId.HasValue)
            {
                HttpContext.Current.Session[CartUserIdSessionKey] = userId.Value;
            }
            else
            {
                HttpContext.Current.Session.Remove(CartUserIdSessionKey);
            }
        }

        private static bool TryGetSessionCartUserId(out long userId)
        {
            userId = 0;
            object value = HttpContext.Current.Session[CartUserIdSessionKey];
            if (value is long longValue)
            {
                userId = longValue;
                return true;
            }

            return value != null && long.TryParse(value.ToString(), out userId);
        }

        private static long? GetCurrentUserId()
        {
            object value = HttpContext.Current.Session["UserId"];
            if (value == null)
            {
                return null;
            }

            if (value is long)
            {
                return (long)value;
            }

            if (long.TryParse(value.ToString(), out long userId))
            {
                return userId;
            }

            return null;
        }
    }
}

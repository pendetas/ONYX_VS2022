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
            var cart = HttpContext.Current.Session["Cart"] as List<CartItem>;
            if (cart == null)
            {
                cart = LoadPersistedCartForCurrentUser();
                HttpContext.Current.Session["Cart"] = cart;
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
            HttpContext.Current.Session["Cart"] = cart;
            PersistCartForCurrentUser();
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
            var cart = GetCartItems();
            var itemToRemove = cart.FirstOrDefault(i => i.ProductId == productId && i.VariantId == variantId);

            if (itemToRemove != null)
            {
                cart.Remove(itemToRemove);
                HttpContext.Current.Session["Cart"] = cart;
                PersistCartForCurrentUser();
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

            var cart = GetCartItems();
            var item = cart.FirstOrDefault(i => i.ProductId == productId && i.VariantId == variantId);

            if (item != null)
            {
                item.Quantity = newQuantity;
                HttpContext.Current.Session["Cart"] = cart;
                PersistCartForCurrentUser();
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

            HttpContext.Current.Session["Cart"] = new List<CartItem>();
        }

        public void MergeSessionCartForUser(long userId, List<CartItem> sessionCart)
        {
            if (sessionCart == null || sessionCart.Count == 0)
            {
                HttpContext.Current.Session["Cart"] = LoadPersistedCartForUser(userId);
                return;
            }

            foreach (CartItem item in sessionCart)
            {
                _cartRepository.UpsertCartItem(userId, item);
            }

            HttpContext.Current.Session["Cart"] = LoadPersistedCartForUser(userId);
        }

        public void PersistCartForCurrentUser()
        {
            long? userId = GetCurrentUserId();
            if (!userId.HasValue)
            {
                return;
            }

            _cartRepository.ClearCart(userId.Value);

            var cart = HttpContext.Current.Session["Cart"] as List<CartItem>;
            if (cart == null)
            {
                return;
            }

            foreach (CartItem item in cart)
            {
                _cartRepository.SetCartItemQuantity(userId.Value, item.ProductId, item.VariantId, item.Quantity);
            }
        }

        public List<CartItem> LoadPersistedCartForCurrentUser()
        {
            long? userId = GetCurrentUserId();
            return userId.HasValue
                ? LoadPersistedCartForUser(userId.Value)
                : new List<CartItem>();
        }

        private List<CartItem> LoadPersistedCartForUser(long userId)
        {
            return _cartRepository.GetCartItems(userId).ToList();
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

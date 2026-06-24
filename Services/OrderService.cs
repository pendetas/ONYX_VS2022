using System;
using System.Collections.Generic;
using System.Linq;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class OrderService
    {
        private readonly OrderRepository _orderRepository;

        public OrderService()
        {
            _orderRepository = new OrderRepository();
        }

        public long CreateOrderFromCart(long userId, string shippingAddress, IList<CartItem> cartItems)
        {
            if (string.IsNullOrWhiteSpace(shippingAddress))
            {
                throw new InvalidOperationException("Shipping address is required.");
            }

            if (cartItems == null || cartItems.Count == 0)
            {
                throw new InvalidOperationException("Your cart is empty.");
            }

            decimal totalAmount = cartItems.Sum(item => item.Price * item.Quantity);
            return _orderRepository.CreateOrder(userId, totalAmount, shippingAddress.Trim(), null, cartItems);
        }

        public Invoice GetInvoice(long orderId, long userId)
        {
            Invoice invoice = _orderRepository.GetInvoice(orderId, userId);
            if (invoice == null)
            {
                throw new InvalidOperationException("Invoice not found.");
            }

            return invoice;
        }

        public IList<Order> GetOrdersForUser(long userId, string status, int limit)
        {
            string normalized = NormalizeFilter(status);
            return _orderRepository.GetOrdersForUser(userId, normalized, limit) ?? new List<Order>();
        }

        public Order GetOrderForUser(long orderId, long userId)
        {
            return _orderRepository.GetOrderForUser(orderId, userId);
        }

        private static string NormalizeFilter(string status)
        {
            string value = (status ?? string.Empty).Trim().ToLowerInvariant();
            if (value == OrderStatuses.PendingPayment ||
                value == OrderStatuses.Paid ||
                value == OrderStatuses.Cancelled)
            {
                return value;
            }

            return null;
        }

        public IList<Product> GetPurchasedProductsForUser(long userId)
        {
            return _orderRepository.GetPurchasedProductsForUser(userId) ?? new List<Product>();
        }

        public bool HasPurchasedProduct(long userId, long productId)
        {
            return _orderRepository.HasPurchasedProduct(userId, productId);
        }
    }
}

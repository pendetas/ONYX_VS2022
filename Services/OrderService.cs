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

        public IList<Order> GetOrdersForUser(long userId, int limit)
        {
            return _orderRepository.GetOrdersForUser(userId, limit) ?? new List<Order>();
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

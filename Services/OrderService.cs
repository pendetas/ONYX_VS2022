using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web.Hosting;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class OrderService
    {
        private readonly OrderRepository _repo;
        private readonly EmailService _emailService;

        public OrderService() : this(new OrderRepository())
        {
        }

        public OrderService(OrderRepository repo)
        {
            _repo = repo;
            _emailService = new EmailService();
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
            return _repo.CreateOrder(userId, totalAmount, shippingAddress.Trim(), null, cartItems);
        }

        public Invoice GetInvoice(long orderId, long userId)
        {
            Invoice invoice = _repo.GetInvoice(orderId, userId);
            if (invoice == null)
            {
                throw new InvalidOperationException("Invoice not found.");
            }

            return invoice;
        }

        public void SendCheckoutSuccessEmailOnce(long orderId, long userId, string invoiceUrl)
        {
            Invoice invoice = GetInvoice(orderId, userId);
            if (!_repo.TryMarkCheckoutSuccessEmailSent(orderId, userId))
            {
                return;
            }

            try
            {
                HostingEnvironment.QueueBackgroundWorkItem(async cancellationToken =>
                {
                    if (cancellationToken.IsCancellationRequested)
                    {
                        _repo.ClearCheckoutSuccessEmailSent(orderId, userId);
                        return;
                    }

                    await SendCheckoutSuccessEmailAsync(orderId, userId, invoice, invoiceUrl);
                });
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Checkout success email queue failed for order {0}: {1}",
                    orderId,
                    exception.GetType().Name);

                Task.Run(() => SendCheckoutSuccessEmailAsync(orderId, userId, invoice, invoiceUrl));
            }
        }

        private async Task SendCheckoutSuccessEmailAsync(
            long orderId,
            long userId,
            Invoice invoice,
            string invoiceUrl)
        {
            try
            {
                await _emailService.SendCheckoutSuccessAsync(invoice, invoiceUrl);
            }
            catch (Exception exception)
            {
                // ponytail: claimed once before SMTP to prevent refresh duplicate emails.
                _repo.ClearCheckoutSuccessEmailSent(orderId, userId);
                System.Diagnostics.Trace.TraceWarning(
                    "Checkout success email failed for order {0}: {1}",
                    orderId,
                    exception.GetType().Name);
            }
        }

        public IList<Order> GetOrdersForUser(long userId, string status, int limit)
        {
            string normalized = NormalizeFilter(status);
            return _repo.GetOrdersForUser(userId, normalized, limit) ?? new List<Order>();
        }

        public Order GetOrderForUser(long orderId, long userId)
        {
            return _repo.GetOrderForUser(orderId, userId);
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
            return _repo.GetPurchasedProductsForUser(userId) ?? new List<Product>();
        }

        public bool HasPurchasedProduct(long userId, long productId)
        {
            return _repo.HasPurchasedProduct(userId, productId);
        }

        public List<OrderSummary> GetAllOrders()
        {
            return _repo.GetAllOrders();
        }

        public OrderStats GetStats()
        {
            return _repo.GetStats();
        }

        public OrderDetail GetOrderById(long id)
        {
            return _repo.GetOrderById(id);
        }

        public List<OrderItemDetail> GetOrderItems(long orderId)
        {
            return _repo.GetOrderItems(orderId);
        }

        public string UpdateStatus(long orderId, string status)
        {
            var allowed = new[] { "pending", "shipped", "delivered", "cancelled" };
            if (!allowed.Contains(status))
            {
                return "Invalid status value.";
            }

            _repo.UpdateStatus(orderId, status);
            return null;
        }

        public void DeleteOrder(long orderId)
        {
            _repo.DeleteOrder(orderId);
        }
    }
}

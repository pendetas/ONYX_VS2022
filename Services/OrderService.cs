using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class OrderService
    {
        private readonly OrderRepository _repo;

        public OrderService() : this(new OrderRepository()) { }

        public OrderService(OrderRepository repo)
        {
            _repo = repo;
        }

        // ── Admin: order list ────────────────────────────────────────────────
        public List<OrderSummary> GetAllOrders()
        {
            return _repo.GetAllOrders();
        }

        public OrderStats GetStats()
        {
            return _repo.GetStats();
        }

        // ── Admin: order detail ──────────────────────────────────────────────
        public OrderDetail GetOrderById(long id)
        {
            return _repo.GetOrderById(id);
        }

        public List<OrderItemDetail> GetOrderItems(long orderId)
        {
            return _repo.GetOrderItems(orderId);
        }

        // Validates the status value before updating.
        // Returns error string or null on success.
        public string UpdateStatus(long orderId, string status)
        {
            var allowed = new[] { "pending", "shipped", "delivered", "cancelled" };
            bool valid = false;
            foreach (var s in allowed) if (s == status) { valid = true; break; }
            if (!valid) return "Invalid status value.";

            _repo.UpdateStatus(orderId, status);
            return null;
        }

        public void DeleteOrder(long orderId)
        {
            _repo.DeleteOrder(orderId);
        }
    }
}

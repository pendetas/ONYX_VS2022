using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class DashboardService
    {
        private readonly AdminRepository _repo;

        public DashboardService() : this(new AdminRepository()) { }

        public DashboardService(AdminRepository repo)
        {
            _repo = repo;
        }

        public DashboardMetrics GetMetrics()
        {
            return _repo.GetDashboardMetrics();
        }

        public List<TopProduct> GetTopProducts(int count = 5)
        {
            return _repo.GetTopSellingProducts(count);
        }

        public List<LowStockProduct> GetLowStockProducts(int threshold = 5)
        {
            return _repo.GetLowStockProducts(threshold);
        }

        public List<RecentOrder> GetRecentOrders(int count = 6)
        {
            return _repo.GetRecentOrders(count);
        }

        public List<decimal> GetWeeklyRevenueTrend()
        {
            return _repo.GetWeeklyRevenueTrend();
        }

        public List<RecentActivity> GetRecentActivities(int count = 3)
        {
            return _repo.GetRecentActivities(count);
        }
    }
}

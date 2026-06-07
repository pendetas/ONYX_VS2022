using System;
using System.Collections.Generic;
using System.Web.UI;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_users : System.Web.UI.Page
    {
        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindUsers();
            }
        }

        // =====================================================================
        //  DATA BINDING  (replace with UserRepository.GetAll() when DB ready)
        // =====================================================================

        private void BindUsers()
        {
            // SpentClass: "spent-value" for customers with purchases, "spent-dash" for admins/zero
            var mockUsers = new List<object>
            {
                new { FullName = "Admin",          Email = "admin@onyx.com",            RoleKey = "admin",    Role = "Admin",    Initials = "AD", Phone = "+60 3-1234 5678",  JoinDate = "1 Jan 2025",   TotalOrders = "—",  TotalSpent = "—",          SpentClass = "spent-dash"  },
                new { FullName = "Amir Rashid",    Email = "amir.rashid@gmail.com",     RoleKey = "customer", Role = "Customer", Initials = "AR", Phone = "+60 12-345 6789",  JoinDate = "14 Jan 2025",  TotalOrders = "12", TotalSpent = "RM 8,942.00", SpentClass = "spent-value" },
                new { FullName = "Siti Nurhaliza", Email = "siti.n@hotmail.com",        RoleKey = "customer", Role = "Customer", Initials = "SN", Phone = "+60 11-876 5432",  JoinDate = "3 Feb 2025",   TotalOrders = "7",  TotalSpent = "RM 5,341.00", SpentClass = "spent-value" },
                new { FullName = "Lee Chong Wei",  Email = "lcw@gmail.com",             RoleKey = "customer", Role = "Customer", Initials = "LC", Phone = "+60 16-234 5678",  JoinDate = "20 Feb 2025",  TotalOrders = "3",  TotalSpent = "RM 1,847.00", SpentClass = "spent-value" },
                new { FullName = "Kumar Rajan",    Email = "kumar.rajan@yahoo.com",     RoleKey = "customer", Role = "Customer", Initials = "KR", Phone = "+60 14-321 0987",  JoinDate = "5 Mar 2025",   TotalOrders = "18", TotalSpent = "RM 14,210.00",SpentClass = "spent-value" },
                new { FullName = "Farah Liyana",   Email = "farah.liyana@gmail.com",    RoleKey = "customer", Role = "Customer", Initials = "FL", Phone = "+60 17-456 7890",  JoinDate = "12 Mar 2025",  TotalOrders = "5",  TotalSpent = "RM 2,249.00", SpentClass = "spent-value" },
                new { FullName = "Tan Wei Xiang",  Email = "weixin.tan@gmail.com",      RoleKey = "customer", Role = "Customer", Initials = "TW", Phone = "+60 12-789 0123",  JoinDate = "28 Mar 2025",  TotalOrders = "2",  TotalSpent = "RM 698.00",   SpentClass = "spent-value" },
                new { FullName = "Nora Ariffin",   Email = "nora.a@outlook.com",        RoleKey = "customer", Role = "Customer", Initials = "NA", Phone = "+60 19-567 8901",  JoinDate = "10 Apr 2025",  TotalOrders = "9",  TotalSpent = "RM 6,750.00", SpentClass = "spent-value" },
                new { FullName = "Jason Lim",      Email = "jason.lim@gmail.com",       RoleKey = "customer", Role = "Customer", Initials = "JL", Phone = "+60 13-234 5678",  JoinDate = "22 Apr 2025",  TotalOrders = "4",  TotalSpent = "RM 5,240.00", SpentClass = "spent-value" },
                new { FullName = "Priya Sharma",   Email = "priya.s@gmail.com",         RoleKey = "customer", Role = "Customer", Initials = "PS", Phone = "+60 11-345 6789",  JoinDate = "7 May 2025",   TotalOrders = "6",  TotalSpent = "RM 3,198.00", SpentClass = "spent-value" }
            };

            UsersRepeater.DataSource = mockUsers;
            UsersRepeater.DataBind();

            int total = mockUsers.Count;
            int adminCount = 1;
            int customerCount = total - adminCount;

            litUserCountHeader.Text = total.ToString();
            litStatTotal.Text = total.ToString();
            litStatAdmins.Text = adminCount.ToString();
            litStatCustomers.Text = customerCount.ToString();
            litStatRevenue.Text = "RM 48,475";
            litVisibleCount.Text = total.ToString();
            litTotalCount.Text = total.ToString();
            litNewThisMonth.Text = "3";
        }
    }
}
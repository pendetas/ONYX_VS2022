using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.DAL;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_users : System.Web.UI.Page
    {
        private readonly UserRepository _repo = new UserRepository();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
                BindUsers();
        }

        private void BindUsers()
        {
            List<UserRepository.UserSummary> users = _repo.GetAllUsers();
            UserRepository.UserStats stats = _repo.GetStats();

            UsersRepeater.DataSource = users;
            UsersRepeater.DataBind();

            int total = stats.Total;
            litUserCountHeader.Text = total.ToString();
            litStatTotal.Text       = total.ToString();
            litStatAdmins.Text      = stats.Admins.ToString();
            litStatCustomers.Text   = stats.Customers.ToString();
            litStatRevenue.Text     = "RM " + stats.PlatformRevenue.ToString("N0");
            litVisibleCount.Text    = total.ToString();
            litTotalCount.Text      = total.ToString();
            litNewThisMonth.Text    = stats.NewThisMonth.ToString();
        }
    }
}

using System;
using System.Collections.Generic;
using System.Web.UI;
using ONYX_DDAC.DAL;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_user_detail : Page
    {
        private readonly UserRepository _repo = new UserRepository();

        private long CurrentUserId
        {
            get { return ViewState["UserId"] != null ? (long)ViewState["UserId"] : 0; }
            set { ViewState["UserId"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                long id;
                if (!long.TryParse(Request.QueryString["id"], out id) || id <= 0)
                {
                    ShowNotFound();
                    return;
                }

                CurrentUserId = id;
                BindUser(id);

                if (Request.QueryString["saved"] == "1")
                    ShowAlert("Changes saved successfully.", true);
            }
        }

        // =====================================================================
        //  DATA BINDING
        // =====================================================================

        private void BindUser(long id)
        {
            UserRepository.UserDetail user = _repo.GetUserById(id);

            if (user == null) { ShowNotFound(); return; }

            pnlUserDetail.Visible = true;
            pnlNotFound.Visible   = false;

            string roleKey = user.Role.ToLower();
            string roleCap = char.ToUpper(user.Role[0]) + user.Role.Substring(1);

            // Header
            litPageTitle.Text = user.FullName;
            litJoinDate.Text  = user.CreatedAt.ToString("d MMM yyyy");
            litUsername.Text  = Server.HtmlEncode(user.Username);

            // Hero
            litInitials.Text  = user.Initials;
            litHeroName.Text  = Server.HtmlEncode(user.FullName);
            litHeroEmail.Text = Server.HtmlEncode(user.Email);

            // Form fields
            txtFullName.Text = user.FullName;
            txtEmail.Text    = user.Email;
            txtPhone.Text    = user.Phone;
            txtAddress.Text  = user.Address;
            ddlRole.SelectedValue = roleKey;

            // Stats
            lblRoleBadge.Text    = "<span class=\"role-badge role-" + roleKey + "\">" + roleCap + "</span>";
            litTotalOrders.Text  = user.TotalOrders.ToString();
            litTotalSpent.Text   = user.TotalSpent == 0m ? "—" : "RM " + user.TotalSpent.ToString("N2");
            litMemberSince.Text  = user.CreatedAt.ToString("d MMM yyyy");

            // Orders
            List<UserRepository.UserOrderSummary> orders = _repo.GetUserOrders(id);
            if (orders.Count == 0)
            {
                pnlNoOrders.Visible = true;
                pnlOrders.Visible   = false;
            }
            else
            {
                pnlNoOrders.Visible   = false;
                pnlOrders.Visible     = true;
                OrdersRepeater.DataSource = orders;
                OrdersRepeater.DataBind();
            }
        }

        // =====================================================================
        //  EVENT HANDLERS
        // =====================================================================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            long id = CurrentUserId;
            if (id <= 0) return;

            string fullName = txtFullName.Text.Trim();
            string email    = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email))
            {
                ShowAlert("Full name and email are required.", false);
                return;
            }

            try
            {
                _repo.UpdateUser(id, fullName, email, txtPhone.Text.Trim(), txtAddress.Text.Trim(), ddlRole.SelectedValue);
                Response.Redirect("onyx_admin_user_detail.aspx?id=" + id + "&saved=1");
            }
            catch (Exception)
            {
                ShowAlert("Save failed. The email may already be in use by another account.", false);
            }
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            long id = CurrentUserId;
            if (id <= 0) return;

            _repo.DeleteUser(id);
            Response.Redirect("~/admin_page/onyx_admin_users.aspx");
        }

        // =====================================================================
        //  HELPERS
        // =====================================================================

        private void ShowNotFound()
        {
            pnlUserDetail.Visible = false;
            pnlNotFound.Visible   = true;
        }

        private void ShowAlert(string message, bool success)
        {
            string cls = success ? "alert-success" : "alert-error";
            litAlertMsg.Text  = "<div class=\"" + cls + "\">" + Server.HtmlEncode(message) + "</div>";
            pnlAlert.Visible  = true;
        }
    }
}

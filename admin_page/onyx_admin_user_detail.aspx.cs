using System;
using System.Web.UI;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_user_detail : Page
    {
        private readonly UserService _svc = new UserService();

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
                    ShowAlert("Changes saved successfully.", success: true);
            }
        }

        private void BindUser(long id)
        {
            var user = _svc.GetUserById(id);
            if (user == null) { ShowNotFound(); return; }

            pnlUserDetail.Visible = true;
            pnlNotFound.Visible   = false;

            string roleKey = string.IsNullOrEmpty(user.Role) ? "" : user.Role.ToLower();
            string roleCap = string.IsNullOrEmpty(user.Role) ? "Unknown" : char.ToUpper(user.Role[0]) + user.Role.Substring(1);

            litPageTitle.Text = Server.HtmlEncode(user.FullName);
            litJoinDate.Text  = user.CreatedAt.ToString("d MMM yyyy");
            litUsername.Text  = Server.HtmlEncode(user.Username);

            litInitials.Text  = Server.HtmlEncode(user.Initials);
            litHeroName.Text  = Server.HtmlEncode(user.FullName);
            litHeroEmail.Text = Server.HtmlEncode(user.Email);

            txtFullName.Text      = user.FullName;
            txtEmail.Text         = user.Email;
            txtPhone.Text         = user.Phone;
            txtAddress.Text       = user.Address;
            ddlRole.SelectedValue = roleKey;

            lblRoleBadge.Text   = "<span class=\"role-badge role-" + roleKey + "\">" + roleCap + "</span>";
            litTotalOrders.Text = user.TotalOrders.ToString();
            litTotalSpent.Text  = user.TotalSpent == 0m ? "—" : "RM " + user.TotalSpent.ToString("N2");
            litMemberSince.Text = user.CreatedAt.ToString("d MMM yyyy");

            var orders = _svc.GetUserOrders(id);
            if (orders.Count == 0)
            {
                pnlNoOrders.Visible = true;
                pnlOrders.Visible   = false;
            }
            else
            {
                pnlNoOrders.Visible       = false;
                pnlOrders.Visible         = true;
                OrdersRepeater.DataSource = orders;
                OrdersRepeater.DataBind();
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            long id = CurrentUserId;
            if (id <= 0) return;

            string err = _svc.UpdateUser(
                id,
                txtFullName.Text.Trim(),
                txtEmail.Text.Trim(),
                txtPhone.Text.Trim(),
                txtAddress.Text.Trim(),
                ddlRole.SelectedValue);

            if (err != null)
            {
                ShowAlert(err, success: false);
                return;
            }

            Response.Redirect("onyx_admin_user_detail.aspx?id=" + id + "&saved=1");
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            long id = CurrentUserId;
            if (id <= 0) return;

            try
            {
                _svc.DeleteUser(id);
                Response.Redirect("~/admin_page/onyx_admin_users.aspx");
            }
            catch (Exception)
            {
                ShowAlert("Failed to delete user. Please try again.", success: false);
            }
        }

        private void ShowNotFound()
        {
            pnlUserDetail.Visible = false;
            pnlNotFound.Visible   = true;
        }

        private void ShowAlert(string message, bool success)
        {
            string cls = success ? "alert-success" : "alert-error";
            litAlertMsg.Text = "<div class=\"" + cls + "\">" + Server.HtmlEncode(message) + "</div>";
            pnlAlert.Visible = true;
        }
    }
}

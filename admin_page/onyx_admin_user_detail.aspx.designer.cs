namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_user_detail
    {
        // Layout panels
        protected global::System.Web.UI.WebControls.Panel pnlNotFound;
        protected global::System.Web.UI.WebControls.Panel pnlUserDetail;

        // Header
        protected global::System.Web.UI.WebControls.Literal litPageTitle;
        protected global::System.Web.UI.WebControls.Literal litJoinDate;
        protected global::System.Web.UI.WebControls.Literal litUsername;

        // Hero
        protected global::System.Web.UI.WebControls.Literal litInitials;
        protected global::System.Web.UI.WebControls.Literal litHeroName;
        protected global::System.Web.UI.WebControls.Literal litHeroEmail;

        // Alert
        protected global::System.Web.UI.WebControls.Panel   pnlAlert;
        protected global::System.Web.UI.WebControls.Literal litAlertMsg;

        // Edit form fields
        protected global::System.Web.UI.WebControls.TextBox      txtFullName;
        protected global::System.Web.UI.WebControls.TextBox      txtEmail;
        protected global::System.Web.UI.WebControls.TextBox      txtPhone;
        protected global::System.Web.UI.WebControls.TextBox      txtAddress;
        protected global::System.Web.UI.WebControls.DropDownList ddlRole;
        protected global::System.Web.UI.WebControls.Button       btnSave;

        // Orders section
        protected global::System.Web.UI.WebControls.Panel    pnlNoOrders;
        protected global::System.Web.UI.WebControls.Panel    pnlOrders;
        protected global::System.Web.UI.WebControls.Repeater OrdersRepeater;

        // Stats
        protected global::System.Web.UI.WebControls.Label   lblRoleBadge;
        protected global::System.Web.UI.WebControls.Literal litTotalOrders;
        protected global::System.Web.UI.WebControls.Literal litTotalSpent;
        protected global::System.Web.UI.WebControls.Literal litMemberSince;

        // Danger zone
        protected global::System.Web.UI.WebControls.Button btnDelete;
    }
}

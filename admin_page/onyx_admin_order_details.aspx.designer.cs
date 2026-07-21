namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_order_details
    {
        // Layout panels
        protected global::System.Web.UI.WebControls.Panel pnlNotFound;
        protected global::System.Web.UI.WebControls.Panel pnlOrderDetail;

        // Header
        protected global::System.Web.UI.WebControls.Literal litOrderId;
        protected global::System.Web.UI.WebControls.Literal litOrderDate;
        protected global::System.Web.UI.WebControls.Literal litCustomerNameHeader;
        protected global::System.Web.UI.WebControls.Label   lblStatusBadge;

        // Customer info
        protected global::System.Web.UI.WebControls.Literal litCustName;
        protected global::System.Web.UI.WebControls.Literal litCustEmail;
        protected global::System.Web.UI.WebControls.Literal litCustPhone;
        protected global::System.Web.UI.WebControls.Literal litCustSince;

        // Shipping
        protected global::System.Web.UI.WebControls.Literal litShippingAddress;

        // Repeaters
        protected global::System.Web.UI.WebControls.Repeater OrderItemsRepeater;
        protected global::System.Web.UI.WebControls.Repeater TimelineRepeater;

        // Summary
        protected global::System.Web.UI.WebControls.Literal litSubtotal;
        protected global::System.Web.UI.WebControls.Panel pnlVoucherSummary;
        protected global::System.Web.UI.WebControls.Literal litVoucherLabel;
        protected global::System.Web.UI.WebControls.Literal litDiscount;
        protected global::System.Web.UI.WebControls.Literal litTotal;

        // Status update
        protected global::System.Web.UI.WebControls.DropDownList ddlStatus;
        protected global::System.Web.UI.WebControls.Button       btnUpdateStatus;
        protected global::System.Web.UI.WebControls.Panel        pnlStatusMsg;
        protected global::System.Web.UI.WebControls.Literal      litStatusMsg;

        // Delete
        protected global::System.Web.UI.WebControls.Button btnDeleteOrder;

        // Metadata
        protected global::System.Web.UI.WebControls.Literal litMetaOrderId;
        protected global::System.Web.UI.WebControls.Literal litMetaDate;
        protected global::System.Web.UI.WebControls.Literal litReceiptKey;
    }
}

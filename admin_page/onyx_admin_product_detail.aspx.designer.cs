namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_product_detail
    {
        // ---- Not found / detail panels ----
        protected global::System.Web.UI.WebControls.Panel pnlNotFound;
        protected global::System.Web.UI.WebControls.Panel pnlDetail;

        // ---- Product image ----
        protected global::System.Web.UI.WebControls.Image imgProduct;
        protected global::System.Web.UI.WebControls.Label lblPlaceholder;

        // ---- Product info labels ----
        protected global::System.Web.UI.WebControls.Label lblCategory;
        protected global::System.Web.UI.WebControls.Label lblName;
        protected global::System.Web.UI.WebControls.Label lblBrand;
        protected global::System.Web.UI.WebControls.Label lblPrice;
        protected global::System.Web.UI.WebControls.Label lblStock;
        protected global::System.Web.UI.WebControls.Label lblDescription;
        protected global::System.Web.UI.WebControls.Label lblCreatedAt;
        protected global::System.Web.UI.WebControls.Label lblId;
        protected global::System.Web.UI.WebControls.HyperLink lnkEdit;

        // ---- Variants section ----
        protected global::System.Web.UI.WebControls.Panel pnlVarMsg;
        protected global::System.Web.UI.HtmlControls.HtmlGenericControl varMsgBox;
        protected global::System.Web.UI.WebControls.Panel pnlNoVariants;
        protected global::System.Web.UI.WebControls.Repeater VariantsRepeater;

        // ---- Add variant form ----
        protected global::System.Web.UI.WebControls.TextBox txtVType;
        protected global::System.Web.UI.WebControls.TextBox txtVValue;
        protected global::System.Web.UI.WebControls.TextBox txtVPrice;
        protected global::System.Web.UI.WebControls.TextBox txtVStock;
        protected global::System.Web.UI.WebControls.Button btnAddVariant;
    }
}

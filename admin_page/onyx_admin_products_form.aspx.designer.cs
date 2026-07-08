namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_products_form
    {
        // ---- Header ----
        protected global::System.Web.UI.WebControls.Literal litPageTitle;
        protected global::System.Web.UI.WebControls.Literal litPageSubtitle;

        // ---- Alert ----
        protected global::System.Web.UI.WebControls.Panel pnlAlert;
        protected global::System.Web.UI.WebControls.Literal litAlertMessage;

        // ---- Product info ----
        protected global::System.Web.UI.WebControls.TextBox txtName;
        protected global::System.Web.UI.WebControls.TextBox txtBrand;
        protected global::System.Web.UI.WebControls.DropDownList ddlCategory;

        // ---- Pricing / inventory ----
        protected global::System.Web.UI.WebControls.TextBox txtPrice;
        protected global::System.Web.UI.WebControls.TextBox txtStock;
        protected global::System.Web.UI.WebControls.Label lblStockHint;

        // ---- Colors ----
        protected global::System.Web.UI.UpdatePanel upColors;
        protected global::System.Web.UI.WebControls.Panel pnlCreateColors;
        protected global::System.Web.UI.WebControls.CheckBoxList CreateColorChoices;
        protected global::System.Web.UI.WebControls.Panel pnlColors;
        protected global::System.Web.UI.WebControls.Repeater ColorSwatchRepeater;
        protected global::System.Web.UI.WebControls.Panel pnlColorVariants;
        protected global::System.Web.UI.WebControls.Repeater ColorVariantsRepeater;

        // ---- Details / media ----
        protected global::System.Web.UI.WebControls.TextBox txtDescription;
        protected global::System.Web.UI.WebControls.FileUpload ProductImageUpload;
        protected global::System.Web.UI.WebControls.TextBox txtImageUrl;

        // ---- Actions ----
        protected global::System.Web.UI.WebControls.Button btnSave;
    }
}

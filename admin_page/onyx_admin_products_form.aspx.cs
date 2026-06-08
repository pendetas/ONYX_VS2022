using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.admin_page
{
    public class ColorSwatch
    {
        public string Name      { get; set; }
        public string Hex       { get; set; }
        public bool   IsActive  { get; set; }
        public int    StockQty  { get; set; }
        public long   VariantId { get; set; }
    }

    public partial class onyx_admin_products_form : Page
    {
        private readonly ProductRepository _repo = new ProductRepository();

        private static readonly string[] _colorNames =
            { "Black", "White", "Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Pink", "Gray" };

        private static readonly string[] _colorHexes =
            { "#1a1a1a", "#f5f5f5", "#e03535", "#2b6ced", "#27ae60", "#f0c426", "#7c3aed", "#e87c2e", "#e84393", "#888888" };

        private bool IsEditMode => _EditId > 0;

        private long _EditId
        {
            get { return ViewState["editId"] != null ? (long)ViewState["editId"] : 0L; }
            set { ViewState["editId"] = value; }
        }

        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                long id;
                if (long.TryParse(Request.QueryString["id"], out id) && id > 0)
                    _EditId = id;

                UpdatePageLabels();

                if (IsEditMode)
                {
                    LoadProduct(_EditId);
                    BindColors(_EditId);

                    string vmsg = Request.QueryString["vmsg"];
                    if (vmsg == "cvsaved")  ShowAlert("Color variant updated.");
                    if (vmsg == "cadded")   ShowAlert("Color variant added.");
                    if (vmsg == "cdeleted") ShowAlert("Color variant removed.");
                }
            }
        }

        // =====================================================================
        //  LOAD / BIND
        // =====================================================================

        private void LoadProduct(long id)
        {
            Product p = _repo.GetProductById(id);
            if (p == null) return;

            txtName.Text        = p.Name;
            txtBrand.Text       = p.Brand ?? "";
            txtPrice.Text       = p.Price.ToString("N2", CultureInfo.InvariantCulture);
            txtStock.Text       = p.StockQty.ToString();
            txtImageUrl.Text    = p.ImageUrl ?? "";
            txtDescription.Text = p.Description ?? "";

            if (ddlCategory.Items.FindByValue(p.Category) != null)
                ddlCategory.SelectedValue = p.Category;

            // Disable manual stock field when color variants control it
            var variants = _repo.GetVariantsByProductId(id);
            if (variants.Any(v => v.VariantType == "Color"))
            {
                txtStock.Enabled      = false;
                lblStockHint.Text     = "Managed by color variants below.";
                lblStockHint.CssClass = "field-hint managed";
            }
        }

        private void BindColors(long productId)
        {
            pnlColors.Visible = true;

            var variants = _repo.GetVariantsByProductId(productId)
                .Where(v => v.VariantType == "Color")
                .ToList();

            var swatches = new List<ColorSwatch>();
            for (int i = 0; i < _colorNames.Length; i++)
            {
                string cname = _colorNames[i];
                var match = variants.FirstOrDefault(v =>
                    string.Equals(v.VariantValue, cname, StringComparison.OrdinalIgnoreCase));

                swatches.Add(new ColorSwatch
                {
                    Name      = cname,
                    Hex       = _colorHexes[i],
                    IsActive  = match != null,
                    StockQty  = match != null ? match.StockQty : 0,
                    VariantId = match != null ? match.ProductVariantId : 0
                });
            }

            ColorSwatchRepeater.DataSource = swatches;
            ColorSwatchRepeater.DataBind();

            if (variants.Count > 0)
            {
                pnlColorVariants.Visible          = true;
                ColorVariantsRepeater.DataSource  = variants;
                ColorVariantsRepeater.DataBind();
            }
            else
            {
                pnlColorVariants.Visible = false;
            }
        }

        // =====================================================================
        //  COLOR SWATCH TOGGLE
        // =====================================================================

        protected void ColorSwatchRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ToggleColor") return;

            long productId   = _EditId;
            string colorName = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(colorName)) return;

            var variants = _repo.GetVariantsByProductId(productId);
            var existing = variants.FirstOrDefault(v =>
                v.VariantType == "Color" &&
                string.Equals(v.VariantValue, colorName, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                _repo.DeleteVariant(existing.ProductVariantId, productId);
                BindColors(productId);
                SyncStockFieldScript(productId);
                ShowAlert("\"" + colorName + "\" color removed.");
            }
            else
            {
                Product p = _repo.GetProductById(productId);
                decimal basePrice = p != null ? p.Price : 0m;
                _repo.AddVariant(productId, "Color", colorName, basePrice, 0);
                BindColors(productId);
                SyncStockFieldScript(productId);
                ShowAlert("\"" + colorName + "\" color added. Set its stock below.");
            }

            upColors.Update();
        }

        // =====================================================================
        //  COLOR VARIANT ROW SAVE
        // =====================================================================

        protected void ColorVariantsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "SaveColor") return;

            long productId = _EditId;
            long variantId;
            if (!long.TryParse(e.CommandArgument?.ToString(), out variantId)) return;

            var txtCvPriceCtrl = (TextBox)e.Item.FindControl("txtCvPrice");
            var txtCvStockCtrl = (TextBox)e.Item.FindControl("txtCvStock");

            decimal price;
            int     stock;

            bool priceOk = decimal.TryParse(txtCvPriceCtrl.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out price);
            bool stockOk = int.TryParse(txtCvStockCtrl.Text.Trim(), out stock);

            if (!priceOk || price < 0 || !stockOk || stock < 0)
            {
                BindColors(productId);
                upColors.Update();
                ShowAlert("Enter a valid price (e.g. 599.00) and stock (≥ 0).", isError: true);
                return;
            }

            _repo.UpdateVariant(variantId, productId, price, stock);
            BindColors(productId);
            SyncStockFieldScript(productId);
            upColors.Update();
            ShowAlert("Stock saved.");
        }

        // Emits JS that keeps the stock TextBox in sync after a partial update
        private void SyncStockFieldScript(long productId)
        {
            var colorVariants = _repo.GetVariantsByProductId(productId)
                .Where(v => v.VariantType == "Color").ToList();

            bool hasColors = colorVariants.Count > 0;
            string stockId  = txtStock.ClientID;
            string hintId   = lblStockHint.ClientID;

            string script = hasColors
                ? "var s=document.getElementById('" + stockId + "');if(s){s.disabled=true;}" +
                  "var h=document.getElementById('" + hintId  + "');if(h){h.textContent='Managed by color variants below.';}"
                : "var s=document.getElementById('" + stockId + "');if(s){s.disabled=false;}" +
                  "var h=document.getElementById('" + hintId  + "');if(h){h.textContent='Set 0 to mark as out of stock.';}";

            ScriptManager.RegisterStartupScript(this, GetType(), "syncStock", script, true);
        }

        // =====================================================================
        //  SAVE PRODUCT
        // =====================================================================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name = txtName.Text.Trim();
            if (string.IsNullOrWhiteSpace(name))
            { ShowAlert("Product name is required.", isError: true); return; }

            if (ddlCategory.SelectedIndex == 0)
            { ShowAlert("Please select a category.", isError: true); return; }

            decimal price;
            if (!decimal.TryParse(txtPrice.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out price) || price < 0)
            { ShowAlert("Please enter a valid price.", isError: true); return; }

            int stock = 0;
            if (txtStock.Enabled && (!int.TryParse(txtStock.Text.Trim(), out stock) || stock < 0))
            { ShowAlert("Please enter a valid stock quantity.", isError: true); return; }

            string brand    = txtBrand.Text.Trim();
            string category = ddlCategory.SelectedValue;
            string desc     = txtDescription.Text.Trim();
            string imgUrl   = txtImageUrl.Text.Trim();

            if (IsEditMode)
            {
                _repo.UpdateProduct(_EditId, name, brand, category, desc, price, stock, imgUrl);
                Response.Redirect("onyx_admin_product_detail.aspx?id=" + _EditId + "&vmsg=updated");
            }
            else
            {
                long newId = _repo.InsertProduct(name, brand, category, desc, price, stock, imgUrl);
                Response.Redirect("onyx_admin_product_detail.aspx?id=" + newId + "&vmsg=created");
            }
        }

        // =====================================================================
        //  HELPERS
        // =====================================================================

        protected string GetColorHex(string colorName)
        {
            for (int i = 0; i < _colorNames.Length; i++)
                if (string.Equals(_colorNames[i], colorName, StringComparison.OrdinalIgnoreCase))
                    return _colorHexes[i];
            return "#888888";
        }

        private void UpdatePageLabels()
        {
            if (IsEditMode)
            {
                litPageTitle.Text    = "Edit Product";
                litPageSubtitle.Text = "Update product details. Use color chips to manage variant stock.";
            }
            else
            {
                litPageTitle.Text    = "Add New Product";
                litPageSubtitle.Text = "Fill in the details below to add a new product to the catalog.";
            }
        }

        private void ShowAlert(string message, bool isError = false)
        {
            pnlAlert.CssClass    = isError ? "alert-panel alert-error-dark" : "alert-panel alert-success-dark";
            litAlertMessage.Text = System.Web.HttpUtility.HtmlEncode(message);
            pnlAlert.Visible     = true;
        }
    }
}

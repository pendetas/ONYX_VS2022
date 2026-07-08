using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

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
        private readonly ProductService _svc = new ProductService();
        private const string LockedBrand = "ONYX";

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

        protected void Page_Init(object sender, EventArgs e)
        {
            BindCreateColorChoices();
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Page.Form != null) Page.Form.Enctype = "multipart/form-data";
            txtBrand.Text = LockedBrand;
            txtBrand.ReadOnly = true;

            if (!IsPostBack)
            {
                long id;
                if (long.TryParse(Request.QueryString["id"], out id) && id > 0)
                    _EditId = id;

                UpdatePageLabels();
                pnlCreateColors.Visible = !IsEditMode;

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

        private void LoadProduct(long id)
        {
            Product p = _svc.GetProductById(id);
            if (p == null) { Response.Redirect("~/admin_page/onyx_admin_products.aspx"); return; }

            txtName.Text        = p.Name;
            txtBrand.Text       = LockedBrand;
            txtPrice.Text       = p.Price.ToString("N2", CultureInfo.InvariantCulture);
            txtStock.Text       = p.StockQty.ToString();
            txtImageUrl.Text    = p.ImageUrl ?? "";
            txtDescription.Text = p.Description ?? "";

            if (ddlCategory.Items.FindByValue(p.Category) != null)
                ddlCategory.SelectedValue = p.Category;

            var variants = _svc.GetVariantsByProductId(id);
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

            var variants = _svc.GetVariantsByProductId(productId)
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

        protected void ColorSwatchRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ToggleColor") return;

            long productId   = _EditId;
            string colorName = e.CommandArgument?.ToString();
            if (string.IsNullOrEmpty(colorName)) return;

            var variants = _svc.GetVariantsByProductId(productId);
            var existing = variants.FirstOrDefault(v =>
                v.VariantType == "Color" &&
                string.Equals(v.VariantValue, colorName, StringComparison.OrdinalIgnoreCase));

            if (existing != null)
            {
                _svc.DeleteVariant(existing.ProductVariantId, productId);
                BindColors(productId);
                SyncStockFieldScript(productId);
                ShowAlert("\"" + colorName + "\" color removed.");
            }
            else
            {
                Product p = _svc.GetProductById(productId);
                decimal basePrice = p != null ? p.Price : 0m;
                string err = _svc.AddVariant(productId, "Color", colorName, basePrice, 0);
                if (err != null) { ShowAlert(err, isError: true); return; }
                BindColors(productId);
                SyncStockFieldScript(productId);
                ShowAlert("\"" + colorName + "\" color added. Set its stock below.");
            }

            upColors.Update();
        }

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

            if (!priceOk || !stockOk)
            {
                BindColors(productId);
                upColors.Update();
                ShowAlert("Enter a valid price and stock.", isError: true);
                return;
            }

            string err = _svc.UpdateVariant(variantId, productId, price, stock);
            if (err != null)
            {
                BindColors(productId);
                upColors.Update();
                ShowAlert(err, isError: true);
                return;
            }

            BindColors(productId);
            SyncStockFieldScript(productId);
            upColors.Update();
            ShowAlert("Stock saved.");
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            string name     = txtName.Text.Trim();
            string brand    = LockedBrand;
            string category = ddlCategory.SelectedValue;
            string desc     = txtDescription.Text.Trim();

            decimal price;
            int     stock = 0;

            if (!decimal.TryParse(txtPrice.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out price))
            { ShowAlert("Please enter a valid price.", isError: true); return; }

            if (txtStock.Enabled && !int.TryParse(txtStock.Text.Trim(), out stock))
            { ShowAlert("Please enter a valid stock quantity.", isError: true); return; }

            try
            {
                string imgUrl = SaveUploadedProductImage();
                if (string.IsNullOrWhiteSpace(imgUrl))
                    imgUrl = txtImageUrl.Text.Trim();

                if (IsEditMode)
                {
                    _svc.UpdateProduct(_EditId, name, brand, category, desc, price, stock, imgUrl);
                    Response.Redirect("onyx_admin_product_detail.aspx?id=" + _EditId + "&vmsg=updated");
                }
                else
                {
                    long newId = _svc.CreateProduct(name, brand, category, desc, price, stock, imgUrl);
                    CreateColorVariantsForNewProduct(newId, price, stock);
                    Response.Redirect("onyx_admin_product_detail.aspx?id=" + newId + "&vmsg=created");
                }
            }
            catch (ArgumentException ex)
            {
                ShowAlert(ex.Message, isError: true);
            }
        }

        private void BindCreateColorChoices()
        {
            if (CreateColorChoices == null || CreateColorChoices.Items.Count > 0) return;

            foreach (string colorName in _colorNames)
                CreateColorChoices.Items.Add(new ListItem(colorName, colorName));
        }

        private IList<string> GetSelectedCreateColors()
        {
            return CreateColorChoices.Items.Cast<ListItem>()
                .Where(item => item.Selected)
                .Select(item => item.Value)
                .Where(value => !string.IsNullOrWhiteSpace(value))
                .Distinct(StringComparer.OrdinalIgnoreCase)
                .ToList();
        }

        private void CreateColorVariantsForNewProduct(long productId, decimal price, int stock)
        {
            IList<string> selectedColors = GetSelectedCreateColors();
            if (selectedColors.Count == 0) return;

            int baseStock = stock / selectedColors.Count;
            int remainder = stock % selectedColors.Count;

            for (int i = 0; i < selectedColors.Count; i++)
            {
                int variantStock = baseStock + (i < remainder ? 1 : 0);
                string err = _svc.AddVariant(productId, "Color", selectedColors[i], price, variantStock);
                if (err != null) throw new ArgumentException(err);
            }
        }

        private string SaveUploadedProductImage()
        {
            if (!ProductImageUpload.HasFile) return string.Empty;

            string extension = Path.GetExtension(ProductImageUpload.FileName).ToLowerInvariant();
            string[] allowedExtensions = { ".jpg", ".jpeg", ".png" };
            if (!allowedExtensions.Contains(extension))
                throw new ArgumentException("Only JPG, JPEG, and PNG product images are allowed.");

            string uploadFolder = Server.MapPath("~/Content/uploads/products/");
            Directory.CreateDirectory(uploadFolder);

            string baseName = Path.GetFileNameWithoutExtension(ProductImageUpload.FileName);
            foreach (char invalid in Path.GetInvalidFileNameChars())
                baseName = baseName.Replace(invalid, '-');

            if (string.IsNullOrWhiteSpace(baseName))
                baseName = "product";

            string fileName = baseName.Trim() + "-" +
                              DateTime.UtcNow.ToString("yyyyMMddHHmmssfff", CultureInfo.InvariantCulture) +
                              extension;
            string path = Path.Combine(uploadFolder, fileName);
            ProductImageUpload.SaveAs(path);

            return ResolveUrl("~/Content/uploads/products/" + fileName);
        }

        protected string GetColorHex(string colorName)
        {
            for (int i = 0; i < _colorNames.Length; i++)
                if (string.Equals(_colorNames[i], colorName, StringComparison.OrdinalIgnoreCase))
                    return _colorHexes[i];
            return "#888888";
        }

        private void SyncStockFieldScript(long productId)
        {
            var colorVariants = _svc.GetVariantsByProductId(productId)
                .Where(v => v.VariantType == "Color").ToList();

            bool hasColors = colorVariants.Count > 0;
            string stockId = txtStock.ClientID;
            string hintId  = lblStockHint.ClientID;

            string script = hasColors
                ? "var s=document.getElementById('" + stockId + "');if(s){s.disabled=true;}" +
                  "var h=document.getElementById('" + hintId  + "');if(h){h.textContent='Managed by color variants below.';}"
                : "var s=document.getElementById('" + stockId + "');if(s){s.disabled=false;}" +
                  "var h=document.getElementById('" + hintId  + "');if(h){h.textContent='Set 0 to mark as out of stock.';}";

            ScriptManager.RegisterStartupScript(this, GetType(), "syncStock", script, true);
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

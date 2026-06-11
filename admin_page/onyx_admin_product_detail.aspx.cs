using System;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_product_detail : Page
    {
        private readonly ProductService _svc = new ProductService();

        private long CurrentProductId
        {
            get { return ViewState["pid"] != null ? (long)ViewState["pid"] : 0L; }
            set { ViewState["pid"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                long id;
                if (!long.TryParse(Request.QueryString["id"], out id))
                { ShowNotFound(); return; }

                CurrentProductId = id;
                BindProduct(id);
                BindVariants(id);

                string vmsg = Request.QueryString["vmsg"];
                if (vmsg == "saved")   ShowVarMsg("Variant updated successfully.", isError: false);
                if (vmsg == "added")   ShowVarMsg("Variant added successfully.",   isError: false);
                if (vmsg == "deleted") ShowVarMsg("Variant deleted.",              isError: false);
                if (vmsg == "updated") ShowVarMsg("Product updated successfully.", isError: false);
                if (vmsg == "created") ShowVarMsg("Product added to catalog.",     isError: false);
            }
        }

        private void BindProduct(long id)
        {
            Product p = _svc.GetProductById(id);
            if (p == null) { ShowNotFound(); return; }

            Page.Title = p.Name + " — ONYX Admin";

            lblCategory.Text  = Server.HtmlEncode(p.Category);
            lblName.Text      = Server.HtmlEncode(p.Name);
            lblBrand.Text     = string.IsNullOrEmpty(p.Brand) ? "&mdash;" : Server.HtmlEncode(p.Brand);
            lblPrice.Text     = "RM " + p.Price.ToString("N2");
            lblId.Text        = p.Id.ToString();
            lblCreatedAt.Text = p.CreatedAt.ToString("d MMM yyyy");

            if (p.StockQty == 0)
                lblStock.Text = "<div class=\"stat-value stock-out\">Out of stock</div>";
            else if (p.StockQty < 5)
                lblStock.Text = "<div class=\"stat-value stock-low\">" + p.StockQty + " left</div>";
            else
                lblStock.Text = "<div class=\"stat-value stock-ok\">" + p.StockQty + "</div>";

            lblDescription.Text = string.IsNullOrWhiteSpace(p.Description)
                ? "<span class=\"desc-empty\">No description provided.</span>"
                : "<div class=\"desc-text\">" + Server.HtmlEncode(p.Description).Replace("\n", "<br/>") + "</div>";

            if (!string.IsNullOrEmpty(p.ImageUrl))
            {
                imgProduct.ImageUrl      = p.ImageUrl;
                imgProduct.AlternateText = p.Name;
                imgProduct.Visible       = true;
                lblPlaceholder.Visible   = false;
            }
            else
            {
                lblPlaceholder.Text    = p.Name.Substring(0, 1).ToUpper();
                lblPlaceholder.Visible = true;
                imgProduct.Visible     = false;
            }

            lnkEdit.NavigateUrl = "onyx_admin_products_form.aspx?id=" + p.Id;
        }

        private void BindVariants(long productId)
        {
            var variants = _svc.GetVariantsByProductId(productId);

            if (variants.Count == 0)
            {
                pnlNoVariants.Visible    = true;
                VariantsRepeater.Visible = false;
            }
            else
            {
                pnlNoVariants.Visible       = false;
                VariantsRepeater.Visible    = true;
                VariantsRepeater.DataSource = variants;
                VariantsRepeater.DataBind();
            }
        }

        protected void VariantsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            long productId = CurrentProductId;
            long variantId;
            if (!long.TryParse(e.CommandArgument?.ToString(), out variantId)) return;

            if (e.CommandName == "SaveVariant")
            {
                var txtPrice = (TextBox)e.Item.FindControl("txtRowPrice");
                var txtStock = (TextBox)e.Item.FindControl("txtRowStock");

                decimal price;
                int     stock;

                bool priceOk = decimal.TryParse(txtPrice.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out price);
                bool stockOk = int.TryParse(txtStock.Text.Trim(), out stock);

                if (!priceOk || !stockOk)
                {
                    ShowVarMsg("Enter a valid price and stock.", isError: true);
                    BindProduct(productId);
                    BindVariants(productId);
                    return;
                }

                string err = _svc.UpdateVariant(variantId, productId, price, stock);
                if (err != null)
                {
                    ShowVarMsg(err, isError: true);
                    BindProduct(productId);
                    BindVariants(productId);
                    return;
                }

                Response.Redirect("onyx_admin_product_detail.aspx?id=" + productId + "&vmsg=saved");
            }
            else if (e.CommandName == "DeleteVariant")
            {
                _svc.DeleteVariant(variantId, productId);
                Response.Redirect("onyx_admin_product_detail.aspx?id=" + productId + "&vmsg=deleted");
            }
        }

        protected void btnAddVariant_Click(object sender, EventArgs e)
        {
            long productId = CurrentProductId;

            string type  = txtVType.Text.Trim();
            string value = txtVValue.Text.Trim();

            decimal price;
            int     stock;

            bool priceOk = decimal.TryParse(txtVPrice.Text.Trim(), NumberStyles.Any, CultureInfo.InvariantCulture, out price);
            bool stockOk = int.TryParse(txtVStock.Text.Trim(), out stock);

            if (!priceOk || !stockOk)
            {
                ShowVarMsg("Enter a valid price and stock quantity.", isError: true);
                BindProduct(productId);
                BindVariants(productId);
                return;
            }

            string err = _svc.AddVariant(productId, type, value, price, stock);
            if (err != null)
            {
                ShowVarMsg(err, isError: true);
                BindProduct(productId);
                BindVariants(productId);
                return;
            }

            Response.Redirect("onyx_admin_product_detail.aspx?id=" + productId + "&vmsg=added");
        }

        private void ShowVarMsg(string message, bool isError)
        {
            pnlVarMsg.Visible = true;
            varMsgBox.Attributes["class"] = "var-alert " + (isError ? "var-alert-error" : "var-alert-success");
            varMsgBox.InnerHtml = System.Web.HttpUtility.HtmlEncode(message);
        }

        private void ShowNotFound()
        {
            pnlDetail.Visible   = false;
            pnlNotFound.Visible = true;
        }
    }
}

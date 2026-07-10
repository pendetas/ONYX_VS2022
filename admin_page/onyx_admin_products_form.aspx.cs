using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
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
        private const int MaxProductImageBytes = 5 * 1024 * 1024;
        private const int MaxCampaignMediaBytes = 20 * 1024 * 1024;
        private static readonly string[] AllowedProductImageExtensions = { ".jpg", ".jpeg", ".png", ".webp" };
        private static readonly string[] AllowedProductImageContentTypes = { "image/jpeg", "image/png", "image/webp" };
        private static readonly string[] AllowedCampaignMediaExtensions = { ".jpg", ".jpeg", ".png", ".webp", ".gif", ".mp4" };
        private static readonly string[] AllowedCampaignMediaContentTypes = { "image/jpeg", "image/png", "image/webp", "image/gif", "video/mp4" };

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

        private IList<ProductCampaignBlock> PendingCampaignBlocks
        {
            get
            {
                var blocks = ViewState["PendingCampaignBlocks"] as IList<ProductCampaignBlock>;
                if (blocks == null)
                {
                    blocks = new List<ProductCampaignBlock>();
                    ViewState["PendingCampaignBlocks"] = blocks;
                }

                return blocks;
            }
            set { ViewState["PendingCampaignBlocks"] = value; }
        }

        private long NextPendingCampaignBlockId
        {
            get { return ViewState["NextPendingCampaignBlockId"] == null ? -1L : (long)ViewState["NextPendingCampaignBlockId"]; }
            set { ViewState["NextPendingCampaignBlockId"] = value; }
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
                    LoadCampaign(_EditId);
                    BindColors(_EditId);

                    string vmsg = Request.QueryString["vmsg"];
                    if (vmsg == "cvsaved")  ShowAlert("Color variant updated.");
                    if (vmsg == "cadded")   ShowAlert("Color variant added.");
                    if (vmsg == "cdeleted") ShowAlert("Color variant removed.");
                }
                else
                {
                    BindExistingProductImages(0);
                    BindCampaignBlocks(0);
                }
            }

            btnDelete.Visible = IsEditMode;
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

            _svc.EnsureProductImageRows(id, p.ImageUrl);
            BindExistingProductImages(id);

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

        private void LoadCampaign(long productId)
        {
            ProductCampaign campaign = _svc.GetProductCampaign(productId);
            BindCampaignBlocks(productId);
            if (campaign == null)
            {
                chkCampaignEnabled.Checked = false;
                return;
            }

            chkCampaignEnabled.Checked = campaign.CampaignEnabled;
        }

        private void BindCampaignBlocks(long productId)
        {
            IList<ProductCampaignBlock> blocks = IsEditMode
                ? _svc.GetCampaignBlocksByProductId(productId)
                : PendingCampaignBlocks;
            rptCampaignBlocks.DataSource = blocks;
            rptCampaignBlocks.DataBind();
            pnlCampaignBlocksEmpty.Visible = blocks.Count == 0;
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

            if (string.IsNullOrWhiteSpace(name))
            { ShowAlert("Product name is required.", isError: true); return; }

            if (string.IsNullOrWhiteSpace(category))
            { ShowAlert("Category is required.", isError: true); return; }

            if (price < 0)
            { ShowAlert("Price must be 0 or greater.", isError: true); return; }

            if (stock < 0)
            { ShowAlert("Stock quantity must be 0 or greater.", isError: true); return; }

            try
            {
                IList<string> imageOrderTokens = ParseImageOrderTokens(ProductImageOrder.Value);
                ISet<long> removedImageIds = ParseRemovedProductImageIds(RemovedProductImages.Value);
                ISet<int> selectedNewImageIndexes = ParseSelectedNewImageIndexes(imageOrderTokens);
                List<string> uploadedImagePaths = SaveUploadedProductImages(selectedNewImageIndexes);
                string fallbackImageUrl = txtImageUrl.Text.Trim();

                if (IsEditMode)
                {
                    Product existingProduct = _svc.GetProductById(_EditId);
                    if (existingProduct != null)
                        _svc.EnsureProductImageRows(_EditId, existingProduct.ImageUrl);

                    _svc.UpdateProduct(_EditId, name, brand, category, desc, price, stock, fallbackImageUrl);
                    _svc.SaveProductImages(_EditId, imageOrderTokens, removedImageIds, uploadedImagePaths, fallbackImageUrl);
                    _svc.SaveProductCampaign(BuildCampaignFromForm(_EditId));
                    SaveCampaignBlocksFromRepeater(_EditId);
                    Response.Redirect("onyx_admin_product_detail.aspx?id=" + _EditId + "&vmsg=updated");
                }
                else
                {
                    long newId = _svc.CreateProduct(name, brand, category, desc, price, stock, string.Empty);
                    _svc.SaveProductImages(newId, imageOrderTokens, removedImageIds, uploadedImagePaths, fallbackImageUrl);
                    _svc.SaveProductCampaign(BuildCampaignFromForm(newId));
                    PersistPendingCampaignBlocks(newId);
                    CreateColorVariantsForNewProduct(newId, price, stock);
                    Response.Redirect("onyx_admin_product_detail.aspx?id=" + newId + "&vmsg=created");
                }
            }
            catch (ArgumentException ex)
            {
                ShowAlert(ex.Message, isError: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin product save failed: {0}", ex);
                ShowAlert("The product could not be saved. Please try again.", isError: true);
            }
        }

        private ProductCampaign BuildCampaignFromForm(long productId)
        {
            return new ProductCampaign
            {
                ProductId = productId,
                CampaignEnabled = chkCampaignEnabled.Checked
            };
        }

        protected void btnAddCampaignBlock_Click(object sender, EventArgs e)
        {
            if (IsEditMode)
            {
                string error = _svc.AddCampaignBlock(_EditId, ddlCampaignBlockType.SelectedValue);
                if (!string.IsNullOrWhiteSpace(error))
                {
                    ShowAlert(error, isError: true);
                    return;
                }
            }
            else
            {
                IList<ProductCampaignBlock> blocks = PendingCampaignBlocks;
                blocks.Add(new ProductCampaignBlock
                {
                    Id = NextPendingCampaignBlockId,
                    ProductId = 0,
                    BlockType = ddlCampaignBlockType.SelectedValue,
                    SortOrder = blocks.Count + 1,
                    IsEnabled = true
                });
                NextPendingCampaignBlockId = NextPendingCampaignBlockId - 1;
                PendingCampaignBlocks = blocks;
            }

            BindCampaignBlocks(_EditId);
            ShowAlert("Campaign block added.");
        }

        protected void rptCampaignBlocks_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            long blockId;
            if (!long.TryParse(e.CommandArgument?.ToString(), out blockId)) return;

            if (!IsEditMode)
            {
                HandlePendingCampaignBlockCommand(e, blockId);
                BindCampaignBlocks(0);
                return;
            }

            try
            {
                switch (e.CommandName)
                {
                    case "MoveUp":
                        _svc.MoveCampaignBlockUp(blockId, _EditId);
                        ShowAlert("Campaign block moved up.");
                        break;
                    case "MoveDown":
                        _svc.MoveCampaignBlockDown(blockId, _EditId);
                        ShowAlert("Campaign block moved down.");
                        break;
                    case "DeleteBlock":
                        _svc.DeleteCampaignBlock(blockId, _EditId);
                        ShowAlert("Campaign block deleted.");
                        break;
                    case "SaveBlock":
                        string error = _svc.UpdateCampaignBlock(BuildCampaignBlockFromRepeaterItem(blockId, e.Item, _EditId));
                        ShowAlert(string.IsNullOrWhiteSpace(error) ? "Campaign block saved." : error, isError: !string.IsNullOrWhiteSpace(error));
                        break;
                }
            }
            catch (ArgumentException ex)
            {
                ShowAlert(ex.Message, isError: true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Admin campaign block action failed: {0}", ex);
                ShowAlert("The campaign block could not be updated. Please try again.", isError: true);
            }

            BindCampaignBlocks(_EditId);
        }

        private void HandlePendingCampaignBlockCommand(RepeaterCommandEventArgs e, long blockId)
        {
            IList<ProductCampaignBlock> blocks = PendingCampaignBlocks;
            ProductCampaignBlock block = blocks.FirstOrDefault(candidate => candidate.Id == blockId);
            if (block == null) return;

            switch (e.CommandName)
            {
                case "MoveUp":
                    MovePendingCampaignBlock(blocks, blockId, -1);
                    ShowAlert("Campaign block moved up.");
                    break;
                case "MoveDown":
                    MovePendingCampaignBlock(blocks, blockId, 1);
                    ShowAlert("Campaign block moved down.");
                    break;
                case "DeleteBlock":
                    blocks.Remove(block);
                    NormalizePendingCampaignBlockSortOrder(blocks);
                    ShowAlert("Campaign block deleted.");
                    break;
                case "SaveBlock":
                    ProductCampaignBlock updated = BuildCampaignBlockFromRepeaterItem(blockId, e.Item, 0);
                    int index = blocks.IndexOf(block);
                    updated.SortOrder = block.SortOrder;
                    blocks[index] = updated;
                    ShowAlert("Campaign block saved.");
                    break;
            }

            PendingCampaignBlocks = blocks;
        }

        private static void MovePendingCampaignBlock(IList<ProductCampaignBlock> blocks, long blockId, int direction)
        {
            int index = blocks.ToList().FindIndex(block => block.Id == blockId);
            int targetIndex = index + direction;
            if (index < 0 || targetIndex < 0 || targetIndex >= blocks.Count) return;

            ProductCampaignBlock item = blocks[index];
            blocks.RemoveAt(index);
            blocks.Insert(targetIndex, item);
            NormalizePendingCampaignBlockSortOrder(blocks);
        }

        private static void NormalizePendingCampaignBlockSortOrder(IList<ProductCampaignBlock> blocks)
        {
            for (int i = 0; i < blocks.Count; i++)
            {
                blocks[i].SortOrder = i + 1;
            }
        }

        private void SaveCampaignBlocksFromRepeater(long productId)
        {
            foreach (RepeaterItem item in rptCampaignBlocks.Items)
            {
                if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem) continue;
                HiddenField hfBlockId = item.FindControl("hfCampaignBlockId") as HiddenField;
                long blockId;
                if (hfBlockId == null || !long.TryParse(hfBlockId.Value, out blockId)) continue;
                string error = _svc.UpdateCampaignBlock(BuildCampaignBlockFromRepeaterItem(blockId, item, productId));
                if (!string.IsNullOrWhiteSpace(error)) throw new ArgumentException(error);
            }
        }

        private void PersistPendingCampaignBlocks(long productId)
        {
            foreach (RepeaterItem item in rptCampaignBlocks.Items)
            {
                if (item.ItemType != ListItemType.Item && item.ItemType != ListItemType.AlternatingItem) continue;
                HiddenField hfBlockId = item.FindControl("hfCampaignBlockId") as HiddenField;
                long blockId;
                if (hfBlockId == null || !long.TryParse(hfBlockId.Value, out blockId)) continue;

                ProductCampaignBlock block = BuildCampaignBlockFromRepeaterItem(blockId, item, productId);
                string error = _svc.AddCampaignBlock(block);
                if (!string.IsNullOrWhiteSpace(error)) throw new ArgumentException(error);
            }

            _svc.EnsureSortOrderIntegrity(productId);
        }

        private ProductCampaignBlock BuildCampaignBlockFromRepeaterItem(long blockId, RepeaterItem item, long productId)
        {
            var chkBlockEnabled = (CheckBox)item.FindControl("chkBlockEnabled");
            var hfCampaignBlockType = (HiddenField)item.FindControl("hfCampaignBlockType");
            var txtBlockEyebrow = (TextBox)item.FindControl("txtBlockEyebrow");
            var txtBlockHeadline = (TextBox)item.FindControl("txtBlockHeadline");
            var txtBlockBody = (TextBox)item.FindControl("txtBlockBody");
            var txtBlockMediaType = (TextBox)item.FindControl("txtBlockMediaType");
            var txtBlockMediaUrl = (TextBox)item.FindControl("txtBlockMediaUrl");
            var txtBlockMediaAlt = (TextBox)item.FindControl("txtBlockMediaAlt");
            var txtBlockLayoutVariant = (TextBox)item.FindControl("txtBlockLayoutVariant");
            var txtBlockBackgroundVariant = (TextBox)item.FindControl("txtBlockBackgroundVariant");
            var txtBlockJsonContent = (TextBox)item.FindControl("txtBlockJsonContent");
            var chkRemoveBlockMedia = (CheckBox)item.FindControl("chkRemoveBlockMedia");
            var mediaUpload = (FileUpload)item.FindControl("CampaignBlockMediaUpload");

            string mediaUrl = txtBlockMediaUrl.Text;
            string mediaType = txtBlockMediaType.Text;
            if (chkRemoveBlockMedia != null && chkRemoveBlockMedia.Checked)
            {
                mediaUrl = string.Empty;
            }
            else if (mediaUpload != null && mediaUpload.HasFile)
            {
                mediaUrl = SaveUploadedCampaignBlockMedia(mediaUpload.PostedFile);
                mediaType = GetCampaignMediaTypeFromPath(mediaUrl);
            }

            return new ProductCampaignBlock
            {
                Id = blockId,
                ProductId = productId,
                BlockType = hfCampaignBlockType.Value,
                IsEnabled = chkBlockEnabled.Checked,
                Eyebrow = txtBlockEyebrow.Text,
                Headline = txtBlockHeadline.Text,
                Body = txtBlockBody.Text,
                MediaType = mediaType,
                MediaUrl = mediaUrl,
                MediaAlt = txtBlockMediaAlt.Text,
                LayoutVariant = txtBlockLayoutVariant.Text,
                BackgroundVariant = txtBlockBackgroundVariant.Text,
                JsonContent = txtBlockJsonContent.Text
            };
        }

        protected string GetCampaignBlockLabel(object dataItem)
        {
            var block = dataItem as ProductCampaignBlock;
            if (block == null) return "Untitled block";

            string label = FirstText(block.Headline, block.Eyebrow, block.MediaAlt, block.Body, block.JsonContent);
            if (string.IsNullOrWhiteSpace(label)) return block.IsEnabled ? "Untitled block" : "Disabled block";
            label = label.Replace("\r", " ").Replace("\n", " ").Trim();
            return label.Length > 90 ? label.Substring(0, 87) + "..." : label;
        }

        protected string GetCampaignBlockMediaPreview(object dataItem)
        {
            var block = dataItem as ProductCampaignBlock;
            if (block == null || string.IsNullOrWhiteSpace(block.MediaUrl)) return string.Empty;

            string url = ResolveImageDisplayUrl(block.MediaUrl);
            string encodedUrl = HttpUtility.HtmlAttributeEncode(url);
            string label = Server.HtmlEncode(block.MediaAlt ?? block.MediaUrl);
            string mediaType = (block.MediaType ?? string.Empty).Trim().ToLowerInvariant();
            if (mediaType == "mp4" || url.EndsWith(".mp4", StringComparison.OrdinalIgnoreCase))
            {
                return "<video src=\"" + encodedUrl + "\" muted playsinline></video><span>" + label + "</span>";
            }

            return "<img src=\"" + encodedUrl + "\" alt=\"" + label + "\" /><span>" + label + "</span>";
        }

        private string SaveUploadedCampaignBlockMedia(HttpPostedFile postedFile)
        {
            if (postedFile == null || postedFile.ContentLength <= 0) return string.Empty;
            if (postedFile.ContentLength > MaxCampaignMediaBytes)
                throw new ArgumentException("Campaign media must be 20 MB or smaller.");

            string extension = Path.GetExtension(postedFile.FileName ?? string.Empty).ToLowerInvariant();
            if (!AllowedCampaignMediaExtensions.Contains(extension))
                throw new ArgumentException("Campaign media must be JPG, PNG, WEBP, GIF, or MP4.");

            string contentType = (postedFile.ContentType ?? string.Empty).ToLowerInvariant();
            if (!AllowedCampaignMediaContentTypes.Contains(contentType, StringComparer.OrdinalIgnoreCase))
                throw new ArgumentException("Campaign media type is not supported.");

            string uploadRoot = Server.MapPath("~/Content/uploads/products");
            Directory.CreateDirectory(uploadRoot);
            string fileName = "campaign-" + Guid.NewGuid().ToString("N") + extension;
            string physicalPath = Path.Combine(uploadRoot, fileName);
            postedFile.SaveAs(physicalPath);
            return "/Content/uploads/products/" + fileName;
        }

        private static string GetCampaignMediaTypeFromPath(string mediaUrl)
        {
            string extension = Path.GetExtension(mediaUrl ?? string.Empty).ToLowerInvariant();
            return extension == ".mp4" ? "mp4" : extension == ".gif" ? "gif" : "image";
        }

        private static string FirstText(params string[] values)
        {
            foreach (string value in values)
                if (!string.IsNullOrWhiteSpace(value))
                    return value.Trim();

            return string.Empty;
        }

        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (!IsEditMode)
            {
                ShowAlert("Product not found.", isError: true);
                return;
            }

            string error = _svc.DeleteProduct(_EditId);
            if (!string.IsNullOrWhiteSpace(error))
            {
                ShowAlert(error, isError: true);
                return;
            }

            Response.Redirect("onyx_admin_products.aspx?msg=deleted");
        }

        private void BindExistingProductImages(long productId)
        {
            List<ProductImage> images = productId > 0
                ? _svc.GetProductImages(productId)
                : new List<ProductImage>();

            var payload = images
                .OrderBy(image => image.DisplayOrder)
                .ThenBy(image => image.Id)
                .Select((image, index) => new
                {
                    Id = image.Id,
                    Url = ResolveImageDisplayUrl(image.ImagePath),
                    ImagePath = image.ImagePath,
                    Label = "Existing image",
                    IsPrimary = index == 0 || image.IsPrimary
                })
                .ToList();

            ExistingProductImagesJson.Value = new JavaScriptSerializer().Serialize(payload);
            ProductImageOrder.Value = string.Join(",", images
                .OrderBy(image => image.DisplayOrder)
                .ThenBy(image => image.Id)
                .Select(image => "existing:" + image.Id.ToString(CultureInfo.InvariantCulture)));
            RemovedProductImages.Value = string.Empty;
        }

        private string ResolveImageDisplayUrl(string imagePath)
        {
            if (string.IsNullOrWhiteSpace(imagePath)) return string.Empty;
            if (imagePath.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                imagePath.StartsWith("https://", StringComparison.OrdinalIgnoreCase) ||
                imagePath.StartsWith("/", StringComparison.Ordinal))
                return imagePath;

            return ResolveUrl(imagePath);
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

        private List<string> SaveUploadedProductImages(ISet<int> selectedNewImageIndexes)
        {
            var savedPaths = new List<string>();
            if (!ProductImageUpload.HasFiles) return savedPaths;

            string uploadFolder = Server.MapPath("~/Content/uploads/products/");
            Directory.CreateDirectory(uploadFolder);
            string safeUploadFolder = Path.GetFullPath(uploadFolder);

            for (int index = 0; index < ProductImageUpload.PostedFiles.Count; index++)
            {
                while (savedPaths.Count <= index)
                    savedPaths.Add(null);

                if (selectedNewImageIndexes == null || !selectedNewImageIndexes.Contains(index))
                    continue;

                HttpPostedFile postedFile = ProductImageUpload.PostedFiles[index];
                if (postedFile == null || postedFile.ContentLength <= 0) continue;

                if (postedFile.ContentLength > MaxProductImageBytes)
                    throw new ArgumentException("Each product image must be 5 MB or smaller.");

                string extension = Path.GetExtension(postedFile.FileName).ToLowerInvariant();
                if (!AllowedProductImageExtensions.Contains(extension))
                    throw new ArgumentException("Only JPG, JPEG, PNG, and WEBP product images are allowed.");

                string contentType = postedFile.ContentType ?? string.Empty;
                if (!AllowedProductImageContentTypes.Contains(contentType, StringComparer.OrdinalIgnoreCase))
                    throw new ArgumentException("Only JPG, JPEG, PNG, and WEBP product images are allowed.");

                string fileName = "product-" + Guid.NewGuid().ToString("N") + extension;
                string path = Path.GetFullPath(Path.Combine(safeUploadFolder, fileName));
                if (!path.StartsWith(safeUploadFolder, StringComparison.OrdinalIgnoreCase))
                    throw new ArgumentException("Invalid product image path.");

                postedFile.SaveAs(path);
                savedPaths[index] = ResolveUrl("~/Content/uploads/products/" + fileName);
            }

            return savedPaths;
        }

        private IList<string> ParseImageOrderTokens(string rawValue)
        {
            return (rawValue ?? string.Empty)
                .Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries)
                .Select(value => value.Trim())
                .Where(value =>
                    value.StartsWith("existing:", StringComparison.OrdinalIgnoreCase) ||
                    value.StartsWith("new:", StringComparison.OrdinalIgnoreCase))
                .ToList();
        }

        private ISet<int> ParseSelectedNewImageIndexes(IList<string> imageOrderTokens)
        {
            var indexes = new HashSet<int>();
            foreach (string token in imageOrderTokens ?? new List<string>())
            {
                if (!token.StartsWith("new:", StringComparison.OrdinalIgnoreCase)) continue;

                int index;
                if (int.TryParse(token.Substring("new:".Length), out index) && index >= 0)
                    indexes.Add(index);
            }
            return indexes;
        }

        private ISet<long> ParseRemovedProductImageIds(string rawValue)
        {
            var removedIds = new HashSet<long>();
            foreach (string rawId in (rawValue ?? string.Empty).Split(new[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                long id;
                if (long.TryParse(rawId.Trim(), out id) && id > 0)
                    removedIds.Add(id);
            }
            return removedIds;
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

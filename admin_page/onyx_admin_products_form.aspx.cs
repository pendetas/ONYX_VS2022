using System;
using System.Web.UI;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_products_form : Page
    {
        // True when a product ID is supplied via query string (?id=N)
        private bool _isEditMode = false;
        private long _editId = 0;

        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string idParam = Request.QueryString["id"];
                if (!string.IsNullOrWhiteSpace(idParam) && long.TryParse(idParam, out _editId))
                {
                    _isEditMode = true;
                    LoadMockProduct(_editId);
                }

                UpdatePageLabels();
            }
        }

        // =====================================================================
        //  MOCK DATA LOAD  (replace with ProductService.GetById when DB ready)
        // =====================================================================

        /// <summary>
        /// Pre-fills the form with hardcoded product data that matches the seed data
        /// in the PRD (Section 13). Simulates ProductRepository.GetById(id).
        /// </summary>
        private void LoadMockProduct(long id)
        {
            // Mirrors the seed data from PRD §13
            var catalog = new[]
            {
                new { Id = 1L,  Name = "Viper V2 Pro",    Brand = "Razer",     Category = "Mouse",    Price = "599.00",   Stock = "23", Url = "",  Desc = "Ultra-lightweight wireless gaming mouse with advanced optical sensor."           },
                new { Id = 2L,  Name = "BlackWidow V3",   Brand = "Razer",     Category = "Keyboard", Price = "449.00",   Stock = "15", Url = "",  Desc = "Mechanical gaming keyboard with Razer Green switches and RGB lighting."           },
                new { Id = 3L,  Name = "Kraken X",        Brand = "Razer",     Category = "Headset",  Price = "299.00",   Stock = "31", Url = "",  Desc = "7.1 surround sound gaming headset with ultra-light frame design."                  },
                new { Id = 4L,  Name = "DeathAdder V3",   Brand = "Razer",     Category = "Mouse",    Price = "349.00",   Stock = "4",  Url = "",  Desc = "Ergonomic wired gaming mouse optimised for claw and palm grip styles."             },
                new { Id = 5L,  Name = "Huntsman Mini",   Brand = "Razer",     Category = "Keyboard", Price = "529.00",   Stock = "10", Url = "",  Desc = "60% compact gaming keyboard with optical switches for lightning-fast actuation."   },
                new { Id = 6L,  Name = "Predator XB273U", Brand = "Acer",      Category = "Monitor",  Price = "1899.00",  Stock = "8",  Url = "",  Desc = "27-inch 165Hz IPS gaming monitor with G-Sync compatibility and HDR support."      },
                new { Id = 7L,  Name = "Secretlab Titan", Brand = "Secretlab", Category = "Chair",    Price = "2199.00",  Stock = "5",  Url = "",  Desc = "Ergonomic gaming chair with lumbar support and magnetic memory foam pillow."       },
                new { Id = 8L,  Name = "G502 X Plus",     Brand = "Logitech",  Category = "Mouse",    Price = "499.00",   Stock = "18", Url = "",  Desc = "HERO sensor wireless gaming mouse with 100-hour battery and LIGHTFORCE switches."  }
            };

            foreach (var p in catalog)
            {
                if (p.Id != id) continue;

                txtName.Text = p.Name;
                txtBrand.Text = p.Brand;
                txtPrice.Text = p.Price;
                txtStock.Text = p.Stock;
                txtImageUrl.Text = p.Url;
                txtDescription.Text = p.Desc;
                ddlCategory.SelectedValue = p.Category;
                return;
            }

            // Product ID not found — treat as add-new
            _isEditMode = false;
        }

        // =====================================================================
        //  UI HELPERS
        // =====================================================================

        private void UpdatePageLabels()
        {
            if (_isEditMode)
            {
                litPageTitle.Text = "Edit Product";
                litPageSubtitle.Text = "Update the details for this product. Changes are saved immediately.";
            }
            else
            {
                litPageTitle.Text = "Add New Product";
                litPageSubtitle.Text = "Fill in the details below to add a new product to the catalog.";
            }
        }

        private void ShowAlert(string message, bool isError = false)
        {
            pnlAlert.CssClass = isError ? "alert-panel alert-error-dark" : "alert-panel alert-success-dark";
            litAlertMessage.Text = message;
            pnlAlert.Visible = true;
        }

        // =====================================================================
        //  EVENT HANDLERS
        // =====================================================================

        protected void btnSave_Click(object sender, EventArgs e)
        {
            // --- Validation ---
            if (string.IsNullOrWhiteSpace(txtName.Text))
            {
                ShowAlert("Product name is required.", isError: true);
                return;
            }

            if (ddlCategory.SelectedIndex == 0)
            {
                ShowAlert("Please select a category.", isError: true);
                return;
            }

            if (!decimal.TryParse(txtPrice.Text, out decimal price) || price < 0)
            {
                ShowAlert("Please enter a valid price (must be 0 or greater).", isError: true);
                return;
            }

            if (!int.TryParse(txtStock.Text, out int stock) || stock < 0)
            {
                ShowAlert("Please enter a valid stock quantity (must be 0 or greater).", isError: true);
                return;
            }

            // --- Simulate save (replace with ProductService.Save() when DB is ready) ---
            string action = _isEditMode ? "updated" : "added to the catalog";
            ShowAlert($"\"{txtName.Text}\" has been {action} successfully.");

            if (!_isEditMode)
            {
                // Clear form for the next product entry
                txtName.Text = string.Empty;
                txtBrand.Text = string.Empty;
                txtPrice.Text = string.Empty;
                txtStock.Text = string.Empty;
                txtImageUrl.Text = string.Empty;
                txtDescription.Text = string.Empty;
                ddlCategory.SelectedIndex = 0;
            }
        }
    }
}
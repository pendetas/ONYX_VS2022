using System;
using System.Collections.Generic;
using System.Web.UI;

namespace ONYX_DDAC.admin_page
{
    public partial class onyx_admin_promos : System.Web.UI.Page
    {
        // =====================================================================
        //  PAGE LIFECYCLE
        // =====================================================================

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindPromos();
            }
        }

        // =====================================================================
        //  DATA BINDING  (replace with PromoRepository.GetAll() when DB ready)
        // =====================================================================

        private void BindPromos()
        {
            // UsagePct is computed as (Uses / Limit) * 100 for the mini progress bar
            var mockPromos = new List<object>
            {
                new { Code = "ONYX20",    Discount = "20% OFF",        Type = "Percentage", Uses = 87,  Limit = "200", UsagePct = 44, Expiry = "31 Dec 2026", ExpiryClass = "expiry-normal",   Status = "Active",  StatusKey = "active"  },
                new { Code = "WELCOME10", Discount = "10% OFF",        Type = "Percentage", Uses = 312, Limit = "500", UsagePct = 62, Expiry = "31 Dec 2026", ExpiryClass = "expiry-normal",   Status = "Active",  StatusKey = "active"  },
                new { Code = "GEAR50",    Discount = "RM 50 OFF",      Type = "Fixed",      Uses = 45,  Limit = "100", UsagePct = 45, Expiry = "15 Jun 2026", ExpiryClass = "expiry-warning",  Status = "Active",  StatusKey = "active"  },
                new { Code = "FREESHIP",  Discount = "Free Shipping",  Type = "Shipping",   Uses = 62,  Limit = "150", UsagePct = 41, Expiry = "30 Jun 2026", ExpiryClass = "expiry-normal",   Status = "Active",  StatusKey = "active"  },
                new { Code = "LAUNCH25",  Discount = "25% OFF",        Type = "Percentage", Uses = 200, Limit = "200", UsagePct = 100,Expiry = "1 Jun 2026",  ExpiryClass = "expiry-expired",  Status = "Expired", StatusKey = "expired" },
                new { Code = "FLASH30",   Discount = "30% OFF",        Type = "Percentage", Uses = 300, Limit = "300", UsagePct = 100,Expiry = "20 May 2026", ExpiryClass = "expiry-expired",  Status = "Expired", StatusKey = "expired" }
            };

            PromosRepeater.DataSource = mockPromos;
            PromosRepeater.DataBind();

            // Stat strip
            litActiveCount.Text = "4";
            litTotalUses.Text = "1,006";
            litSavingsGiven.Text = "RM 14,320";
        }
    }
}
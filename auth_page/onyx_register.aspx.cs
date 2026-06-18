using System;
using System.Configuration;
using System.Globalization;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.WebControls;
using ONYX_DDAC.Helpers;
using ONYX_DDAC.Models;
using ONYX_DDAC.Services;

namespace ONYX_DDAC.auth_page
{
    public partial class onyx_register : Page
    {
        private const string PendingEmailSessionKey = "PendingRegistrationEmail";
        private readonly AuthService _authService = new AuthService();

        protected string TurnstileSiteKey { get; private set; }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);
            ViewStateUserKey = AuthHelper.GetOrCreateViewStateUserKey(this);
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            TurnstileSiteKey =
                ConfigurationManager.AppSettings["TurnstileSiteKey"] ?? string.Empty;

            if (Session["UserId"] != null)
            {
                RedirectAuthenticatedUser();
                return;
            }

            if (!IsPostBack)
                ShowRegistrationPanel();
        }

        protected async void btnRegister_Click(object sender, EventArgs e)
        {
            DateTime dob;
            if (!DateTime.TryParseExact(
                    txtDob.Text,
                    "yyyy-MM-dd",
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out dob))
            {
                ShowRegistrationPanel();
                ShowMessage("Please enter a valid date of birth.", false);
                return;
            }

            RegistrationRequest request = new RegistrationRequest
            {
                FullName = txtFullName.Text,
                Username = txtUsername.Text,
                Email = txtEmail.Text,
                PhoneNumber = txtPhone.Text,
                Address = txtAddress.Text,
                Password = txtPassword.Text,
                ConfirmPassword = txtConfirmPassword.Text,
                Dob = dob
            };

            string captchaToken = Request.Form["cf-turnstile-response"];
            string error = await _authService.StartRegistrationAsync(
                request,
                captchaToken,
                Request.UserHostAddress);

            if (error != null)
            {
                ShowRegistrationPanel();
                ShowMessage(error, false);
                return;
            }

            Session[PendingEmailSessionKey] = request.Email;
            litOtpDestination.Text = Server.HtmlEncode(MaskEmail(request.Email));
            txtOtp.Text = string.Empty;
            ShowOtpPanel();
            ShowMessage("Verification code sent. Check your email.", true);
        }

        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            string email = Session[PendingEmailSessionKey] as string;
            if (string.IsNullOrWhiteSpace(email))
            {
                ShowRegistrationPanel();
                ShowMessage("Your registration session expired. Please start again.", false);
                return;
            }

            string error = _authService.VerifyRegistrationOtp(
                email,
                txtOtp.Text.Trim(),
                Request.UserHostAddress);

            if (error != null)
            {
                ShowOtpPanel();
                ShowMessage(error, false);
                return;
            }

            Session.Remove(PendingEmailSessionKey);
            Response.Redirect("onyx_login.aspx?registered=true", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected async void btnResendOtp_Click(object sender, EventArgs e)
        {
            string email = Session[PendingEmailSessionKey] as string;
            if (string.IsNullOrWhiteSpace(email))
            {
                ShowRegistrationPanel();
                ShowMessage("Your registration session expired. Please start again.", false);
                return;
            }

            string error = await _authService.ResendRegistrationOtpAsync(
                email,
                Request.UserHostAddress);

            ShowOtpPanel();
            ShowMessage(
                error ?? "A new verification code was sent.",
                error == null);
        }

        protected void btnStartOver_Click(object sender, EventArgs e)
        {
            string email = Session[PendingEmailSessionKey] as string;
            try
            {
                _authService.CancelPendingRegistration(email);
            }
            catch (Exception exception)
            {
                System.Diagnostics.Trace.TraceWarning(
                    "Pending registration cleanup failed: " + exception.GetType().Name);
            }

            Session.Remove(PendingEmailSessionKey);
            ClearRegistrationForm();
            ShowRegistrationPanel();
            ShowMessage("You can enter your registration details again.", true);
        }

        private void ShowRegistrationPanel()
        {
            pnlRegistration.CssClass = string.Empty;
            pnlOtpVerification.CssClass = "server-hidden";
            lblOtpMessage.Visible = false;
        }

        private void ShowOtpPanel()
        {
            pnlRegistration.CssClass = "server-hidden";
            pnlOtpVerification.CssClass = string.Empty;
            lblMessage.Visible = false;

            string email = Session[PendingEmailSessionKey] as string;
            litOtpDestination.Text = Server.HtmlEncode(MaskEmail(email));
        }

        private void ClearRegistrationForm()
        {
            txtFullName.Text = string.Empty;
            txtUsername.Text = string.Empty;
            txtEmail.Text = string.Empty;
            txtPhone.Text = string.Empty;
            txtPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
            txtDob.Text = string.Empty;
            txtAddress.Text = string.Empty;
            txtOtp.Text = string.Empty;
        }

        private void RedirectAuthenticatedUser()
        {
            string target = string.Equals(
                Session["Role"] as string,
                "admin",
                StringComparison.OrdinalIgnoreCase)
                ? "~/admin_page/onyx_admin_dashboard.aspx"
                : "~/customer_page/onyx_catalog.aspx";

            Response.Redirect(target, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string MaskEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email))
                return "your email address";

            int atIndex = email.IndexOf('@');
            if (atIndex <= 1)
                return "***" + email.Substring(Math.Max(0, atIndex));

            return email.Substring(0, 1) +
                   new string('*', Math.Min(5, atIndex - 1)) +
                   email.Substring(atIndex);
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            Label target = pnlOtpVerification.CssClass == string.Empty
                ? lblOtpMessage
                : lblMessage;

            target.Text =
                "<span class=\"auth-alert\" style=\"color: " +
                (isSuccess ? "#c0c0c0" : "#ff4444") +
                ";\">" +
                Server.HtmlEncode(message) +
                "</span>";
            target.Visible = true;
        }
    }
}

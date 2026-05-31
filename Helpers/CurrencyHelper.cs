using System.Globalization;

namespace ONYX_DDAC.Helpers
{
    public static class CurrencyHelper
    {
        private static readonly CultureInfo MalaysiaCulture = new CultureInfo("ms-MY");

        public static string FormatMyr(decimal amount)
        {
            return string.Format(MalaysiaCulture, "RM {0:N2}", amount);
        }
    }
}

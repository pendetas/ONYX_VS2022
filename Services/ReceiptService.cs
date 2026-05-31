namespace ONYX_DDAC.Services
{
    public class ReceiptService
    {
        public string GetReceiptKey(long orderId)
        {
            return "receipts/" + orderId + ".json";
        }
    }
}

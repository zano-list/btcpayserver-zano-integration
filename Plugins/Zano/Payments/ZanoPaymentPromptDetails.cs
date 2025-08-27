namespace BTCPayServer.Plugins.Zano.Payments
{
    public class ZanoPaymentPromptDetails
    {
        public string AccountAddress { get; set; }
        public long? InvoiceSettledConfirmationThreshold { get; set; }
    }
}
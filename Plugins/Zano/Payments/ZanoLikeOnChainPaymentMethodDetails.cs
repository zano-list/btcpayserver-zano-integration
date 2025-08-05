namespace BTCPayServer.Plugins.Zano.Payments
{
    public class ZanoLikeOnChainPaymentMethodDetails
    {
        public string AccountAddres { get; set; }
        //public string AddressIndex { get; set; }
        public long? InvoiceSettledConfirmationThreshold { get; set; }
    }
}
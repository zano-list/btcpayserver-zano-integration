using Newtonsoft.Json;

namespace BTCPayServer.Plugins.Zano.RPC.Models
{
    public partial class CreateAddressRequest
    {
        [JsonProperty("account_addres")] public string AccountIndex { get; set; }
        [JsonProperty("label")] public string Label { get; set; }
    }
}
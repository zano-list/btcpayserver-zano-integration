using Newtonsoft.Json;

namespace BTCPayServer.Plugins.Zano.RPC.Models
{
    public class GetFeeEstimateResponse
    {
        [JsonProperty("default_fee")] public long DefautlFee { get; set; }
        //[JsonProperty("status")] public string Status { get; set; }
        //[JsonProperty("untrusted")] public bool Untrusted { get; set; }
    }
}
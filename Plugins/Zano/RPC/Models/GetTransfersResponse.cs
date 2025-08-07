using System.Collections.Generic;

namespace BTCPayServer.Plugins.Zano.RPC.Models
{


    public class EmployedEntries
    {
        public List<Receive> receive { get; set; }
    }

    public class Pi
    {
        public long balance { get; set; }
        public int curent_height { get; set; }
        public int transfer_entries_count { get; set; }
        public int transfers_count { get; set; }
        public long unlocked_balance { get; set; }
    }

    public class Receive
    {
        public long amount { get; set; }
        public string asset_id { get; set; }
        public int index { get; set; }
    }

    public class GetTransfersResponse
    {
        public int last_item_index { get; set; }
        public Pi pi { get; set; }
        public long total_transfers { get; set; }
        public List<Transfer> transfers { get; set; }
    }

   

    public class ServiceEntry
    {
        public string body { get; set; }
        public int flags { get; set; }
        public string instruction { get; set; }
        public string security { get; set; }
        public string service_id { get; set; }
    }

    public class Subtransfer
    {
        public long amount { get; set; }
        public string asset_id { get; set; }
        public bool is_income { get; set; }
    }

    public class Transfer
    {
        public string comment { get; set; }
        public EmployedEntries employed_entries { get; set; }
        public object fee { get; set; }
        public int height { get; set; }
        public bool is_mining { get; set; }
        public bool is_mixing { get; set; }
        public bool is_service { get; set; }
        public string payment_id { get; set; }
        public List<string> remote_addresses { get; set; }
        public bool show_sender { get; set; }
        public List<Subtransfer> subtransfers { get; set; }
        public int timestamp { get; set; }
        public int transfer_internal_index { get; set; }
        public int tx_blob_size { get; set; }
        public string tx_hash { get; set; }
        public int tx_type { get; set; }
        public int unlock_time { get; set; }
        public List<ServiceEntry> service_entries { get; set; }
    }




    //public partial class GetTransfersResponse
    //{
    //    [JsonProperty("in")] public List<GetTransfersResponseItem> In { get; set; }
    //    [JsonProperty("out")] public List<GetTransfersResponseItem> Out { get; set; }
    //    [JsonProperty("pending")] public List<GetTransfersResponseItem> Pending { get; set; }
    //    [JsonProperty("failed")] public List<GetTransfersResponseItem> Failed { get; set; }
    //    [JsonProperty("pool")] public List<GetTransfersResponseItem> Pool { get; set; }

    //    public partial class GetTransfersResponseItem

    //    {
    //        [JsonProperty("address")] public string Address { get; set; }
    //        [JsonProperty("amount")] public long Amount { get; set; }
    //        [JsonProperty("confirmations")] public long Confirmations { get; set; }
    //        [JsonProperty("double_spend_seen")] public bool DoubleSpendSeen { get; set; }
    //        [JsonProperty("height")] public long Height { get; set; }
    //        [JsonProperty("note")] public string Note { get; set; }
    //        [JsonProperty("payment_id")] public string PaymentId { get; set; }
    //        [JsonProperty("subaddr_index")] public SubaddrIndex SubaddrIndex { get; set; }

    //        [JsonProperty("suggested_confirmations_threshold")]
    //        public long SuggestedConfirmationsThreshold { get; set; }

    //        [JsonProperty("timestamp")] public long Timestamp { get; set; }
    //        [JsonProperty("txid")] public string Txid { get; set; }
    //        [JsonProperty("type")] public string Type { get; set; }
    //        [JsonProperty("unlock_time")] public long UnlockTime { get; set; }
    //    }
    //}
}
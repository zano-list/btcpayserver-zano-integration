using BTCPayServer.Plugins.Zano.RPC;
using System.Reflection;

using Microsoft.AspNetCore.Mvc;

namespace BTCPayServer.Plugins.Zano.Controllers
{
    [Route("[controller]")]
    public class ZanoLikeDaemonCallbackController : Controller
    {
        private readonly EventAggregator _eventAggregator;

        public ZanoLikeDaemonCallbackController(EventAggregator eventAggregator)
        {
            _eventAggregator = eventAggregator;
        }
        [HttpGet("block")]
        public IActionResult OnBlockNotify(string hash, string cryptoCode)
        {
            _eventAggregator.Publish(new ZanoEvent()
            {
                BlockHash = hash,
                CryptoCode = cryptoCode.ToUpperInvariant()
            });
            return Ok();
        }
        [HttpGet("tx")]
        public IActionResult OnTransactionNotify(string hash, string cryptoCode)
        {
            _eventAggregator.Publish(new ZanoEvent()
            {
                TransactionHash = hash,
                CryptoCode = cryptoCode.ToUpperInvariant()
            });
            return Ok();
        }

        [HttpGet("zano.svg")]
        public IActionResult GetZanoSvg()
        {
            var assembly = Assembly.GetExecutingAssembly();
            var resourceName = "BTCPayServer.Plugins.Zano.zano.svg";
            
            using var stream = assembly.GetManifestResourceStream(resourceName);
            if (stream == null)
            {
                return NotFound();
            }
            
            return File(stream, "image/svg+xml");
        }
    }
}
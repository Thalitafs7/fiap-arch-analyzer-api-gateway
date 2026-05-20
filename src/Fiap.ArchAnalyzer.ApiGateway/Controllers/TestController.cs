using Microsoft.AspNetCore.Mvc;

namespace Fiap.ArchAnalyzer.ApiGateway.Controllers;

[ApiController]
[Route("[controller]")]
public class TestController : ControllerBase
{
    [HttpGet]
    public IActionResult Get()
    {
        return Ok(new { message = "API Gateway is working!" });
    }
}

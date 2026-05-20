using Microsoft.AspNetCore.Mvc;

namespace Fiap.ArchAnalyzer.ApiGateway.Controllers;

[ApiController]
[Route("[controller]")]
public class DiagramsController : ControllerBase
{
    [HttpPost]
    public IActionResult Upload(IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("No file uploaded.");

        var analysisId = Guid.NewGuid().ToString();

        // Logic to send file to Upload & Orchestration service would go here

        return Accepted(new { analysisId = analysisId, message = "Diagram received and analysis started." });
    }
}

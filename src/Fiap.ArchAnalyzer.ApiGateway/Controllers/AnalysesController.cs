using Microsoft.AspNetCore.Mvc;

namespace Fiap.ArchAnalyzer.ApiGateway.Controllers;

[ApiController]
[Route("[controller]")]
public class AnalysesController : ControllerBase
{
    [HttpGet("{id}/status")]
    public IActionResult GetStatus(string id)
    {
        // Status: Received, InProgress, Analyzed, Error
        return Ok(new
        {
            analysisId = id,
            status = "InProgress",
            message = "Diagram is being processed by IA."
        });
    }

    [HttpGet("{id}/report")]
    public IActionResult GetReport(string id)
    {
        return Ok(new
        {
            analysisId = id,
            components = new[] { "Web App", "API Gateway", "Microservices", "PostgreSQL" },
            risks = new[] { "Single point of failure in API Gateway", "Database not replicated" },
            recommendations = new[] { "Implement High Availability for Gateway", "Use RDS with Multi-AZ for PostgreSQL" }
        });
    }
}

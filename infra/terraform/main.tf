resource "aws_api_gateway_rest_api" "this" {
  name        = "${var.project_name}-api-gateway-${var.environment}"
  description = "API Gateway for Fiap Arch Analyzer"
}

# --- TEST RESOURCE ---
resource "aws_api_gateway_resource" "test" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "test"
}

resource "aws_api_gateway_method" "test_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.test.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "test_integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.test_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "test_response_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.test_get.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "test_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.test.id
  http_method = aws_api_gateway_method.test_get.http_method
  status_code = aws_api_gateway_method_response.test_response_200.status_code

  response_templates = {
    "application/json" = "{\"message\": \"API Gateway is working!\"}"
  }
}

# --- DIAGRAMS RESOURCE (Upload) ---
resource "aws_api_gateway_resource" "diagrams" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "diagrams"
}

resource "aws_api_gateway_method" "diagrams_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.diagrams.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "diagrams_integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.diagrams.id
  http_method = aws_api_gateway_method.diagrams_post.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 202}"
  }
}

# --- ANALYSES RESOURCE ---
resource "aws_api_gateway_resource" "analyses" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "analyses"
}

resource "aws_api_gateway_resource" "analysis_id" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.analyses.id
  path_part   = "{id}"
}

# --- STATUS RESOURCE ---
resource "aws_api_gateway_resource" "analysis_status" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.analysis_id.id
  path_part   = "status"
}

resource "aws_api_gateway_method" "analysis_status_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.analysis_status.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "analysis_status_integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analysis_status.id
  http_method = aws_api_gateway_method.analysis_status_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# --- REPORT RESOURCE ---
resource "aws_api_gateway_resource" "analysis_report" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.analysis_id.id
  path_part   = "report"
}

resource "aws_api_gateway_method" "analysis_report_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.analysis_report.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "analysis_report_integration" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.analysis_report.id
  http_method = aws_api_gateway_method.analysis_report_get.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

# --- DEPLOYMENT ---
resource "aws_api_gateway_deployment" "this" {
  depends_on = [
    aws_api_gateway_integration.test_integration,
    aws_api_gateway_integration.diagrams_integration,
    aws_api_gateway_integration.analysis_status_integration,
    aws_api_gateway_integration.analysis_report_integration
  ]

  rest_api_id = aws_api_gateway_rest_api.this.id
}

resource "aws_api_gateway_stage" "this" {
  deployment_id        = aws_api_gateway_deployment.this.id
  rest_api_id          = aws_api_gateway_rest_api.this.id
  stage_name           = var.environment
  xray_tracing_enabled = true
}

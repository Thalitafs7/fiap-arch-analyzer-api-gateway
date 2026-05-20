# Fiap Arch Analyzer — API Gateway

Exposes endpoints for uploading software architecture diagrams and retrieving AI-generated analysis reports.

## Tech Stack

- **Runtime:** .NET 9.0 / ASP.NET Core
- **Infrastructure:** AWS API Gateway, Amazon EKS, Amazon ECR, Terraform
- **CI/CD:** GitHub Actions, GHCR
- **Branching:** GitFlow with semantic versioning

---

## Architecture

### System Overview — Service Communication

```mermaid
graph LR
    subgraph Client
        U["User / Frontend"]
    end

    subgraph "API Gateway Layer"
        APIGW["AWS API Gateway<br/>Terraform managed"]
        SVC["ASP.NET Core 9 API<br/>Fiap.ArchAnalyzer.ApiGateway"]
    end

    subgraph "Backend Services (inferred)"
        UPLOAD["Upload & Orchestration Service"]
        ANALYSIS["Analysis Service (AI)"]
    end

    subgraph "Infrastructure"
        EKS["Amazon EKS<br/>eks-mecanicaos"]
        ECR["Amazon ECR<br/>mecanicaos-ecr"]
        GHCR["GitHub Container Registry"]
    end

    U -->|HTTPS| APIGW
    APIGW -->|Proxy| SVC
    SVC -->|"POST /diagrams"| UPLOAD
    UPLOAD -->|Async| ANALYSIS
    SVC -->|"GET /analyses/{id}/status"| ANALYSIS
    SVC -->|"GET /analyses/{id}/report"| ANALYSIS
    SVC -.->|Deployed to| EKS
    SVC -.->|Image stored| ECR
    SVC -.->|Image stored| GHCR
```

### Business Flow — Diagram Analysis Pipeline

```mermaid
flowchart TD
    subgraph "Client"
        A["User uploads diagram"]
    end

    subgraph "API Gateway"
        B{"File valid?"}
        C["Generate analysisId"]
        D["Return 202 Accepted"]
        E["Return 400 Bad Request"]
    end

    subgraph "Processing (inferred)"
        F["Send to Upload & Orchestration"]
        G["AI Analysis Engine"]
        H{"Analysis complete?"}
    end

    subgraph "Status Polling"
        I["GET /analyses/{id}/status"]
        J["Status: Received"]
        K["Status: InProgress"]
        L["Status: Analyzed"]
        M["Status: Error"]
    end

    subgraph "Report Retrieval"
        N["GET /analyses/{id}/report"]
        O["Components + Risks + Recommendations"]
    end

    A --> B
    B -->|No file| E
    B -->|Valid| C
    C --> D
    D --> F
    F --> G
    G --> H
    H -->|Success| L
    H -->|Failure| M
    I --> J
    J --> K
    K --> L
    L --> N
    N --> O
```

### Infrastructure Topology — AWS Deployment

```mermaid
graph TD
    subgraph "GitHub"
        REPO["Source Repository"]
        GHA["GitHub Actions"]
        GHCR["GHCR Registry"]
    end

    subgraph "AWS - us-east-1"
        subgraph "Networking"
            APIGW["AWS API Gateway REST API"]
        end

        subgraph "Compute - EKS"
            EKS["EKS Cluster: eks-mecanicaos"]
            DEPLOY["K8s Deployment: mecanicaos-api"]
            SVC_K8S["K8s Service: mecanicaos-service<br/>LoadBalancer"]
        end

        subgraph "Container Registry"
            ECR["ECR: mecanicaos-ecr"]
        end
    end

    subgraph "API Gateway Resources"
        R_TEST["/test - GET - MOCK"]
        R_DIAG["/diagrams - POST - MOCK"]
        R_STATUS["/analyses/{id}/status - GET - MOCK"]
        R_REPORT["/analyses/{id}/report - GET - MOCK"]
    end

    REPO -->|Push main| GHA
    GHA -->|Build + Push| GHCR
    GHA -->|Build + Push| ECR
    GHA -->|kubectl set image| EKS
    EKS --> DEPLOY
    DEPLOY --> SVC_K8S
    APIGW --> R_TEST
    APIGW --> R_DIAG
    APIGW --> R_STATUS
    APIGW --> R_REPORT
```

### CI/CD Pipeline

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant GH as GitHub
    participant CI as GitHub Actions
    participant GHCR as GHCR
    participant ECR as Amazon ECR
    participant EKS as Amazon EKS

    Dev->>GH: Push to develop
    GH->>CI: Trigger CI Develop
    CI->>CI: dotnet restore + build + test
    CI->>GH: Create PR to release branch

    Dev->>GH: Merge to main
    GH->>CI: Trigger CD Main
    CI->>CI: Docker build
    CI->>GHCR: Push image (SHA + latest)
    CI->>ECR: Push image (SHA + latest)
    CI->>EKS: kubectl set image
    EKS->>EKS: Rolling update
    CI->>CI: Verify rollout status
```

### Internal Structure

```mermaid
classDiagram
    class Program {
        +WebApplication app
        +AddControllers()
        +AddOpenApi()
        +UseAuthorization()
        +MapControllers()
    }

    class TestController {
        +Get() IActionResult
    }

    class DiagramsController {
        +Upload(IFormFile file) IActionResult
    }

    class AnalysesController {
        +GetStatus(string id) IActionResult
        +GetReport(string id) IActionResult
    }

    class ControllerBase

    ControllerBase <|-- TestController
    ControllerBase <|-- DiagramsController
    ControllerBase <|-- AnalysesController
    Program --> TestController : registers
    Program --> DiagramsController : registers
    Program --> AnalysesController : registers
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/test` | Health check |
| POST | `/diagrams` | Upload architecture diagram (multipart/form-data) |
| GET | `/analyses/{id}/status` | Poll analysis status |
| GET | `/analyses/{id}/report` | Retrieve AI-generated report |

---

## Key Observations

- **Current state:** Terraform integrations use `MOCK` type — downstream services not yet wired. Controllers return hardcoded responses.
- **SPOF:** Single API Gateway without visible HA/HPA config in this repo.
- **No auth configured:** `authorization = "NONE"` on all Terraform methods; `UseAuthorization()` present but no auth scheme registered.
- **Inferred dependencies:** Upload & Orchestration service + AI Analysis service referenced but not connected yet.

---

## Running Locally

```bash
cd src/Fiap.ArchAnalyzer.ApiGateway
dotnet run
```

## Deploy

Push to `main` triggers full CD pipeline → Docker build → ECR/GHCR push → EKS rolling update.

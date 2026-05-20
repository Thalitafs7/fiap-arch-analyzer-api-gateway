# Prompt para Replicar Pipeline CI/CD (SemVer + PRs Automáticos)

Este prompt foi desenvolvido para ser usado com assistentes de IA (como o Jules ou o ChatGPT) para configurar rapidamente a mesma estrutura de CI/CD em outros repositórios, independentemente do tipo de serviço (Lambda, SQS, API, etc.).

---

## 🤖 Copie e Cole o Prompt Abaixo:

"Preciso configurar uma pipeline de CI/CD completa para um novo repositório no GitHub. O foco deste repositório é: **[DESCREVA AQUI, EX: 'Uma função Lambda em Python' ou 'Um microserviço SQS em .NET']**.

A pipeline deve seguir exatamente este fluxo de promoção de código:

1.  **Branch `feature/*` -> `develop`**:
    *   **CI**: Rodar Build e Testes Unitários.
    *   **Automação**: Se os testes passarem, criar um Pull Request (PR) automaticamente da `feature/` para a branch `develop`.

2.  **Branch `develop` -> `release/*`**:
    *   **CI**: Rodar Build e Testes.
    *   **SemVer**: Calcular a próxima versão de release baseada na mensagem do último commit (Semantic Versioning):
        *   `BREAKING CHANGE` ou `!` (ex: `feat!:`) -> Incrementa MAJOR (1.0.0 -> 2.0.0).
        *   `feat:` -> Incrementa MINOR (1.0.0 -> 1.1.0).
        *   `fix:` ou outros -> Incrementa PATCH (1.0.0 -> 1.0.1).
    *   **Automação**: Criar a branch `release/x.y.z` a partir da `main` e abrir um PR de `develop` para essa nova branch de release.

3.  **Branch `release/*` -> `main`**:
    *   **CI**: Validar o código da release.
    *   **Automação**: Abrir um PR da branch `release/` para a branch `main`.

4.  **Branch `main` (Deploy)**:
    *   **CD**: Realizar o deploy para o ambiente de produção. **[ADICIONE AQUI DETALHES DO DEPLOY, EX: 'Deploy no AWS Lambda usando Serverless Framework' ou 'Deploy no EKS usando Manifestos K8s']**.

### Requisitos Técnicos:
*   Use o **GitHub CLI (`gh`)** para a criação de PRs.
*   Utilize o token padrão `${{ github.token }}` (mapeado para `GH_TOKEN`) para autorização.
*   Garanta que a branch principal se chame `main` (minúsculo).
*   Inclua um passo para instalar o `jq` nos jobs de criação de PR para processar metadados.
*   Crie um script auxiliar `.github/scripts/check_test_success.sh` para padronizar a execução de testes.
*   Adicione um bloco de `permissions` (`contents: write`, `pull-requests: write`) em todos os workflows.

### Instruções Adicionais:
*   Configure os workflows em arquivos separados: `ci-feature.yml`, `ci-develop.yml`, `ci-release.yml` e `cd-main.yml`.
*   Lembre o usuário de habilitar a configuração 'Allow GitHub Actions to create and approve pull requests' nas Settings do repositório."

#!/bin/bash
# Script para simular ou executar testes e verificar sucesso

echo "🔍 Iniciando execução dos testes..."

# Se houver uma solução .NET, executa dotnet test
if ls *.sln 1> /dev/null 2>&1; then
    dotnet test --no-build --verbosity normal
    if [ $? -eq 0 ]; then
        echo "✅ Testes concluídos com sucesso!"
        exit 0
    else
        echo "❌ Falha nos testes."
        exit 1
    fi
else
    echo "⚠️ Nenhuma solução .NET encontrada (*.sln)."
    echo "Este repositório pode estar no início do desenvolvimento."
    echo "Simulando sucesso dos testes para permitir a progressão da pipeline inicial."
    exit 0
fi

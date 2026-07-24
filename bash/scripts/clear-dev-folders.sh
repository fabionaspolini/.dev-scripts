#!/usr/bin/env bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Diretório atual
CURRENT_DIR=$(pwd)

# Mostrar cabeçalho
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}    Limpador de Pastas de Desenvolvimento${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "Diretório: ${YELLOW}${CURRENT_DIR}${NC}\n"

# Inicializar array de seleção
unset FOLDERS
declare -A FOLDERS
FOLDERS[bin]="Pasta 'bin' (.NET)"
FOLDERS[obj]="Pasta 'obj' (.NET)"
FOLDERS[node_modules]="Pasta 'node_modules' (Node.js)"
FOLDERS[publish]="Pasta 'publish' (publicações)"
FOLDERS[angular]="Pasta '.angular' (Angular)"
FOLDERS[terraform]="Pasta '.terraform' (Terraform)"
FOLDERS[venv]="Pasta '.venv' (Python virtual environment)"

# Mostrar menu de seleção
echo -e "${GREEN}Selecione as pastas que deseja limpar:${NC}\n"
for i in "${!FOLDERS[@]}"; do
    echo "[$i] ${FOLDERS[$i]}"
done
echo -e "[all]   Todas as pastas ${YELLOW}(PADRÃO)${NC}"
echo -e "[none]  Nenhuma pasta\n"

read -p "Opções (separe com espaço ou 'all'/'none', pressione ENTER para usar padrão): " -r SELECTION

# Processar seleção
unset TO_DELETE
declare -A TO_DELETE

# Se nada for digitado, usar "all" como padrão
if [[ -z "$SELECTION" ]]; then
    SELECTION="all"
    echo -e "${YELLOW}Usando opção padrão: all${NC}\n"
fi

if [[ "$SELECTION" == "all" ]]; then
    TO_DELETE[bin]=1
    TO_DELETE[obj]=1
    TO_DELETE[node_modules]=1
    TO_DELETE[publish]=1
    TO_DELETE[angular]=1
    TO_DELETE[terraform]=1
    TO_DELETE[venv]=1
elif [[ "$SELECTION" == "none" ]]; then
    echo -e "${YELLOW}Nenhuma pasta foi selecionada. Operação cancelada.${NC}"
    return 0
else
    for selection in $SELECTION; do
        if [[ "${FOLDERS[$selection]+x}" ]]; then
            TO_DELETE[$selection]=1
        else
            echo -e "${RED}Opção inválida: $selection${NC}"
            echo -e "${RED}Operação cancelada.${NC}"
            return 1
        fi
    done
fi

# Mostrar resumo das pastas a serem deletadas
echo -e "\n${YELLOW}========================================${NC}"
echo -e "${YELLOW}Resumo das operações:${NC}"
echo -e "${YELLOW}========================================${NC}\n"

for key in "${!TO_DELETE[@]}"; do
    echo -e "  • ${FOLDERS[$key]}"
done

echo ""
read -p "$(echo -e ${RED}Tem certeza que deseja proceder\? \(s/n\):${NC}) " -r CONFIRM

if [[ ! "$CONFIRM" =~ ^[Ss]$ ]]; then
    echo -e "${YELLOW}Operação cancelada pelo usuário.${NC}"
    return 0
fi

echo -e "\n${BLUE}Iniciando limpeza...${NC}\n"

# Executar limpeza das pastas selecionadas
if [[ -v TO_DELETE[bin] ]]; then
    echo "Apagando pastas 'bin'..."
    find . -iname "bin" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[obj] ]]; then
    echo "Apagando pastas 'obj'..."
    find . -iname "obj" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[node_modules] ]]; then
    echo "Apagando pastas 'node_modules'..."
    find . -iname "node_modules" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[publish] ]]; then
    echo "Apagando pastas 'publish'..."
    find . -iname "publish" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[angular] ]]; then
    echo "Apagando pastas '.angular'..."
    find . -iname ".angular" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[terraform] ]]; then
    echo "Apagando pastas '.terraform'..."
    find . -iname ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
fi

if [[ -v TO_DELETE[venv] ]]; then
    echo "Apagando pastas '.venv'..."
    find . -iname ".venv" -type d -exec rm -rf {} + 2>/dev/null || true
fi

echo -e "\n${GREEN}✓ Limpeza concluída com sucesso!${NC}\n"
echo -e "${BLUE}Script finalizado. O terminal segue disponível.${NC}"

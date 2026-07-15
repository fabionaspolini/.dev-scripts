#!/bin/bash

# Script para excluir branches já mescladas na main
# Uso: ./delete_merged_branches.sh [opções]

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variáveis padrão
DELETE_LOCAL=true
DELETE_REMOTE=false
DRY_RUN=false
MAIN_BRANCH="main"
PROTECTED_BRANCHES=("main" "master" "develop" "development" "staging" "production")

# Função de ajuda
show_help() {
    cat << EOF
Uso: ${0##*/} [OPÇÕES]

Exclui branches que já foram mescladas na branch principal (main/master).

OPÇÕES:
    -l, --local-only     Exclui apenas branches locais (padrão)
    -r, --remote         Exclui também branches remotas
    -a, --all            Exclui branches locais e remotas
    -d, --dry-run        Mostra quais branches seriam excluídas sem excluir
    -m, --main BRANCH    Define a branch principal (padrão: main)
    -p, --protect BRANCH Adiciona uma branch à lista de proteção
    -h, --help           Mostra esta mensagem de ajuda

BRANCHES PROTEGIDAS (nunca serão excluídas):
    main, master, develop, development, staging, production

EXEMPLOS:
    ${0##*/}                    # Exclui apenas branches locais mescladas
    ${0##*/} --remote           # Exclui branches locais e remotas
    ${0##*/} --dry-run          # Mostra quais branches seriam excluídas
    ${0##*/} -m master -r       # Usa 'master' como branch principal e exclui remotas

EOF
}

# Parse de argumentos
while [[ $# -gt 0 ]]; do
    case $1 in
        -l|--local-only)
            DELETE_LOCAL=true
            DELETE_REMOTE=false
            shift
            ;;
        -r|--remote)
            DELETE_REMOTE=true
            shift
            ;;
        -a|--all)
            DELETE_LOCAL=true
            DELETE_REMOTE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -m|--main)
            MAIN_BRANCH="$2"
            shift 2
            ;;
        -p|--protect)
            PROTECTED_BRANCHES+=("$2")
            shift 2
            ;;
        -h|--help)
            show_help
            return 0
            ;;
        *)
            echo -e "${RED}Erro: Opção desconhecida: $1${NC}"
            show_help
            return 1
            ;;
    esac
done

# Verifica se está em um repositório git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Erro: Não está em um repositório git${NC}"
    return 1
fi

# Atualiza referências remotas
echo -e "${YELLOW}Atualizando referências remotas...${NC}"
git fetch --prune

# Verifica se a branch principal existe
if ! git show-ref --verify --quiet "refs/heads/$MAIN_BRANCH"; then
    echo -e "${RED}Erro: Branch '$MAIN_BRANCH' não encontrada${NC}"
    echo -e "${YELLOW}Branches disponíveis:${NC}"
    git branch -a
    return 1
fi

# Garante que estamos atualizados com a main
echo -e "${YELLOW}Mudando para a branch $MAIN_BRANCH...${NC}"
git checkout "$MAIN_BRANCH"
git pull

# Função para verificar se a branch está protegida
is_protected_branch() {
    local branch="$1"
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$branch" == "$protected" ]]; then
            return 0
        fi
    done
    return 1
}

# Função para excluir branches locais
delete_local_branches() {
    echo -e "\n${YELLOW}Procurando branches locais mescladas...${NC}"
    
    # Lista branches mescladas (exceto a atual e a main)
    MERGED_BRANCHES=$(git branch --merged "$MAIN_BRANCH" | grep -v "^\*" | grep -v "$MAIN_BRANCH" | sed 's/^[[:space:]]*//')
    
    if [ -z "$MERGED_BRANCHES" ]; then
        echo -e "${GREEN}Nenhuma branch local mesclada encontrada.${NC}"
        return
    fi
    
    # Filtra branches protegidas
    BRANCHES_TO_DELETE=""
    PROTECTED_FOUND=""
    
    while IFS= read -r branch; do
        if [ -n "$branch" ]; then
            if is_protected_branch "$branch"; then
                PROTECTED_FOUND+="$branch\n"
            else
                BRANCHES_TO_DELETE+="$branch\n"
            fi
        fi
    done <<< "$MERGED_BRANCHES"
    
    if [ -n "$PROTECTED_FOUND" ]; then
        echo -e "${YELLOW}Branches protegidas ignoradas:${NC}"
        echo -e "$PROTECTED_FOUND"
    fi
    
    if [ -z "$BRANCHES_TO_DELETE" ]; then
        echo -e "${GREEN}Nenhuma branch local não-protegida para excluir.${NC}"
        return
    fi
    
    echo -e "${GREEN}Branches locais mescladas encontradas:${NC}"
    echo -e "$BRANCHES_TO_DELETE"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "\n${YELLOW}[DRY RUN] As seguintes branches seriam excluídas localmente:${NC}"
        echo -e "$BRANCHES_TO_DELETE"
    else
        echo -e "\n${YELLOW}Excluindo branches locais...${NC}"
        echo -e "$BRANCHES_TO_DELETE" | while read -r branch; do
            if [ -n "$branch" ]; then
                echo -e "Excluindo: ${RED}$branch${NC}"
                git branch -d "$branch"
            fi
        done
        echo -e "${GREEN}Branches locais excluídas com sucesso!${NC}"
    fi
}

# Função para excluir branches remotas
delete_remote_branches() {
    echo -e "\n${YELLOW}Procurando branches remotas mescladas...${NC}"
    
    # Lista branches remotas mescladas
    REMOTE_MERGED=$(git branch -r --merged "$MAIN_BRANCH" | grep -v "HEAD" | grep -v "$MAIN_BRANCH" | sed 's/^[[:space:]]*//' | sed 's#origin/##')
    
    if [ -z "$REMOTE_MERGED" ]; then
        echo -e "${GREEN}Nenhuma branch remota mesclada encontrada.${NC}"
        return
    fi
    
    # Filtra branches protegidas
    REMOTE_TO_DELETE=""
    REMOTE_PROTECTED=""
    
    while IFS= read -r branch; do
        if [ -n "$branch" ]; then
            if is_protected_branch "$branch"; then
                REMOTE_PROTECTED+="$branch\n"
            else
                REMOTE_TO_DELETE+="$branch\n"
            fi
        fi
    done <<< "$REMOTE_MERGED"
    
    if [ -n "$REMOTE_PROTECTED" ]; then
        echo -e "${YELLOW}Branches remotas protegidas ignoradas:${NC}"
        echo -e "$REMOTE_PROTECTED"
    fi
    
    if [ -z "$REMOTE_TO_DELETE" ]; then
        echo -e "${GREEN}Nenhuma branch remota não-protegida para excluir.${NC}"
        return
    fi
    
    echo -e "${GREEN}Branches remotas mescladas encontradas:${NC}"
    echo -e "$REMOTE_TO_DELETE"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "\n${YELLOW}[DRY RUN] As seguintes branches seriam excluídas remotamente:${NC}"
        echo -e "$REMOTE_TO_DELETE"
    else
        echo -e "\n${YELLOW}Excluindo branches remotas...${NC}"
        echo -e "${RED}ATENÇÃO: Isso irá excluir branches do repositório remoto!${NC}"
        read -p "Tem certeza que deseja continuar? (s/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            echo -e "$REMOTE_TO_DELETE" | while read -r branch; do
                if [ -n "$branch" ]; then
                    echo -e "Excluindo remotamente: ${RED}$branch${NC}"
                    git push origin --delete "$branch"
                fi
            done
            echo -e "${GREEN}Branches remotas excluídas com sucesso!${NC}"
        else
            echo -e "${YELLOW}Operação cancelada.${NC}"
        fi
    fi
}

# Executa as operações
if [ "$DELETE_LOCAL" = true ]; then
    delete_local_branches
fi

if [ "$DELETE_REMOTE" = true ]; then
    delete_remote_branches
fi

echo -e "\n${GREEN}Concluído!${NC}"
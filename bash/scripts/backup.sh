#!/bin/bash

# Script de backup genérico para compactar múltiplos conjuntos de arquivos
# Permite definir facilmente novos backups na estrutura de dados BACKUPS


# Configurações globais
DESTINO="$HOME/GoogleDrive/Backups/Automatic"

# Cores para mensagens
VERDE='\033[0;32m'
VERMELHO='\033[0;31m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # Sem cor

# ============================================================================
# ESTRUTURA DE BACKUPS
# ============================================================================
# Formato simples:    [nome_destino]="caminho_origem1:caminho_origem2:..."
# Formato com -C:     [nome_destino]="-C|/base/path|subpath1:subpath2:arquivo.json"
#
# O formato com -C usa pipe (|) como separador:
#   -C | diretório_base | itens_relativos_separados_por_dois_pontos
#
# Exemplo simples:
#   [bashrc.d]="$HOME/.bashrc.d"
#
# Exemplo com -C (evita path completo no tar):
#   [qwen]="-C|$HOME/.qwen|agents:skills:settings.json"
# ============================================================================

# Adicione mais backups conforme necessário:
declare -A BACKUPS=(
    [home.bashrc.d]="-C|$HOME/.bashrc.d|*.*"
#    [home.qwen]="-C|$HOME/.qwen|agents:skills:settings.json"
    [home.qwen]="-C|$HOME/.qwen|*"
    [home.ssh]="-C|$HOME/.ssh|*"
    [home.config]="-C|$HOME/.config|systemd/user/*.service:systemd/user/*.timer:systemd/user/disabled-services/:plasma*:kglobalshortcutsrc:kdeglobals:kwin*"
    [home.local]="-C|$HOME/.local|share/plasma*"
    [home.kube]="-C|$HOME/.kube|config:*.config"
)

# ============================================================================
# FUNÇÕES
# ============================================================================

exibir_msg() {
    echo -e "${VERDE}[BACKUP]${NC} $1"
}

exibir_erro() {
    echo -e "${VERMELHO}[ERRO]${NC} $1" >&2
}

exibir_aviso() {
    echo -e "${AMARELO}[AVISO]${NC} $1"
}

exibir_secao() {
    echo -e "\n${AZUL}═══════════════════════════════════════${NC}"
    echo -e "${AZUL}$1${NC}"
    echo -e "${AZUL}═══════════════════════════════════════${NC}\n"
}

# Criar diretório de destino se não existir
criar_diretorio_destino() {
    if [ ! -d "$DESTINO" ]; then
        exibir_msg "Criando diretório de destino: $DESTINO"
        if ! mkdir -p "$DESTINO"; then
            exibir_erro "Falha ao criar diretório: $DESTINO"
            return 1
        fi
    fi
    return 0
}

# Validar se path existe (suporta glob patterns)
validar_path() {
    local path="$1"
    # Se contém glob, expandir
    if [[ "$path" == *'*'* || "$path" == *'?'* || "$path" == *'['* ]]; then
        local expanded=()
        # shellcheck disable=SC2206
        expanded=($path)
        if [ ${#expanded[@]} -gt 0 ] && [ -e "${expanded[0]}" ]; then
            return 0
        fi
        return 1
    fi
    if [ ! -e "$path" ]; then
        return 1
    fi
    return 0
}

# Expandir glob pattern em array de paths válidos
expandir_glob() {
    local pattern="$1"
    local results=()

    if [[ "$pattern" == *'*'* || "$pattern" == *'?'* || "$pattern" == *'['* ]]; then
        # shellcheck disable=SC2206
        results=($pattern)
        # Filtrar apenas existentes
        local validos=()
        for r in "${results[@]}"; do
            if [ -e "$r" ]; then
                validos+=("$r")
            fi
        done
        echo "${validos[@]}"
    else
        if [ -e "$pattern" ]; then
            echo "$pattern"
        fi
    fi
}

# Executar backup individual
executar_backup() {
    local nome_backup="$1"
    local paths_origem="$2"
    local nome_arquivo="${nome_backup}.tar.gz"
    local caminho_completo="$DESTINO/$nome_arquivo"

    local usar_c_flag=false
    local diretorio_base=""
    local itens_relativos_str=""
    local paths_validos=()

    # Detectar formato: com -C ou simples
    if [[ "$paths_origem" == "-C|"* ]]; then
        usar_c_flag=true
        IFS='|' read -r _ diretorio_base itens_relativos_str <<< "$paths_origem"

        # Validar diretório base
        if [ ! -d "$diretorio_base" ]; then
            exibir_erro "Diretório base não encontrado: $diretorio_base"
            return 1
        fi

        # Separar itens relativos por ':'
        local IFS=':'
        set -f  # Desativar glob expansion
        local itens=($itens_relativos_str)
        set +f
        unset IFS

        exibir_msg "Validando arquivos de origem (modo -C: $diretorio_base)..."
        for item in "${itens[@]}"; do
            local pattern="$diretorio_base/$item"
            local expandidos
            expandidos=$(expandir_glob "$pattern")

            if [ -n "$expandidos" ]; then
                local adicionados=0
                for file in $expandidos; do
                    # Armazenar path relativo ao diretorio_base para o -C funcionar
                    local relativo="${file#$diretorio_base/}"
                    paths_validos+=("$relativo")
                    exibir_msg "✓ Encontrado: $relativo"
                    ((adicionados++))
                done
            else
                exibir_aviso "✗ Não encontrado: $item"
            fi
        done
    else
        # Formato simples (paths absolutos, possivelmente com glob)
        local IFS=':'
        set -f  # Desativar glob expansion
        local paths=($paths_origem)
        set +f
        unset IFS

        exibir_msg "Validando arquivos de origem..."
        for path in "${paths[@]}"; do
            local expandidos
            expandidos=$(expandir_glob "$path")

            if [ -n "$expandidos" ]; then
                for file in $expandidos; do
                    paths_validos+=("$file")
                    exibir_msg "✓ Encontrado: $file"
                done
            else
                exibir_aviso "✗ Não encontrado: $path"
            fi
        done
    fi

    # Verificar se temos pelo menos um path válido
    if [ ${#paths_validos[@]} -eq 0 ]; then
        exibir_erro "Nenhum arquivo ou diretório válido encontrado para: $nome_backup"
        return 1
    fi

    # Criar arquivo de backup
    exibir_msg "Criando arquivo de backup: $nome_arquivo"

    local tar_result=false
    if [ "$usar_c_flag" = true ]; then
        tar -czf "$caminho_completo" -C "$diretorio_base" "${paths_validos[@]}" 2>&1 > /dev/null && tar_result=true
    else
        tar -czf "$caminho_completo" "${paths_validos[@]}" 2>&1 > /dev/null && tar_result=true
    fi

    if [ "$tar_result" = true ]; then
        # Exibir informações do arquivo criado
        if [ -f "$caminho_completo" ]; then
            local tamanho=$(du -h "$caminho_completo" | cut -f1)
            exibir_msg "Backup concluído com sucesso!"
            exibir_msg "Arquivo: $nome_arquivo"
            exibir_msg "Tamanho: $tamanho"
            exibir_msg "Caminho: $caminho_completo"
            return 0
        else
            exibir_erro "Arquivo de backup não foi criado"
            return 1
        fi
    else
        exibir_erro "Falha ao criar arquivo de backup: $nome_arquivo"
        return 1
    fi
}

# ============================================================================
# PROGRAMA PRINCIPAL
# ============================================================================

main() {
    exibir_secao "INICIANDO BACKUPS"
    
    # Validar diretório de destino
    if ! criar_diretorio_destino; then
        exibir_erro "Não foi possível criar o diretório de destino"
        return 1
    fi
    
    # Verificar se há backups configurados
    if [ ${#BACKUPS[@]} -eq 0 ]; then
        exibir_erro "Nenhum backup configurado"
        return 1
    fi
    
    exibir_msg "Total de backups a executar: ${#BACKUPS[@]}"
    
    local total_backups=${#BACKUPS[@]}
    local backups_sucesso=0
    local backups_falha=0
    
    # Executar cada backup
    for nome_backup in "${!BACKUPS[@]}"; do
        exibir_secao "BACKUP: $nome_backup"
        
        if executar_backup "$nome_backup" "${BACKUPS[$nome_backup]}"; then
            ((backups_sucesso++))
        else
            ((backups_falha++))
        fi
        
        echo ""
    done
    
    # Resumo final
    exibir_secao "RESUMO FINAL"
    exibir_msg "Total: $total_backups | Sucesso: $backups_sucesso | Falha: $backups_falha"
    
    if [ $backups_falha -gt 0 ]; then
        return 1
    fi
    
    return 0
}

main
#exit $?

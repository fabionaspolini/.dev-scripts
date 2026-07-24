Convenção de nomes:

```txt
.<tech>_<scope>.<platform>.sh`
| |      |       |
| |      |       └─⫸ Se for um script específico para plataforma adicionar `.win` ou `.linux`. Caso for geral, omitir esta parte
| |      |
| |      └─────────⫸ Tipo do script: aliases|init
| |
| └────────────────⫸ Tecnologia: docker|git|terrafrom|profile|etc
|
└──────────────────⫸ Fixo
```

Scripts sem o sufixo "platform" são para ambiente Linux por padrão.


## System-triggers

- **on-login**: Executa automaticamente após login, com toda interface gráfica já carregada.
- **on-login/before-desktop-load**: Eles são executados antes de a área de trabalho carregar completamente, exatamente para definir variáveis de ambiente (export MINHA_VAR=valor) que todos os programas da sua sessão gráfica precisarão herdar.

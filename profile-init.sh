if [[ -n "${ZSH_VERSION:-}" ]]; then
  DEV_TOOLS_DIR="${${(%):-%x}:a:h}"
else
  DEV_TOOLS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
fi

. "$DEV_TOOLS_DIR"/profile-init/init.sh
. "$DEV_TOOLS_DIR"/scripts/init.sh

# Register autocomplete for kafka.sh
# . "$DEV_TOOLS_DIR"/scripts/kafka-autocomplete.sh

#_KAFKA_SOURCED_FOR_INIT=1 . "$DEV_TOOLS_DIR"/scripts/kafka.sh
#register_kafka_autocomplete
#unset _KAFKA_SOURCED_FOR_INIT

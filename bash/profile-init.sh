DEV_TOOLS_DIR="$(dirname -- "${BASH_SOURCE[0]}")"

. "$DEV_TOOLS_DIR"/aliases/init.sh
. "$DEV_TOOLS_DIR"/scripts/aliases.sh

# Register autocomplete for kafka.sh
. "$DEV_TOOLS_DIR"/scripts/kafka.sh
. "$DEV_TOOLS_DIR"/scripts/rclone.sh

#_KAFKA_SOURCED_FOR_INIT=1 . "$DEV_TOOLS_DIR"/scripts/kafka.sh
#register_kafka_autocomplete
#unset _KAFKA_SOURCED_FOR_INIT

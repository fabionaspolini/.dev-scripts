#!/usr/bin/env bash

#
# Script de callback para executar quando o serviço do systemd concluir (com sucesso ou erro).
#

SERVICE_NAME=$1
SERVICE_RESULT=$2
EXIT_STATUS=$3

if [ "$SERVICE_RESULT" = "success" ]; then
  /usr/bin/bash -c \
    "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus \
    notify-send --urgency=normal --icon=dialog-information --app-name=systemd \
    '$SERVICE_NAME completed' \
    'The task finished successfully.'"
  
    exit 0 # Se foi sucesso, não faz nada e encerra
fi

# Lógica de notificação de falha aqui
/usr/bin/bash -c \
  "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus \
  notify-send --urgency=critical --icon=dialog-error --app-name=systemd \
   '$SERVICE_NAME failed'\
   'The task finished with an error.\nExist status: $EXIT_STATUS\nCheck the logs with:\njournalctl --user -u $SERVICE_NAME'"
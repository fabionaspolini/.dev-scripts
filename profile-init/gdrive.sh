#!/usr/bin/env bash

#
# Manual sync - Google Drive
#

alias gdrive-sync="rclone bisync \
  googledrive: ~/GoogleDrive/ \
  --progress \
  --transfers 8 \
  --fast-list \
  --resilient \
  --log-level ERROR \
  --log-file ~/.local/state/rclone/gdrive-bisync.log"
#  --track-renames \

alias gdrive-sync-dry-run="rclone bisync \
  googledrive: ~/GoogleDrive/ \
  --progress \
  --transfers 8 \
  --fast-list \
  --resilient \
  --dry-run \
  --verbose"

#alias gdrive-resync="rclone bisync \
#  googledrive: ~/GoogleDrive/ \
#  --progress \
#  --resync \
#  --resync-mode local \
#  --transfers 8 \
#  --fast-list \
#  --log-level ERROR \
#  --log-file ~/.local/state/rclone/gdrive-bisync.log"

alias gdrive-show-logs="tail -n 20 ~/.local/state/rclone/gdrive-bisync.log"
alias gdrive-open-logs="kate ~/.local/state/rclone/gdrive-bisync.log"
# alias gdrive-status="systemctl --user status googledrive-rclone.service --no-pager" # It is no longer used as a service. Now it runs as a standalone command.

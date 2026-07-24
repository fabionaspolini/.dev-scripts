#!/usr/bin/env bash

#
# Management commands
#

rclone-selfupdate() {
#  echo "Stoping service"
#  systemctl --user stop googledrive-rclone.service

  echo "Self update"
  sudo rclone selfupdate

#  echo "Starting service"
#  rclone-start
}

#
# Only to VFS as a service mode
#

#alias rclone-show-journal-logs="journalctl --user -u googledrive-rclone.service -b --no-pager"
#
#rclone-stop() {
#  systemctl --user stop googledrive-rclone.service
#  rclone-status
#}
#
#rclone-start() {
#  systemctl --user daemon-reload
#  systemctl --user start googledrive-rclone.service
#  rclone-status
#}
#
#rclone-restart() {
#  systemctl --user daemon-reload
#  systemctl --user restart googledrive-rclone.service
#  rclone-status
#}

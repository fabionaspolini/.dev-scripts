#
# Manual sync - Google Drive
#

alias gdrive-sync="rclone bisync \
  googledrive: ~/GoogleDrive/ \
  --progress \
  --transfers 8 \
  --fast-list \
  --track-renames \
  --resilient \
  --log-level ERROR \
  --log-file ~/.local/state/rclone/googledrive-bisync.log"
  
alias gdrive-resync="rclone bisync \
  googledrive: ~/GoogleDrive/ \
  --progress \
  --resync \
  --transfers 8 \
  --fast-list \
  --log-level ERROR \
  --log-file ~/.local/state/rclone/googledrive-bisync.log"

alias gdrive-show-logs="tail -n 20 ~/.local/state/rclone/googledrive-bisync.log"
alias gdrive-open-logs="kate ~/.local/state/rclone/googledrive-bisync.log"

#
# Management commands
#

alias rclone-status="systemctl --user status googledrive-rclone.service --no-pager"
#alias rclone-show-service-logs="tail -n 20 ~/.local/state/rclone/googledrive.log"
#alias rclone-open-service-logs="kate ~/.local/state/rclone/googledrive.log"

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

alias rclone-status="systemctl --user status googledrive-rclone.service --no-pager"

alias rclone-show-journal-logs="journalctl --user -u googledrive-rclone.service -b --no-pager"
alias rclone-show-service-logs="tail -n 20 ~/.local/state/rclone/googledrive.log"
alias rclone-open-service-logs="kate ~/.local/state/rclone/googledrive.log"

rclone-stop() {
  systemctl --user stop googledrive-rclone.service
  rclone-status
}

rclone-start() {
  systemctl --user daemon-reload
  systemctl --user start googledrive-rclone.service
  rclone-status
}

rclone-restart() {
  systemctl --user daemon-reload
  systemctl --user restart googledrive-rclone.service
  rclone-status
}

rclone-selfupdate() {
  echo "Stoping service"
  systemctl --user stop googledrive-rclone.service
  
  echo "Self update"
  sudo rclone selfupdate
  
  echo "Starting service"
  rclone-start
}
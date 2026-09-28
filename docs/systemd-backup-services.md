# Backup systemd services

This guide explains how to set up the systemd **user** units that run the automatic backup
(`scripts/backup.sh`) on a schedule and notify you on the desktop when it finishes.

- [Overview](#overview)
- [Files involved](#files-involved)
- [1. `backup.service`](#1-backupservice)
- [2. `backup.timer`](#2-backuptimer)
- [Installing](#installing)
- [Checking status and logs](#checking-status-and-logs)
- [Testing](#testing)
- [Customizing the schedule](#customizing-the-schedule)

## Overview

Two units cooperate here, both under `~/.config/systemd/user/`:

- **`backup.timer`** triggers **`backup.service`** once a day.
- **`backup.service`** runs `scripts/backup.sh` and, when it finishes, calls a helper script
  that fires a desktop notification (success or failure) via `notify-send`.

All of this is **user-level** systemd (`systemctl --user`), so it runs as your regular user
session — no root/sudo required, and it depends on your user session (and, for
`notify-send`, on D-Bus/the graphical session) being available.

## Files involved

| File | Purpose |
|---|---|
| `~/.config/systemd/user/backup.service` | Runs `scripts/backup.sh` |
| `~/.config/systemd/user/backup.timer` | Schedules `backup.service` daily |
| `scripts/backup.sh` | The actual backup logic (compresses configured paths into `~/GoogleDrive/Backups/Automatic/<hostname>/<date>/`) |
| `scripts/utils/systemd-service-exec-post-start-notify.sh` | Helper invoked by `backup.service`'s `ExecStopPost` to notify success/failure |

## 1. `backup.service`

```ini
[Unit]
Description=Backup to GoogleDrive
#After=googledrive-rclone.service
#Requires=googledrive-rclone.service

[Service]
Type=oneshot

ExecStart=%h/.dev-scripts/scripts/backup.sh
ExecStopPost=-%h/.dev-scripts/scripts/utils/systemd-service-exec-post-start-notify.sh "%n" "$SERVICE_RESULT" "$EXIT_STATUS"

[Install]
WantedBy=default.target
```

Key points:

- `Type=oneshot`: the unit runs the command to completion and exits; it's not a long-lived
  daemon. This is the correct type for a script that runs once and finishes.
- `%h` expands to the invoking user's home directory, and `%n` to the full unit name
  (e.g. `backup.service`) — both systemd specifiers, so the unit stays portable across
  machines/usernames.
- `ExecStopPost=` runs *after* `ExecStart` finishes, regardless of whether it succeeded or
  failed, and receives `$SERVICE_RESULT` (`success`, `exit-code`, etc.) and `$EXIT_STATUS`
  as environment variables set by systemd. The leading `-` means systemd ignores this
  command's own exit code (a notification failure should never mark the whole unit as failed).
- The commented `After=`/`Requires=googledrive-rclone.service` lines show how you'd order
  this against another unit (e.g. an rclone mount/sync) if you needed the backup to wait
  for it — currently disabled, meaning the backup does not depend on any other unit.
- `WantedBy=default.target` only matters if you *enable* this unit directly (see
  [Installing](#installing)); for a timer-triggered oneshot, this line is mostly unused
  since you enable the `.timer`, not the `.service`.

## 2. `backup.timer`

```ini
[Unit]
Description=Backup to GoogleDrive diário às 20h

[Timer]
# Executa todos os dias às 20:00 (usa o horário local do sistema)
OnCalendar=*-*-* 20:00:00
# Se a máquina estiver desligada na hora, executa assim que ligar
Persistent=true

[Install]
WantedBy=timers.target
```

Key points:

- `OnCalendar=*-*-* 20:00:00`: runs every day at 20:00 local time. The calendar syntax is
  `year-month-day hour:minute:second`, where `*` matches any value.
- `Persistent=true`: if the machine was off/asleep at 20:00, systemd runs the missed backup
  as soon as the user session comes back up, instead of skipping it.
- A `.timer` unit activates the `.service` unit with the **same base name**
  (`backup.timer` → `backup.service`) automatically — no explicit `Unit=` needed in
  `[Timer]` unless you want to target a differently-named service.
- `WantedBy=timers.target` is what makes `systemctl --user enable backup.timer` actually
  start the timer on every login/boot of the user session.

## Installing

1. The unit files (`backup.service`, `backup.timer`) are plain files living directly in
   `~/.config/systemd/user/` — they are **not** tracked in this git repository (only the
   helper script `scripts/utils/systemd-service-exec-post-start-notify.sh` is). On a new
   machine, recreate them there manually (copy the content shown in this guide, or from a
   backup archive produced by `home.config` in `scripts/backup.sh`, which already includes
   `systemd/user/*.service` and `systemd/user/*.timer`).

2. Reload the systemd user daemon so it picks up new/changed unit files:

   ```bash
   systemctl --user daemon-reload
   ```

3. Enable and start the timer (not the service — the timer starts the service on schedule):

   ```bash
   systemctl --user enable --now backup.timer
   ```

4. Make sure your user services can run even when you're not logged into a graphical
   session (optional, but recommended for a nightly backup):

   ```bash
   loginctl enable-linger "$USER"
   ```

   Without lingering, user units only run while you have an active login session.

## Checking status and logs

```bash
# Timer status and next scheduled run
systemctl --user status backup.timer
systemctl --user list-timers backup.timer

# Last run status of the service itself
systemctl --user status backup.service

# Full logs from the service
journalctl --user -u backup.service

# Follow logs live
journalctl --user -u backup.service -f
```

## Testing

Run the backup immediately, without waiting for the timer:

```bash
systemctl --user start backup.service
```

Then check the notification appeared and inspect the result:

```bash
systemctl --user status backup.service
journalctl --user -u backup.service --since "5 minutes ago"
```

## Customizing the schedule

Edit the `OnCalendar=` line in `backup.timer`, then reload and restart the timer:

```bash
systemctl --user daemon-reload
systemctl --user restart backup.timer
```

Some useful `OnCalendar=` examples:

| Expression | Meaning |
|---|---|
| `*-*-* 20:00:00` | Every day at 20:00 |
| `Mon..Fri 09:00:00` | Weekdays at 09:00 |
| `*-*-* 08,20:00:00` | Every day at 08:00 and 20:00 |
| `weekly` | Once a week (Monday 00:00) |

Preview when a given expression would actually fire, without touching the timer:

```bash
systemd-analyze calendar "Mon..Fri 09:00:00"
```

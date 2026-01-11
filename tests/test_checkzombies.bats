@test "no zombies shows clean message" {
  run bin/checkzombies
  [ "$status" -eq 0 ]
  [ "$output" =~ "Keine Zombie-Prozesse aktiv" ]
}

@test "log file is created when configured" {
  local logfile="$BATS_TEST_TMPDIR/checkzombies.log"
  run bin/checkzombies --list --log-file "$logfile"
  [ "$status" -eq 0 ]
  [ -s "$logfile" ]
}

@test "systemd unit files are present" {
  [ -f packaging/systemd/checkzombies.service ]
  [ -f packaging/systemd/checkzombies-auto.service ]
  [ -f packaging/systemd/checkzombies.timer ]

  run grep -q "ExecStart=/usr/bin/env checkzombies --watch" packaging/systemd/checkzombies.service
  [ "$status" -eq 0 ]

  run grep -q "ExecStart=/usr/bin/env checkzombies --auto" packaging/systemd/checkzombies-auto.service
  [ "$status" -eq 0 ]
}

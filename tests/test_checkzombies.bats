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

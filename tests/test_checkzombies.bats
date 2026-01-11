setup() {
  export PATH="$BATS_TEST_DIRNAME/mocks:$PATH"
  export CHECKZOMBIES_LOG_FILE="$BATS_TEST_TMPDIR/checkzombies.log"
  export CHECKZOMBIES_LOG_LEVEL="INFO"
  export CHECKZOMBIES_LOG_SYSLOG="0"
  export CHECKZOMBIES_MOCK_PS_MODE="empty"
  export CHECKZOMBIES_KILL_STATE="$BATS_TEST_TMPDIR/kill_state"
  : > "$CHECKZOMBIES_KILL_STATE"
}

@test "--help exits 0 and shows usage" {
  run bin/checkzombies --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "--version exits 0 and shows name" {
  run bin/checkzombies --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"checkzombies"* ]]
}

@test "unknown option returns exit 1" {
  run bin/checkzombies --nope
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown option"* ]]
}

@test "mode conflict returns exit 1" {
  run bin/checkzombies --list --auto
  [ "$status" -eq 1 ]
  [[ "$output" == *"only one mode"* ]]
}

@test "--log-file requires an argument" {
  run bin/checkzombies --log-file
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires a path argument"* ]]
}

@test "--log-level requires an argument" {
  run bin/checkzombies --log-level
  [ "$status" -eq 1 ]
  [[ "$output" == *"requires a value"* ]]
}

@test "invalid log level falls back to INFO" {
  run bin/checkzombies --list --log-level FOO --no-log-file
  [ "$status" -eq 0 ]
  [[ "$output" == *"invalid log level, defaulting to INFO"* ]]
}

@test "non-tty list output uses tabs and no header" {
  export CHECKZOMBIES_MOCK_PS_MODE="zombies"
  run bash -c "PATH=\"$PATH\" CHECKZOMBIES_MOCK_PS_MODE=zombies CHECKZOMBIES_LOG_FILE=\"$CHECKZOMBIES_LOG_FILE\" bin/checkzombies --list | cat"
  [ "$status" -eq 0 ]
  [[ "$output" != *"PID"* ]]
  [[ "$output" == *$'\t'* ]]
}

@test "no zombies shows clean message" {
  run bin/checkzombies --list --no-log-file
  [ "$status" -eq 0 ]
  [[ "$output" == *"Keine Zombie-Prozesse aktiv"* ]]
}

@test "exit code 2 when zombies found in list mode" {
  export CHECKZOMBIES_MOCK_PS_MODE="zombies"
  run bin/checkzombies --list --no-log-file
  [ "$status" -eq 2 ]
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

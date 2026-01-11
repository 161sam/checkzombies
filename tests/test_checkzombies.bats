@test "no zombies shows clean message" {
  run bin/checkzombies
  [ "$status" -eq 0 ]
  [ "$output" =~ "Keine Zombie-Prozesse aktiv" ]
}

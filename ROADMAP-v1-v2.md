## ROADMAP: checkzombies → Professionelles Linux-Systemkommando (v1.0) → Cross-Plattform (v2.0)

Ziel: **v1.0 = “professionelles Linux-Tool”** mit stabilem CLI, sauberer Doku, systemd-Integration, Packaging, Tests, Release-Prozess.
**v2.0 = Cross-Plattform/Homebrew** (nach v1.0).

---

# v0.x → v1.0 (Linux-first)

## v0.2.0 – CLI-Grundlagen “sauber & erwartbar”

**Ziel:** Alles, was in Manpage/README steht, funktioniert wirklich – keine “Fake-Optionen”.

### Deliverables

* **Argument-Parsing** vollständig:

  * `-h/--help` (Usage + Beispiele)
  * `-v/--version`
  * `-l/--list` (nur auflisten, kein Menü)
  * `-a/--auto`
  * `-w/--watch` (intern, nicht externes `watch` voraussetzen)
  * `-f/--force` (keine Bestätigungen / aggressiver)
  * saubere Behandlung unbekannter Optionen + Exit-Code ≠ 0
  * **Konflikte** sauber abfangen (z.B. `--list` + `--auto` → Fehler + Usage)
* **Modularisierung**: `cmd_list`, `cmd_auto`, `cmd_watch`, `cmd_interactive`, `parse_args`
* **Konsistentes Privilege-Handling**

  * klare Policy: entweder “läuft auch ohne root, aber kill/restart benötigen Rechte” *oder* “für Cleanup braucht es root”
  * konsistente Verwendung von `sudo` (oder: root-check + Hard-Fail)
* **Code Cleanup**

  * tote Variablen entfernen
  * robustere `ps`-Ausgabe (nicht nur `$11 $12`)
* **Manpage & README** auf Ist-Zustand ziehen (oder umgekehrt)

### Akzeptanzkriterien

* `checkzombies --help` und `--version` funktionieren.
* `--list`, `--auto`, `--watch` und `--force` sind implementiert und dokumentiert.
* “Unknown option” führt nicht ins Menü, sondern zu Fehlermeldung + Usage.

---

## v0.3.0 – Robustheit, Safety & Exit-Codes (Production Verhalten)

**Ziel:** Fehler- und Sicherheitsverhalten definieren, Stabilität hochziehen.

### Deliverables

* **Strict Mode**: `set -euo pipefail` + kontrollierte Ausnahmen
* **Exit-Status-Definition** (und Doku in Manpage):

  * `0` = keine Zombies / erfolgreich
  * `1` = Fehler (Usage, fehlende Rechte, interne Fehler)
  * `2` = Zombies gefunden, aber nicht bereinigt (z.B. User abgebrochen)
* **Signal-Eskalation vereinheitlichen**

  * Standard: `TERM → wait → KILL` (auch im Einzelmodus)
  * `--force`: `KILL` direkt (oder extrem kurze Wait)
* **Verify-after-action**

  * nach Termination prüfen: sind Zombies weg? (erneut `find_zombies`, mindestens für betroffene PPIDs)
* **Sonderfälle**

  * Schutz vor riskanten Targets (z.B. PPID=1: niemals killen)
  * robustes Verhalten, wenn Prozesse verschwinden zwischen Listing und Aktion
* **trap/Signal-Handling**

  * SIGINT/SIGTERM → sauberer Exit + Logeintrag (besonders im `--watch` Loop)

### Akzeptanzkriterien

* Tool bricht bei Fehlern kontrolliert ab und liefert sinnvollen Exit-Code.
* `--force` ändert Verhalten sichtbar (keine Prompts, aggressiver).
* Bei `--watch` kann man per Ctrl+C sauber beenden.

---

## v0.4.0 – Logging “professionell”: Datei, syslog/journald, Konfig

**Ziel:** Logs nutzbar für Admins, systemd, Support-Fälle.

### Deliverables

* **Logging konsistent**: jede Aktion (TERM/KILL/restart/Fehler) geht ins Log
* Zeitstempel **pro Log-Entry**, nicht nur pro Run
* **Log-Ziel konfigurierbar**

  * Env oder Config: `CHECKZOMBIES_LOG=...`
  * Default für Linux-Tool sinnvoll (z.B. `/var/log/checkzombies.log` wenn root, sonst `${HOME}/checkzombies.log`)
* Optional: **syslog/journald** via `logger` (oder `systemd-cat`)
* **FILES-Sektion** der Manpage korrigieren (kein hartes `/home/dev/...`)

### Akzeptanzkriterien

* Log enthält reproduzierbar alle Aktionen + Fehler.
* Log-Pfad ist nicht “dev-hardcoded”, sondern systemtauglich.

---

## v0.5.0 – UX/Output-Policy: TTY vs Pipe, Unicode/Color optional

**Ziel:** Gute UX interaktiv, aber skriptfreundlich im Pipe/CI.

### Deliverables

* **TTY-Detection**

  * Bei Nicht-TTY: kein interaktives Menü, stattdessen Usage oder `--list` empfehlen
* **Output-Formate**

  * `--list` maschinenfreundlich (optional `--json` später; für v1.0 reicht “stabile Textstruktur”)
* **Unicode/Emoji/Color Policy**

  * `--no-unicode` (oder `CHECKZOMBIES_NO_UNICODE=1`)
  * Farben optional & automatisch deaktiviert ohne TTY
* **Interaktives Menü verbessern**

  * Loop: nach Aktion erneut anzeigen, solange Zombies existieren
  * `r` = refresh, `q` = quit
  * klare Warnung bei `--force`

### Akzeptanzkriterien

* `--list | less` wirkt sauber (keine Prompts, kein “Menü-Lärm”).
* Interaktiv ist wiederholbar nutzbar (mehrere Aktionen ohne Neustart).

---

## v0.6.0 – systemd Integration (Service + Timer) + Doku

**Ziel:** “Professionell” heißt: als Dienst betreibbar (optional), sauber dokumentiert.

### Deliverables

* `systemd/` (oder `contrib/systemd/`) mit:

  * `checkzombies.service` (für `--watch`)
  * **oder besser**: `checkzombies.timer` + `checkzombies.service` (periodischer Run mit `--auto` oder `--list` + Alert)
* Doku in README: Installation + enable/start/disable
* Manpage: ggf. Abschnitt “SYSTEMD” / Hinweise

### Akzeptanzkriterien

* User kann optional `systemctl enable --now checkzombies.timer` nutzen (wenn installiert).
* Keine “systemd-Abhängigkeit” im normalen CLI (Tool läuft auch ohne systemd, aber kann’s nutzen).

---

## v0.7.0 – Tests ausbauen (BATS) + Zombie-Simulation

**Ziel:** CI gibt dir Vertrauen, dass du nichts kaputt machst.

### Deliverables

* Tests für:

  * `--help`, `--version`, unknown args
  * Modus-Konflikte
  * `--list` Ausgabe bei “keine Zombies”
  * `--watch` Start/Stop Verhalten (kurzer Loop testbar)
* **Zombie-Simulation** für Tests:

  * kleiner Helper (z.B. Mini-C-Programm oder Bash-Fork-Konstrukt), der zuverlässig Zombie erzeugt
  * Tests laufen isoliert und cleanupen sich selbst
* ShellCheck: “clean” (Warnungen beheben statt ignorieren)

### Akzeptanzkriterien

* CI deckt Kernpfade ab, nicht nur den “no zombies” Happy Path.
* Zombie-Test läuft stabil (oder fallback: mock/stub, wenn Zombie-Erzeugung in CI zu flaky ist).

---

## v0.8.0 – Packaging: Debian vollständig + RPM realistisch (Linux-only)

**Ziel:** Installation wie ein echtes Tool.

### Deliverables (Debian)

* `debian/` vervollständigen:

  * `changelog`, `rules`, ggf. `install`, `copyright`
  * installiere `bin/checkzombies` nach `/usr/bin/checkzombies` oder `/usr/local/bin` je nach Policy
  * installiere manpage korrekt nach `/usr/share/man/man1/`
  * optional systemd units in `/lib/systemd/system/`
* `make deb` baut reproduzierbar ein `.deb`

### Deliverables (RPM)

* Entweder:

  * `.spec` + Build in CI **oder**
  * klarer Scope-Cut: RPM erst ab v1.1+ (aber du wolltest “alle Verbesserungen” → daher hier rein)
* GitHub Actions Job für RPM in Fedora-Container (Artifacts)

### Akzeptanzkriterien

* `dpkg -i` installiert Tool + Manpage + (optional) systemd units.
* RPM entsteht als CI-Artifact (mindestens “basic”).

---

## v0.9.0 – Release Automation + Repo-Professionalität

**Ziel:** Releases wie bei “echten” Projekten: Tag → Assets → Notes.

### Deliverables

* GitHub Actions **Release Workflow**

  * bei Tag `v*`:

    * run tests + lint
    * build `.deb` (+ optional `.rpm`)
    * upload Release Assets
    * generate Release Notes (z.B. aus Changelog oder GitHub auto notes)
* Repo-Docs:

  * `CHANGELOG.md` / `NEWS.md`
  * `CONTRIBUTING.md` (kurz: dev setup, tests, style)
* CI-Matrix (optional, aber empfohlen):

  * ubuntu-latest + ggf. debian container
  * bash version check (nur wenn sinnvoll)

### Akzeptanzkriterien

* `git tag v0.9.0` → GitHub Release mit Paketen und Notes.

---

## v1.0.0 – Stabilisierung & “Definition of Done”

**Ziel:** “Professionelles Systemkommando” für Linux.

### Must-have Checklist

* CLI vollständig, stabil, dokumentiert (help/man/README konsistent)
* Robust: strict mode, exit codes, verify-after-action, signal handling
* Logging professionell (konfigurierbar + optional journald)
* systemd integration (optional installierbar)
* Tests solide (CLI + mindestens eine Zombie-Case-Strategie)
* Debian-Paket vollständig; RPM mindestens basic
* Release Prozess automatisiert

### Akzeptanzkriterien (operativ)

* Admin kann:

  * `checkzombies --list` in Skripten nutzen (sauberes Verhalten)
  * `checkzombies --auto` per Timer/cron/systemd laufen lassen
  * im Fehlerfall Logs + Exit Codes verwerten
* Tool verhält sich sicher (kein “aus Versehen” killen kritischer Sachen ohne Warnung/Policy)

---

# v2.0.0 – Cross-Plattform / Homebrew / macOS (nach Linux v1.0)

## v2.0.0 – macOS/BSD Support + Homebrew Tap

**Ziel:** Portabilität ohne systemd, distribution-friendly.

### Deliverables

* **Platform Abstraction**

  * Linux: systemd optional
  * macOS: kein systemd → Service-Detection anders oder deaktiviert
  * Zombie-Erkennung ggf. an `ps`-Varianten anpassen (BSD ps flags)
* **Homebrew Formula**

  * Tap Repo oder Formula im separaten Repo
  * `brew install checkzombies` installiert Script + manpage
* Doku: “Linux vs macOS Unterschiede”
* CI: macOS runner (smoke tests)

### Akzeptanzkriterien

* `brew install` funktioniert und `man checkzombies` zeigt Manpage.
* Tool läuft sinnvoll auf macOS (mit reduzierter Funktion, wo systemd fehlt).


# 🧟💾🎮 ROADMAP: checkzombies → Linux Systemkommando

## v1.0.0 — Linux-first: stabiles, skriptfähiges, paketierbares Zombie-Tool (CLI/Man/Package/systemd)

> **Stabilität & Admin-Vertrauen** (ohne “Feature-Explosion”)

### v0.2.0 – CLI sauber (help/version/list/auto/watch/force)

* vollständiges Argument-Parsing:

  * `-h/--help`, `-v/--version`
  * `-l/--list` (nur Ausgabe, keine Interaktion)
  * `-a/--auto`
  * `-w/--watch` (intern implementiert)
  * `-f/--force`
* Modus-Konflikte erkennen (z.B. list+auto → Fehler + Usage)
* Modularisierung: `cmd_list/cmd_auto/cmd_watch/cmd_interactive`
* Doku-Sync: README + Manpage = Implementierung

### v0.3.0 – Robustheit & Safety

* `set -euo pipefail`
* Exit-Codes definieren (0/1/2) + Manpage “EXIT STATUS”
* Signal-Eskalation standardisieren (TERM → wait → KILL)
* Verify-after-action (prüfen ob Zombies verschwinden)
* Schutzregeln: niemals PPID=1 killen, Race-Conditions robust

### v0.4.0 – Logging professionell

* konsequentes Logging (jede Aktion/Fehler)
* Zeitstempel pro Entry
* Log-Ziel konfigurierbar
* optional `logger` / journald
* Manpage FILES korrigieren (kein hardcoded /home/dev)

### v0.5.0 – UX & Ausgabe-Policy (TTY vs Pipe)

* bei Nicht-TTY: keine interaktiven Prompts
* `--no-unicode` / automatische Unicode-Policy
* interaktiver Loop: `r` refresh, `q` quit
* stabile `--list` Ausgabe (script-friendly)

### v0.6.0 – systemd Integration

* optional Units:

  * `checkzombies.timer` + `checkzombies.service` (recommended)
  * oder `--watch` als service
* README Doku: enable/start/disable
* kein systemd-Zwang im Core

### v0.7.0 – Tests (BATS) & CI

* Tests für CLI, Exit-Codes, watch loop
* Zombie-Simulation (oder stabiler Mock)
* ShellCheck clean

### v0.8.0 – Packaging (Deb + RPM)

* Debian vollständig (rules/changelog/install)
* RPM als CI artifact (spec oder fpm)
* Manpage & systemd units korrekt im Paket

### v0.9.0 – Release Automation

* Tag → CI → Build → GitHub Release Assets
* Release Notes automatisieren
* CHANGELOG/NEWS, CONTRIBUTING

✅ **v1.0.0 Release**

* Definition of Done: “wie ps/top” nutzbar, sicher, dokumentiert, paketiert, vertrauenswürdig

---

# v2.0.0 — Cross-Plattform / Homebrew (nach Linux v1.0)

* GNU vs BSD `ps` kompatibel machen
* systemd-Funktionen sauber deaktivieren/ersetzen
* Homebrew Formula + macOS CI smoke tests
* Doku: Feature-Matrix Linux/macOS

---

# v3.0.0 — **ZOMBIES + MEMORY + TUI = All-in-One Prozess Manager**

> Hier kommen die “Wow”-Features rein: **Memory-Plugin + htop-style TUI**

---

## v3.0.0 — 💾 Memory-Integration (Plugin/Fallback)

### Neue Optionen

* `--memory`, `-m`: systemweiter Memory Report
* `--memory-zombies`: RAM-Verbrauch von Zombie-Parents
* `--full`: Zombies + Memory kombiniert

### Auto-Detection

`smem (best) → ps_mem → ps fallback`

### Regeln

* Memory-Modus ist **read-only** (keine kills)
* skriptfähig & pipe-freundlich

### Doku

* Manpage OPTIONS ergänzen
* README Feature-Tabelle + Vergleich (zps/ps_mem)

### Tests

* Tool-detection mocken
* Fallback-Reihenfolge testen
* memory-zombies mapping testen

---

## v3.1.0 — 🎮 Minimal-TUI (interaktiver Modus “sauber”, ohne htop-Komplexität)

> **Sinnvoller Zwischenschritt**, damit du TUI-Rendering & Input sauber hinbekommst

### Ziel

* `checkzombies --tui` = **interaktives UI**, aber noch ohne Scrolling/Sorting/Maus
* Fokus: stabile ANSI-Render-Schleife + Key Handling + Cursor Restore

### Deliverables

* Screen redraw loop (2–5 Hz)
* Header + Zombie-Tabelle
* Keys: `q` quit, `r` refresh, `k` kill (mit Bestätigung außer `--force`)
* Cursor hide/show + `trap` für Restore
* TTY-only: wenn kein TTY → Fehler + Hinweis

---

## v3.2.0 — 🎛️ htop-style TUI “Full”

> jetzt wird es wirklich “htop-ähnlich”, aber weiter bash/ANSI (ohne ncurses)

### Deliverables (htop-Level)

* **Scrolling** (↑↓) mit offset
* **Sortierung**: CPU/MEM (z.B. `c`/`m` oder “F6”-ähnlich)
* Anzeige: Top CPU Prozesse + Zombie Tabelle + optional Memory (wenn `--memory`/smem verfügbar)
* optional: “live mode” shortcut (`--live`) = internes refresh (nicht externes watch)
* robustes Input-Parsing für ESC-Sequenzen
* “safe mode”: niemals kill ohne explizite Aktion

### Optional (v3.3.0)

* Mouse tracking (`\033[?1000h`) nur wenn sauber testbar
* JSON Export aus TUI heraus (Taste `e`)

---

## v3.3.0 — 🔥 Unified “Full Check” UI

* `checkzombies --full --tui`:

  * Zombies rot highlight
  * Memory view togglable (`tab`)
  * “selected parent” details panel (mini “inspect”)

---

# v3.4.0 — Monitoring/Alert Track (optional)

* Thresholds (`--mem-warn`, `--mem-crit`)
* Nagios-like exit semantics für memory checks
* systemd timer + notify script example
* `--json` für Integration in andere Tools

---

## Warum diese Einordnung sinnvoll ist

* **v1.0** bleibt “Unix-Tool”, stabil und paketierbar.
* **v3.x** ist der “Power-Release” mit TUI + Memory, ohne Risiko für den Core.


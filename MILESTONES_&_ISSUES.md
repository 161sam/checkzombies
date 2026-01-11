# 🧭 **checkzombies** Milestones & Issues – 

---

# 🟢 Milestone: **v1.0.0 – Professional Linux System Command**

> **Ziel:** stabiles, skriptfähiges, paketierbares Linux-Tool
> **Definition of Done:** vertrauenswürdig wie `ps`, `kill`, `top`

---

## 🔹 Core CLI & Verhalten

### Issue #1 – Implement robust CLI argument parsing

**Labels:** `core`, `cli`, `v1.0`

**Beschreibung**

* Implementiere vollständiges Argument-Parsing:

  * `--help`, `--version`
  * `--list`, `--auto`, `--watch`, `--force`
* Verhindere ungültige Kombinationen (z. B. `--list --auto`)

**Akzeptanzkriterien**

* Alle Optionen funktionieren wie in Manpage beschrieben
* Ungültige Optionen → Exit 1 + Usage
* `checkzombies -h` beendet sauber ohne Seiteneffekte

---

### Issue #2 – Enforce strict shell safety mode

**Labels:** `core`, `safety`, `v1.0`

**Beschreibung**

* Aktiviere `set -euo pipefail`
* Entferne implizite Fehlerunterdrückung
* Ersetze pauschales `|| true` durch gezielte Ausnahmen

**Akzeptanzkriterien**

* Keine ShellCheck SC2086/SC2154/SC2312 Warnungen
* Fehler führen nicht zu stillen Fehlzuständen

---

### Issue #3 – Define and document exit codes

**Labels:** `cli`, `docs`, `v1.0`

**Beschreibung**

* Definiere Exit-Code-Semantik:

  * `0` → keine Zombies / erfolgreich bereinigt
  * `1` → Fehler / falsche Nutzung
  * `2` → Zombies gefunden, aber nicht bereinigt

**Akzeptanzkriterien**

* Exit-Codes konsistent in allen Modi
* Manpage enthält Abschnitt **EXIT STATUS**

---

## 🔹 Zombie Handling & Safety

### Issue #4 – Harden zombie detection and PID handling

**Labels:** `core`, `process`, `v1.0`

**Beschreibung**

* Stabilisiere Zombie-Erkennung
* Validierung aller PIDs
* Schutzregeln:

  * niemals PPID=1 killen
  * race-conditions abfangen

**Akzeptanzkriterien**

* Keine Kills kritischer Systemprozesse
* Wiederholbare Ergebnisse bei parallelen Prozessänderungen

---

### Issue #5 – Standardize signal escalation strategy

**Labels:** `process`, `safety`, `v1.0`

**Beschreibung**

* Einheitliches Vorgehen:

  1. SIGTERM
  2. wait (konfigurierbar)
  3. SIGKILL (nur bei Bedarf / `--force`)
* Verify-after-kill (Zombie wirklich weg?)

**Akzeptanzkriterien**

* Einheitliches Verhalten in Auto & Interactive Mode
* Ergebnis wird geloggt

---

## 🔹 UX & Output Policy

### Issue #6 – Implement TTY vs non-TTY output policy

**Labels:** `ux`, `cli`, `v1.0`

**Beschreibung**

* Bei Pipe/Redirect:

  * kein interaktives Menü
  * reine Textausgabe
* Auto-Erkennung von Unicode-Support

**Akzeptanzkriterien**

* `checkzombies --list | grep Z` funktioniert stabil
* `--no-unicode` erzwingt ASCII

---

### Issue #7 – Improve interactive menu loop

**Labels:** `ux`, `interactive`, `v1.0`

**Beschreibung**

* Interaktiver Modus bleibt aktiv bis `q`
* Keys:

  * `r` reload
  * `q` quit
* saubere Rückkehr in Terminalzustand

**Akzeptanzkriterien**

* Kein „Einmal-Menü“
* Cursor/Terminalzustand korrekt restauriert

---

## 🔹 Logging & Observability

### Issue #8 – Implement consistent logging strategy

**Labels:** `logging`, `v1.0`

**Beschreibung**

* Jede relevante Aktion loggen:

  * Detektion
  * Kill
  * Restart
  * Fehler
* Konfigurierbarer Log-Pfad
* Optional: `logger` / journald

**Akzeptanzkriterien**

* Keine stillen Aktionen
* Logeinträge mit Zeitstempel & Kontext

---

## 🔹 systemd Integration

### Issue #9 – Add optional systemd service + timer

**Labels:** `systemd`, `v1.0`

**Beschreibung**

* `checkzombies.service` (`--watch`)
* `checkzombies.timer` (`--auto`)
* Dokumentation in README

**Akzeptanzkriterien**

* Kein systemd-Zwang im Core
* Units funktionieren out-of-the-box

---

## 🔹 Testing & CI

### Issue #10 – Expand BATS test coverage

**Labels:** `tests`, `ci`, `v1.0`

**Beschreibung**

* Tests für:

  * CLI-Parsing
  * Exit-Codes
  * `--list` / `--help`
* Zombie-Simulation oder stabiler Mock

**Akzeptanzkriterien**

* CI grün
* Regressionssicher bei Refactoring

---

## 🔹 Packaging & Release

### Issue #11 – Complete Debian packaging

**Labels:** `packaging`, `v1.0`

**Beschreibung**

* `debian/rules`, `install`, `changelog`
* Manpage & systemd units im Paket

**Akzeptanzkriterien**

* `dpkg-buildpackage` ohne Fehler
* Installiertes Paket funktioniert

---

### Issue #12 – Add RPM build artifact

**Labels:** `packaging`, `ci`, `v1.0`

**Beschreibung**

* RPM via spec oder fpm
* CI erzeugt `.rpm` als Artifact

---

### Issue #13 – Automate GitHub releases

**Labels:** `release`, `ci`, `v1.0`

**Beschreibung**

* Tag → CI → Release
* Attach `.deb`, `.rpm`
* CHANGELOG automatisch

---

# 🟡 Milestone: **v2.0.0 – Zombies + Memory + TUI**

---

## 💾 Memory Integration

### Issue #17 – Implement `--memory` auto-backend

**Labels:** `memory`, `v2.0`

* Auto-detect: `smem → ps_mem → ps`
* read-only

### Issue #18 – Implement `--memory-zombies`

* Zombie-Parents → RAM-Verbrauch
* **Unique Feature**

### Issue #19 – Implement `--full` combined mode

* Zombies + Memory orchestration

---

## 🎮 TUI (htop-style)

### Issue #20 – Minimal ANSI TUI (`--tui`)

**Labels:** `tui`, `v2.0`

* ANSI-Render-Loop
* Header + Zombie-Table
* Keys: q/r/k
* Cursor hide/show + trap

---

### Issue #21 – Advanced htop-style TUI

**Labels:** `tui`, `v2.0`

* Scrolling (↑↓)
* Sorting (CPU/MEM)
* Live refresh (intern, kein watch)
* optional mouse tracking

---

### Issue #22 – Unified Full-Check TUI

**Labels:** `tui`, `memory`, `v2.0`

* Zombies + Memory
* Toggle views
* Inspect selected parent

---

## 🧪 Tests & Doku (v2)

### Issue #23 – TUI safety & restore tests

* Terminal state always restored

### Issue #24 – Update Manpage + README for v2

* Memory + TUI Optionen
* Feature comparison table

---


# 🔵 **MAIBE FUTURE** Milestone: **v3.0.0 – Cross-Platform / Homebrew**

### Issue #14 – Abstract platform-specific behavior

* GNU vs BSD `ps`
* systemd optional

### Issue #15 – Homebrew formula

* `brew install checkzombies`

### Issue #16 – macOS CI smoke tests

---


# 🧠 Strategische Notiz (für README / Maintainer)

> **checkzombies ist bewusst modular aufgebaut**
> Core (v1) = stabil
> Power-Features (v3) = optional, isoliert, austauschbar

---


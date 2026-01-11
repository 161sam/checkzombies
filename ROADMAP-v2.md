# 🧟💾 ROADMAP: **checkzombies → Professionelles Systemkommando**

---

## v1.0.0 — **Linux-first: stabiles, professionelles Zombie-Tool**

> *„Unix-würdig, skriptfähig, paketierbar, sicher“*

### 🎯 Ziel

Ein **zuverlässiges Linux-CLI-Tool**, das Admins bedenkenlos in Skripten, systemd und CI einsetzen können.

### Kern-Deliverables

✅ (bereits von dir definiert, hier nur strukturiert zusammengeführt)

#### CLI & Core

* vollständiges Argument-Parsing
  `--help, --version, --list, --auto, --watch, --force`
* saubere Modus-Trennung (keine stillen Kombinationen)
* konsistente Exit-Codes (0/1/2)
* Strict Mode (`set -euo pipefail`)
* sichere Signal-Eskalation (TERM → wait → KILL)
* Schutz vor kritischen PIDs (PPID=1 etc.)
* verify-after-kill

#### UX & Output

* TTY-Erkennung (kein Menü bei Pipes)
* interaktiver Loop (`r`, `q`)
* optional Unicode/Emoji (`--no-unicode`)
* stabile Textausgabe für `--list`

#### Logging

* konsistentes Logging aller Aktionen
* konfigurierbarer Log-Pfad
* optional `logger` / journald

#### systemd

* optional:

  * `checkzombies.service` (`--watch`)
  * **oder besser** `checkzombies.timer` (`--auto`)
* dokumentiert, aber **nicht erzwungen**

#### Tests & CI

* BATS-Tests für:

  * CLI-Parser
  * Exit-Codes
  * Watch-Start/Stop
* ShellCheck clean
* Zombie-Simulation (oder stabiler Stub)

#### Packaging

* vollständiges `.deb`
* RPM mindestens als CI-Artifact
* Manpage korrekt installiert

➡️ **v1.0 Definition of Done**

> „Ich kann `checkzombies` wie `ps`, `top` oder `kill` behandeln – sicher, vorhersagbar, dokumentiert.“

---

## v1.1.0 — **Stabilisierung & Admin-Feinschliff**

> *Qualität statt Features*

* bessere Fehlertexte (konkret, nicht generisch)
* `EXIT STATUS` Sektion in Manpage
* `SEE ALSO` (ps, top, systemctl)
* README: klare Use-Cases (cron, systemd, manuell)
* kleine Performance-Optimierungen

---

# 🚀 v2.0.0 — **Cross-Platform / Distribution Layer**

> *nach Linux-Stabilität*

### Ziel

checkzombies läuft **auch außerhalb von systemd-Linux**, ohne Kernlogik zu beschädigen.

### Deliverables

* Plattform-Abstraktion:

  * Linux (systemd optional)
  * macOS / BSD (kein systemd)
* ps-Flags kompatibel machen (GNU vs BSD ps)
* Homebrew Formula (`brew install checkzombies`)
* macOS CI Smoke-Tests
* Doku: Feature-Matrix Linux vs macOS

➡️ **kein Feature-Zwang**, nur saubere Degradation

---

# 🧠🔥 v3.0.0 — **ZOMBIES + MEMORY = ONE COMMAND**

> *Hier kommt dein Killer-Feature*

## 🎯 Ziel

**checkzombies wird vom Spezialtool zum All-in-One Prozess-Manager**

---

## v3.0.0 — Memory-Integration (Plugin-basiert, optional)

### 🧩 Design-Prinzip (wichtig!)

* **kein Python im Core**
* **Auto-Detection**
* Memory ist **Feature**, kein Zwang

---

### 🔌 Memory-Backend-Priorität (automatisch)

```
smem (BEST) → ps_mem → native ps
```

---

### Neue CLI-Modi

| Option             | Bedeutung                        |
| ------------------ | -------------------------------- |
| `--memory`, `-m`   | Systemweiter Memory-Report       |
| `--memory-zombies` | RAM-Verbrauch der Zombie-Parents |
| `--full`           | Zombies + Memory kombiniert      |

---

### Implementierungs-Scope

#### `--memory`

* zeigt Top-Memory-Prozesse
* nutzt:

  * `smem` (USS/PSS/RSS)
  * fallback `ps_mem`
  * fallback `ps`

#### `--memory-zombies`

* korreliert Zombie-Parents mit RAM-Verbrauch
* **echter Mehrwert**, kein anderes Tool bietet das

#### `--full`

* orchestrierter Run:

  1. Zombie-Analyse
  2. Memory-Analyse
  3. klare Trennung im Output

---

### UX-Regeln

* **niemals killen** im Memory-Modus
* reine Analyse
* skript- & pipe-fähig

---

### Manpage & README

* neue OPTIONS-Sektion
* Feature-Tabelle
* Vergleich zu zps / ps_mem
* klarer Hinweis: *Memory optional*

---

### Tests

* Tool-Detection mocken (`smem`, `ps_mem`)
* Fallback-Reihenfolge testen
* Zombie-Parent → Memory-Mapping testen

---

### Marketing / Positionierung (bewusst!)

> **„checkzombies: ZOMBIES + MEMORY LEAKS = ONE COMMAND“**

---

## v3.1.0 — Optional: Monitoring / Alert-Use-Cases

*(nur falls gewünscht)*

* Exit-Codes für Monitoring (Nagios-Style)
* Thresholds (`--mem-warn`, `--mem-crit`)
* JSON-Output (`--json`) für Tools
* systemd-Timer + Alert-Script Beispiel

---

# 🧭 Strategische Einordnung (wichtig)

| Phase | Fokus                                      |
| ----- | ------------------------------------------ |
| v1.x  | **Stabilität, Sicherheit, Linux-Qualität** |
| v2.x  | Reichweite (macOS, Brew)                   |
| v3.x  | **Alleinstellungsmerkmal**                 |

Du machst es **genau richtig**, die Memory-Power **nicht** in v1 zu erzwingen.
So bleibt der Core sauber – und v3 wird ein **echter Wow-Release**.

---

# AGENTS.md — checkzombies

## 🎯 Zweck dieser Datei

Diese Datei steuert **autonome und halb‑autonome Agenten** (z. B. Codex, GPT‑basierte Dev‑Agents), die am Projekt **checkzombies** arbeiten.

Ziel ist es, **professionelle, sichere und reproduzierbare Weiterentwicklung** zu gewährleisten – ohne Feature‑Drift, ohne Scope‑Creep, ohne inkonsistente Releases.

checkzombies ist **kein Spielzeug**, sondern ein **Linux‑Systemkommando**.

---

## 🧭 Projekt‑Philosophie

**checkzombies folgt klassischen Unix‑Prinzipien:**

* Do one thing well (v1.x)
* Script‑ & pipe‑fähig
* Vorhersagbares Verhalten
* Klare Exit‑Codes
* Saubere Dokumentation
* Optional erweiterbar (Plugins / Power‑Features)

❌ Keine Magie
❌ Keine stillen Nebenwirkungen
❌ Keine versteckten Abhängigkeiten

---

## 🗂️ Versions‑ & Feature‑Strategie

### v1.x — Linux‑first Core (STABILITÄT)

Pflichtfokus:

* CLI‑Korrektheit
* Sicherheit
* systemd‑Integration (optional)
* Packaging (.deb / rpm)

⚠️ **Keine neuen Power‑Features** in v1.x

---

### v2.x — Cross‑Platform (PORTABILITÄT)

* macOS / BSD Kompatibilität
* Homebrew Formula
* saubere Feature‑Degradation

---

### v3.x — Power‑Features (OPTIONAL)

Erlaubte Erweiterungen:

* Memory‑Analyse (`smem` / `ps_mem`)
* htop‑style ANSI‑TUI
* Kombinierte Analyse‑Modi

⚠️ v3.x darf **niemals** den v1‑Core destabilisieren.

---

## 🧠 Agent‑Rollen

### 🛠️ Code‑Agent

**Aufgaben:**

* Implementierung einzelner Issues
* Refactoring innerhalb klarer Grenzen

**Regeln:**

* Nur Features implementieren, die im jeweiligen Milestone erlaubt sind
* Kein „nebenbei verbessern“ ohne Issue
* Kein Umbau der Architektur ohne expliziten Auftrag

---

### 📦 Packaging‑Agent

**Aufgaben:**

* Debian / RPM Packaging
* systemd Units

**Regeln:**

* Keine Code‑Logik ändern
* Nur Installations‑ & Runtime‑Pfad anpassen

---

### 📖 Docs‑Agent

**Aufgaben:**

* README
* Manpage
* CHANGELOG

**Regeln:**

* Dokumentation MUSS der Implementierung entsprechen
* Niemals Optionen dokumentieren, die nicht existieren

---

## 🚦 Entwicklungs‑Regeln (SEHR WICHTIG)

### 1️⃣ Scope‑Kontrolle

Agenten dürfen **nicht**:

* neue CLI‑Optionen erfinden
* bestehende Semantik ändern
* stilles Verhalten einführen

Wenn Unsicherheit besteht:
➡️ **STOP** und Rückfrage formulieren

---

### 2️⃣ Bash‑Qualitätsregeln

Pflicht:

* `set -euo pipefail`
* defensives `IFS`
* konsequentes Quoting
* ShellCheck clean

Erlaubt:

* gezielte `|| true` **nur mit Kommentar**
* 
---

### 3️⃣ CLI‑Verhalten

* `--help` und `--version` sind **early‑exit**
* Unbekannte Optionen → Exit 1
* Exit‑Codes sind Teil der API

---

### 4️⃣ Sicherheit

* Niemals PPID=1 killen
* Kein implizites `sudo`
* Kein Kill ohne explizite User‑Aktion oder `--force`

---

## 🧪 Tests & Qualitätssicherung

Minimalanforderung je PR:

* manuelle Smoke‑Tests dokumentiert
* kein ShellCheck‑Regression

Wenn Tests existieren:

* Tests anpassen oder erweitern

---

## 🔄 Arbeitsablauf für autonome Agenten

1. Repo lesen (README + AGENTS.md + aktuelle Milestones)
2. Ziel‑Issue vollständig verstehen
3. **Kleinste mögliche Änderung** umsetzen
4. Tests / Smoke‑Checks durchführen
5. Dokumentation ggf. anpassen
6. PR erstellen mit:

   * Kurzbeschreibung
   * Issue‑Referenz
   * Test‑Notizen

---

## 🧯 Abbruch‑Regeln

Agent **muss abbrechen**, wenn:

* Anforderungen widersprüchlich sind
* Feature nicht eindeutig v1/v2/v3 zuordenbar ist
* Änderung sicherheitsrelevant erscheint

➡️ Stattdessen: präzise Rückfrage formulieren

---

## 🏁 Leitmotiv

> **„checkzombies soll sich anfühlen wie ein natives Linux‑Tool – nicht wie ein Experiment.“**

Wenn eine Entscheidung nicht eindeutig ist:
➡️ entscheide **konservativ**, **sicher**, **Unix‑konform**.

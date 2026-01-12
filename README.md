# checkzombies 🧟‍♂️ Zombie Process Manager

[![Release](https://img.shields.io/github/v/release/161sam/checkzombies)](https://github.com/161sam/checkzombies/releases)

**erstelle eine passende onliner beschreibung für das projekt, die ich anstatt "little terminal tool, find and clean up zombie-prozesses"  in der github repo beschreibung verwenden kann.

****checkzombies** automatisiert die Erkennung und Bereinigung von Zombie-Prozessen auf Linux-Systemen. Unterstützt systemd-Services, mehrstufiges Cleanup (SIGCHLD→TERM→KILL), verifizierte .deb-Pakete, optionale Timer und umfassende Logging-Funktionen mit klaren Exit-Codes.**

## 🚀 Schnellstart

```bash
curl -fsSL https://raw.githubusercontent.com/161sam/checkzombies/main/scripts/install.sh | sudo REPO=161sam/checkzombies bash
man checkzombies  # Man-Page!
```

## ✨ Features

    🧟 Robuste Zombie-Detection (ps + awk)

    🔄 Systemd-Service Integration

    📊 Interaktives Menü + Auto-Mode

    📜 Vollständige Man-Page

    🧪 Unit-Tests + CI/CD

    📦 Debian/RPM Packages

## 📦 Installation

### Option A (empfohlen): Release Single-File (verifiziert)
```bash
curl -fsSL https://raw.githubusercontent.com/161sam/checkzombies/main/scripts/install.sh | sudo REPO=161sam/checkzombies bash
````

### Option B: Release .deb (verifiziert)

```bash
curl -fsSL https://raw.githubusercontent.com/161sam/checkzombies/main/scripts/install.sh | sudo REPO=161sam/checkzombies bash -s -- --method deb
```

### Version pinnen

```bash
curl -fsSL https://raw.githubusercontent.com/161sam/checkzombies/main/scripts/install.sh | sudo REPO=161sam/checkzombies bash -s -- --version v1.0.0
```

Installer lädt Releases, prüft die `SHA256SUMS` und installiert nur bei gültiger Prüfsumme.

Release-Assets enthalten: `checkzombies`, `.deb`, `.rpm`, `SHA256SUMS`.

## 🔐 APT Repo (signiert, ab v2.0)

```bash
curl -fsSL https://<owner>.github.io/<repo>/apt/checkzombies-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/checkzombies-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/checkzombies-archive-keyring.gpg] https://<owner>.github.io/<repo>/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/checkzombies.list

sudo apt update && sudo apt install checkzombies
```

## systemd (optional)

Units sind optional und machen systemd **nicht** zur harten Abhängigkeit des CLI-Cores.

**Installieren & aktivieren**
```bash
sudo ./scripts/systemd_install.sh --watch
sudo ./scripts/systemd_install.sh --auto
```

**Status**
```bash
systemctl status checkzombies.service
systemctl list-timers | grep checkzombies
```

**Logs**
```bash
journalctl -u checkzombies.service -f
journalctl -u checkzombies-auto.service --since today
```

**Stop/Disable/Uninstall**
```bash
sudo ./scripts/systemd_install.sh --uninstall
```

Hinweis: Root ist erforderlich (Prozesse terminieren + Services verwalten).

## 🔚 Exit-Codes

- `0`: keine Zombies gefunden oder erfolgreich bereinigt
- `1`: Fehler (z. B. ungültige Option)
- `2`: Zombies gefunden, aber nicht bereinigt

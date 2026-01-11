# checkzombies 🧟‍♂️ Zombie Process Manager

[![Release](https://img.shields.io/github/v/release/161sam/checkzombies)](https://github.com/161sam/checkzombies/releases)

**Linux-Tool zum Finden und sicheren Bereinigen von Zombie-Prozessen**

## 🚀 Schnellstart

```bash
curl -sSL https://github.com/161sam/checkzombies/releases/latest/download/checkzombies -o /usr/local/bin/
chmod +x /usr/local/bin/checkzombies
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
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/install.sh | sudo REPO=<owner>/<repo> bash
````

### Option B: Release .deb (verifiziert)

```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/install.sh | sudo REPO=<owner>/<repo> bash -s -- --method deb
```

### Version pinnen

```bash
curl -fsSL https://raw.githubusercontent.com/<owner>/<repo>/main/scripts/install.sh | sudo REPO=<owner>/<repo> bash -s -- --version v1.0.0
```

## 🔐 APT Repo (signiert, ab v2.0)

```bash
curl -fsSL https://<owner>.github.io/<repo>/apt/checkzombies-archive-keyring.gpg \
  | sudo tee /usr/share/keyrings/checkzombies-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/checkzombies-archive-keyring.gpg] https://<owner>.github.io/<repo>/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/checkzombies.list

sudo apt update && sudo apt install checkzombies
```

## 🔚 Exit-Codes

- `0`: keine Zombies gefunden oder erfolgreich bereinigt
- `1`: Fehler (z. B. ungültige Option)
- `2`: Zombies gefunden, aber nicht bereinigt

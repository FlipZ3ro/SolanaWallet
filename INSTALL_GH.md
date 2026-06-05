# Install GitHub CLI

## Ubuntu/Debian (WSL2)

```bash
# Method 1: apt (mudah)
sudo apt update
sudo apt install -y gh

# Method 2: Manual install (kalau apt tidak work)
(type -p wget || sudo apt install wget -y) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y
```

## macOS

```bash
brew install gh
```

## Windows

```bash
winget install GitHub.cli
```

---

## Setelah Install

```bash
# Cek versi
gh --version

# Login
gh auth login
```

Pilih:
- **Account**: GitHub.com
- **Protocol**: HTTPS
- **Authenticate**: Login with web browser

# Security Policy

## Supported Versions

Only the latest commit on `main` is actively maintained. Older states of the repo are not patched.

| Version | Supported |
|---|---|
| `main` (latest) | ✅ |
| Older commits | ❌ |

---

## Scope

This repo distributes shell scripts and config files that are copied into `$HOME` and executed with user-level permissions. Security concerns relevant to this project include:

- **Malicious or unintended commands** in `install.sh` or any script under `.local/bin/scripts/`
- **Unsafe file permissions** set by the installer
- **Credential or secret leakage** in config files
- **Dependency confusion** — a bundled package name shadowing a legitimate system package

General Hyprland, Wayland, or Arch Linux vulnerabilities are **out of scope** — report those upstream to the respective projects.

---

## Reporting a Vulnerability

> [!IMPORTANT]
> **Do not open a public GitHub issue for security vulnerabilities.** This exposes users before a fix is available.

To report a vulnerability privately:

1. Go to the [Security Advisories](https://github.com/Cybersnake223/Hypr/security/advisories/new) page for this repo and open a **private advisory**.
2. Include as much detail as possible:
   - Which file(s) are affected
   - Steps to reproduce or trigger the issue
   - Potential impact (privilege escalation, data exposure, etc.)
   - A suggested fix if you have one

You can expect an acknowledgement within **72 hours** and a status update within **7 days**.

---

## Disclosure Policy

- Vulnerabilities will be fixed on `main` as quickly as possible.
- A public advisory will be published **after** a fix is available.
- Credit will be given to the reporter unless anonymity is requested.

---

## Security Best Practices for Users

- Always run `./install.sh --dry-run` before a real install to preview every action.
- Review scripts in `.local/bin/scripts/` before adding them to your `$PATH`.
- Do not run `install.sh` as `root` — it is designed for normal user execution only.
- Keep your Arch packages up to date: `yay -Syu`

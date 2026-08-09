# Windows RDP via Tailscale + GitHub Actions

Spin up a **full Windows desktop** (GitHub-hosted runner) and connect to it via
RDP — routed privately over [Tailscale](https://tailscale.com) so no port
forwarding or public IP is required.

```
Your laptop  ──Tailscale──►  GitHub runner (Windows)
                                   │
                                 RDP 3389
```

---

## Prerequisites

| What | Where |
|------|-------|
| Free Tailscale account | <https://login.tailscale.com/start> |
| Tailscale installed on **your** machine | <https://tailscale.com/download> |
| GitHub repo (any visibility) | — |

---

## 1 · Get a Tailscale auth key

1. Open <https://login.tailscale.com/admin/settings/keys>
2. Click **Generate auth key**
3. Enable **Reusable** and **Ephemeral**
   - *Ephemeral* = the runner auto-removes from your network when the job ends
4. Copy the key (starts with `tskey-auth-…`)

---

## 2 · Add the secret to your repo

```
GitHub repo → Settings → Secrets and variables → Actions → New repository secret

Name:   TAILSCALE_AUTHKEY
Value:  tskey-auth-xxxxxxxxxxxx
```

---

## 3 · Add the workflow file

Copy `.github/workflows/windows-rdp.yml` from this repo into your own, then
push to `main` (or any branch).

---

## 4 · Start a session

1. Go to **Actions → 🖥️ Windows RDP via Tailscale → Run workflow**
2. Fill in the inputs:

   | Input | Default | Notes |
   |-------|---------|-------|
   | `timeout_minutes` | `60` | Max 350 (≈ 6 h). Job is killed after 360 min anyway. |
   | `rdp_password` | *(auto)* | Leave blank for a generated password |
   | `hostname` | `gh-windows-rdp` | Visible in your Tailscale admin panel |

3. Click **Run workflow**

---

## 5 · Find your credentials

Once the **Connect to Tailscale** step finishes (~1 min), expand it in the
Actions log to see:

```
==============================================
   ✅  RDP SESSION READY
==============================================
   Host     : 100.x.y.z
   Port     : 3389
   Username : Administrator
   Password : Gh••••••••9!
==============================================
```

---

## 6 · Connect via RDP

### Windows
```
mstsc /v:100.x.y.z
```
or open **Remote Desktop Connection** and enter the Tailscale IP.

### macOS — Microsoft Remote Desktop
1. Install [Microsoft Remote Desktop](https://apps.apple.com/app/microsoft-remote-desktop/id1295203466)
2. Add PC → PC name: `100.x.y.z`
3. User account → add `runneradmin` + password

### macOS — built-in (CoRD / Remmina / etc.)
Any RDP client that supports RDP 8+ will work.

### Linux
```bash
xfreerdp /v:100.x.y.z /u:runneradmin /p:'YOUR_PASSWORD' /size:1920x1080
```

### Optional: generate an `.rdp` shortcut file
```powershell
.\scripts\make-rdp-file.ps1 -IP 100.x.y.z -Username runneradmin
# then double-click github-runner.rdp
```

---

## How it works

```
workflow_dispatch
      │
      ▼
windows-latest runner boots
      │
      ├─ Enable RDP (registry + firewall)
      ├─ Set password on runneradmin
      ├─ Install Tailscale (silent /S)
      ├─ tailscale up --authkey --hostname --accept-routes
      │         ↓
      │   Runner joins YOUR Tailscale network
      │   and gets a stable 100.x.y.z address
      │
      └─ Sleep loop (prints status every 60 s)
             ↓ timeout reached
           Job exits → Tailscale removes the ephemeral node
```

---

## Security notes

- The runner is **ephemeral** — it disappears from your Tailscale network the
  moment the job ends or times out.
- RDP is only reachable from devices **already on your Tailscale network** —
  there is no public exposure.
- NLA (Network Level Authentication) is disabled to maximise client
  compatibility. Since access is already gated by Tailscale, the practical
  risk is low.
- The auto-generated password is 16 characters with mixed case, digits, and
  symbols. Use `rdp_password` input if you need something predictable.
- GitHub Actions logs **do** show the password in plain text — treat the log
  as sensitive and don't share it.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Could not retrieve Tailscale IP` | Check that `TAILSCALE_AUTHKEY` secret is set and the key hasn't expired |
| RDP connection refused | Wait ~60 s after the step prints the IP; the service may still be starting |
| "Your credentials did not work" | Copy the password exactly from the log (watch for leading/trailing spaces) |
| Can't reach the IP | Ensure Tailscale is running and logged in on your local machine |
| Session ends too early | Increase `timeout_minutes` (max 350) |

---

## License

MIT — use freely, no warranty.

# DNS / domain — **vihresearchlabs.ai** (new platform stack)

Live Terraform stacks: **`infra-live/prod/`**.

## Important — do not reuse production hostnames

Existing traffic uses **`api`**, **`www`**, **`voicebot`**, **`exotel`**, apex, etc. — **leave those alone**.  
This infrastructure uses a **separate** label so nothing clashes:

**`*.platform.vihresearchlabs.ai`**

## ACM certificate (one cert, four names)

| Use | Hostname |
|-----|----------|
| API (NLP / backend) | `api.platform.vihresearchlabs.ai` |
| WebSocket (if exposed separately) | `ws.platform.vihresearchlabs.ai` |
| Web / frontend | `app.platform.vihresearchlabs.ai` |
| Argo CD UI | `argocd.platform.vihresearchlabs.ai` |

Configured in **`infra-live/prod/pre/acm/terragrunt.hcl`**.

After ACM is **Issued**, add **Route 53** records (A alias or CNAME) for these names → **new** ALBs / Ingress only — not the legacy ELB.

**Route 53 validation:**

```bash
export VIH_ROUTE53_ZONE_VIHRESEARCHLABS="Zxxxxxxxxxxxx"
```

If the zone is in **another** AWS account, add ACM **validation CNAME** records manually.

---

## Same account as Terraform

1. Route 53 → **vihresearchlabs.ai** hosted zone → copy **Hosted zone ID**.
2. `export VIH_ROUTE53_ZONE_VIHRESEARCHLABS=...`
3. `cd infra-live/prod/pre/acm` → `terragrunt apply`

---

## After certificate is Issued

Point **`api.platform` / `ws.platform` / `app.platform` / `argocd.platform`** at the **new** cluster’s load balancers (see repo root **`README.md`**).

---

## Domain registered outside AWS

Create a Route 53 hosted zone, point registrar **NS** to Route 53, then follow above.

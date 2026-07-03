# stagecraft-helm

Helm charts for running the Stagecraft platform on the EKS cluster
provisioned by `stagecraft-infra`. One shared library chart
(`charts/common`) captures the near-identical Deployment/Service/ConfigMap/
ServiceAccount shape all five services follow; each service gets a thin
chart depending on it. The root chart is an umbrella that installs all five
in one shot.

## Layout

| Chart | What it deploys |
|---|---|
| `charts/common` | Library chart — no resources of its own, just named templates the others `include`. |
| `charts/api` | `stagecraft-api` Deployment + Service + Ingress (shares one ALB with frontend) + a pre-upgrade migration Job (`alembic upgrade head`). |
| `charts/worker` | `stagecraft-worker`'s two processes as separate Deployments — the Celery worker and the SQS→Celery consumer bridge — sharing one ServiceAccount/ConfigMap. No Service (nothing calls it over HTTP). |
| `charts/webhook` | `stagecraft-webhook` Deployment + Service + Ingress. |
| `charts/frontend` | `stagecraft-frontend` Deployment + Service + Ingress (catch-all `/`, same ALB group as api's `/api`). |
| `charts/mcp` | `stagecraft-mcp` Deployment + ClusterIP Service only — called in-cluster over SSE, never exposed externally, no AWS IAM role. |

Namespace: `stagecraft`. Service names: `stagecraft-<service>` (matches the k8s DNS defaults baked into each service's `config.py` after the rebrand).

## Secrets

This chart never templates plaintext secrets. Every Deployment's `envFrom` includes an **optional** `<service>-secrets` Secret reference — create it out-of-band (External Secrets Operator, Sealed Secrets, or `kubectl create secret` for a demo) before installing, containing whatever that service's `.env.example` lists (GitHub App credentials, `SECRET_KEY`/`TOKEN_ENCRYPTION_KEY`, AWS creds if not using IRSA, etc).

## Usage

```bash
# One-time: create the <service>-secrets Secret for each of the 5 services first.

helm dependency update .
helm upgrade --install stagecraft . -f values.yaml -f values-dev.yaml \
  --namespace stagecraft --create-namespace
```

Swap `values-dev.yaml` for `values-staging.yaml` / `values-prod.yaml` as appropriate. Prod's overlay expects the IRSA role ARNs from `terraform output` in `stagecraft-infra` — fill those in before applying.

## AWS Load Balancer Controller

`stagecraft-infra` provisions the IAM role (`lb_controller_role_arn` output); this repo doesn't install the controller itself. Install it via its own Helm chart before the `api`/`webhook`/`frontend` Ingress resources here can provision an ALB:

```bash
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=stagecraft \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"=<lb_controller_role_arn output>
```

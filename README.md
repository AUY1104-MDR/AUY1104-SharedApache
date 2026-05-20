# AUY1104-SharedApache

Repositorio dedicado al **servicio Apache HTTP** desplegado en k3s para la Evaluación Sumativa 2 (AUY1104 — Ciclo de Vida del Software II).

Cubre el requisito de la sección 7 de la pauta: aplicación basada en Apache, expuesta vía NodePort en el puerto **30100**.

## Contenido del repositorio

| Ruta | Propósito |
|---|---|
| `Dockerfile` | Imagen basada en `httpd:2.4-alpine`. Apache escucha internamente en `30100`. |
| `index.html` | Página estática personalizada que sirve el contenedor. |
| `k8s/deployment.yml` | `Deployment` con estrategia `RollingUpdate`, `livenessProbe` y `readinessProbe`. La imagen se inyecta vía `IMAGE_PLACEHOLDER`. |
| `k8s/service.yml` | `Service` tipo `NodePort` en el puerto `30100`. |
| `.github/workflows/deploy.yml` | Pipeline CI/CD: build de la imagen, push a Docker Hub y despliegue por SSH al nodo k3s. |

## Flujo CI/CD

```
push tag v*
   ↓
Build Docker (apache-custom:<tag> + :latest)
   ↓
Push a Docker Hub
   ↓
SCP de manifiestos al servidor k3s
   ↓
sed → kubectl apply → rollout status → curl :30100
```

Disparador único: `push` de un tag `v*` (ej. `v0.0.5`). El versionamiento es obligatorio y no se permite ejecución manual.

Secrets/Variables necesarios (configurados a nivel de organización + variable por repo):
- `secrets.DOCKER_USERNAME` / `secrets.DOCKER_PASSWORD`
- `secrets.EA2_SSH_PRIVATE_KEY`
- `vars.K3S_SERVER_PUBLIC_IP`

## URL esperada

```
http://<IP_PUBLICA>:30100
```

## Imagen publicada

- Docker Hub: `marcdelrio/apache-custom`
- Tags: el del push (`v0.0.x`) y `latest`.

## Rollback

Dos vías equivalentes:

```bash
# 1. Volver a la revisión anterior del Deployment
kubectl rollout undo deployment/apache-30100
kubectl rollout history deployment/apache-30100

# 2. Re-aplicar un tag previo desde Docker Hub
kubectl set image deployment/apache-30100 \
    apache=marcdelrio/apache-custom:v0.0.3
kubectl rollout status deployment/apache-30100
```

## Verificación manual

```bash
kubectl get pods -l app=apache-30100 -o wide
kubectl get svc apache-svc-30100
curl http://<IP_PUBLICA>:30100
```

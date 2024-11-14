---
hide:
  - toc
---

# Run Portainer

The bootstrap script downloads the `components/portainer/docker-compose.yml` script from this repo into `/opt/vm-ubuntu/portainer/docker-compose.yml`.

The portainer password is written from the `docker-compose.yml` file to the local filesystem when starting the stack. The password is written into `portainer.passwd` next to the `docker-compose.yml`.

Alternatively, you can download the `docker-compose.yml` file manually and start all services.

```bash
curl -fsSL https://raw.githubusercontent.com/sommerfeld-io/vm-ubuntu/refs/heads/main/components/portainer/docker-compose.yml -o docker-compose.yml
docker-compose up -d
```

This configuration starts portainer on port `7990`.

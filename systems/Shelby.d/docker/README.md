# Helpful Info
Start service:
```
docker compose --project-directory /path/to/docker/dir up -d
```

Stop service:
```
docker compose --project-directory /path/to/docker/dir down
```

Start docker:
```
doas systemctl start docker.socket
doas systemctl start docker
```

Stop docker:
```
doas systemctl stop docker.socket
doas systemctl stop docker
```

Docker full reset:
```sh
docker system prune -a
systemctl stop docker
rm -rf /var/lib/docker/containers/*
rm -rf /var/lib/docker/overlay2/*
systemctl start docker
```

# Resources
- https://blog.devops.dev/stopped-docker-compose-but-services-still-running-heres-how-i-fixed-this-strange-issue-58bb6a0c90c4

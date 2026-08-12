#!/bin/sh

# ----- HELPFUL INFO -----
# Help: https://blog.devops.dev/stopped-docker-compose-but-services-still-running-heres-how-i-fixed-this-strange-issue-58bb6a0c90c4
#
# Docker full reset:
# docker system prune -a
# systemctl stop docker
# rm -rf /var/lib/docker/containers/*
# rm -rf /var/lib/docker/overlay2/*
# systemctl start docker

# ----- SETTINGS -----
SERVICES_DIR=""

# ----- SCRIPT -----
case "$1" in
	"start")
		printf '%s\n' "Bringing Immich online... "
		docker compose --project-directory "$SERVICES_DIR/Immich" up -d
		printf '%s\n' "Immich now online."
		printf '%s\n' "Bringing NGINX Proxy Manager online... "
		docker compose --project-directory "$SERVICES_DIR/NGINX_Proxy_Manager" up -d
		printf '%s\n' "NGINX Proxy Manager now online."
		;;
	"stop")
		printf '%s\n' "Bringing Immich offline... "
		docker compose --project-directory "$SERVICES_DIR/Immich" down
		printf '%s\n' "Immich now offline."
		printf '%s\n' "Bringing NGINX Proxy Manager offline... "
		docker compose --project-directory "$SERVICES_DIR/NGINX_Proxy_Manager" down
		printf '%s\n' "NGINX Proxy Manager now offline."
		;;
	"offline")
		printf '%s\n' "Bringing docker offline"
		doas systemctl stop docker.socket
		doas systemctl stop docker
		printf '%s\n' "Docker now offline."
		;;
	"online")
		printf '%s\n' "Bringing docker online..."
		doas systemctl start docker.socket
		doas systemctl start docker
		printf '%s\n' "Docker now online."
		;;
	"full-reset")
		printf'full reset commencing in 5 minutes...\n'
		sleep 5m
		printf 'commencing full reset'

		printf '%s\n' "Bringing Immich offline... "
		docker compose --project-directory "$SERVICES_DIR/Immich" down
		printf '%s\n' "Immich now offline."
		printf '%s\n' "Bringing NGINX Proxy Manager offline... "
		docker compose --project-directory "$SERVICES_DIR/NGINX_Proxy_Manager" down
		printf '%s\n' "NGINX Proxy Manager now offline."

		printf 'doas docker system prune -a'
		doas docker system prune -a
		printf 'doas rm -rf /var/lib/docker/containers/*'
		doas rm -rf /var/lib/docker/containers/*
		printf 'doas rm -rf /var/lib/docker/overlay2/*'
		doas rm -rf /var/lib/docker/overlay2/*

		printf 'reset complete'
		;;
	*)
		printf 'options: start, stop, offline, online, full-reset\n'
		exit 1
		;;
esac

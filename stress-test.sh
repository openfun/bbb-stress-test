#!/usr/bin/env bash
set -eo pipefail

source .env


CLIENTS_LISTEN_ONLY=${BBB_CLIENTS_LISTEN_ONLY:-2}
CLIENTS_MIC_ONLY=${BBB_CLIENTS_MIC_ONLY:-0}
CLIENTS_WEBCAM_MIC=${BBB_CLIENTS_WEBCAM_MIC:-2}

docker-compose up --scale webcam-mic="${CLIENTS_WEBCAM_MIC}" --scale mic-only="${CLIENTS_MIC_ONLY}" --scale listen-only="${CLIENTS_LISTEN_ONLY}"

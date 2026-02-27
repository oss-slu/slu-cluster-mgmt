#!/bin/bash
BACKUP_DIR="/home/sluinfra/backups"
mkdir -p \$BACKUP_DIR
DATE=\$(date +%Y%m%d_%H%M)
POD_NAME=\$(microk8s kubectl get pod -l app=postgres -o jsonpath="{.items[0].metadata.name}")

echo "Backing up \$POD_NAME..."
microk8s kubectl exec \$POD_NAME -- pg_dump -U postgres postgres > \$BACKUP_DIR/coredesk_\$DATE.sql
echo "Saved to \$BACKUP_DIR/coredesk_\$DATE.sql"

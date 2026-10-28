#!/bin/bash
mkdir -p backups
docker exec postgres_Farid pg_dump -U postgres -n salam postgres \
  > backups/salam_$(date +%Y%m%d_%H%M%S).sql
echo "Backup selesai"

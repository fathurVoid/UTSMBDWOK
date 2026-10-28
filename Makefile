up:
	docker compose up -d
down:
	docker compose down
reset:
	docker compose down -v && docker compose up -d
test:
	docker exec -i postgres_Farid psql -U postgres < tests/demo.sql
backup:
	bash scripts/backup.sh
psql:
	docker exec -it postgres_Farid psql -U postgres

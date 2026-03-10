all:
	mkdir -p /home/rjaada/data/wordpress_files /home/rjaada/data/wordpress_db
	docker-compose -f srcs/docker-compose.yml up --build -d

down:
	docker-compose -f srcs/docker-compose.yml down

clean:
	docker-compose -f srcs/docker-compose.yml down -v
	docker system prune -af
	sudo rm -rf /home/rjaada/data/wordpress_files /home/rjaada/data/wordpress_db

re: clean all

.PHONY: all down clean re

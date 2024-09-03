
build-container:
	caffeinate nix build .#container 
	#./result | docker load

run:
	nix run .#app

run-container:
	docker run -it --rm app:latest

develop:
	nix develop

develop-poetry:
	nix develop .#poetry

clear-caches:
	nix-store --delete /nix/store/*app.tar.gz.drv
	docker system prune -af

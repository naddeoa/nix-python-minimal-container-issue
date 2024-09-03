

build-container:
	caffeinate nix build .#container

run:
	nix run .#app

develop:
	nix develop

develop-poetry:
	nix develop .#poetry

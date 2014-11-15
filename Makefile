PACK=pkgs.gnome3_12.evolution-mapi

build:
	nix-build -A $(PACK)

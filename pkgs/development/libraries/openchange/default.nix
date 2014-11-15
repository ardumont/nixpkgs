{ pkgs, stdenv, fetchurl, autoconf, autogen, automake, gettext, libX11
, mesa, pkgconfig, python, utilmacros
}:

stdenv.mkDerivation rec {
  version = "2.2-NANOPROBE";
  name = "openchange-${version}";

  src = fetchurl {
    url = "https://github.com/openchange/openchange/releases/download/${name}/${name}.tar.gz";
    sha256 = "127nki1pjjk0rl5bd91p0isz0c9cfbb0sc292vq8a3ip2rnv4ppi";
  };

  buildInputs = with pkgs; [
    autoconf autogen automake gettext libX11 mesa pkgconfig python
    utilmacros mysql perl samba4 talloc
  ];

  preConfigure = ''
    export PKG_CONFIG_PATH="${pkgs.samba4}/lib/:${pkgs.samba4}/lib/private/:/usr/local/samba/lib:/usr/local/samba/pkgconfig:$PKG_CONFIG_PATH"
    echo "############ tony: PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
    echo "############ tony: SAMBA_CFLAGS=$SAMBA_CFLAGS"
    echo "############ tony: SAMBA_LIBS=$SAMBA_LIBS"
    echo "############ "
  '';

  enableParallelBuilding = true;

  buildPhase = ''
    ./autogen.sh --prefix="$out" && ./configure && make && make test
  '';

  meta = with stdenv.lib; {
    description = "A library for handling exchange protocol";
    homepage = https://github.com/openchange/openchange;
    # license = licenses.mit;
    # maintainers = [ maintainers.goibhniu ];
    platforms = platforms.linux;
  };
}

{ stdenv
, fetchurl
, cmake
, pkgconfig
, gtk2
, poppler
, poppler_data
, freetype
, libpthreadstubs
, libXdmcp
, libxshmfence
, libxkbcommon
, epoxy
}:

stdenv.mkDerivation rec {
  version = "0.1.f7f7b9c";
  name = "apvlv-${version}";

  src = fetchurl {
    url = "https://github.com/downloads/naihe2010/apvlv/${name}-Source.tar.gz";
    sha256 = "125nlcfjdhgzi9jjxh9l2yc9g39l6jahf8qh2555q20xkxf4rl0w";
  };

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${poppler}/include/poppler"
  '';

  buildInputs = [
    pkgconfig cmake
     poppler
     freetype gtk2
     libpthreadstubs libXdmcp libxshmfence # otherwise warnings in compilation
   ];

  installPhase = ''
    # binary
    mkdir -p $out/bin
    cp src/apvlv $out/bin/apvlv
    chmod +x $out/bin/apvlv

    # pdf startup as doc
    mkdir -p $out/share/doc/apvlv/
    cp ../Startup.pdf $out/share/doc/apvlv/Startup.pdf
  '';

  meta = {
    homepage = "http://naihe2010.github.io/apvlv/";
    description = "PDF viewer with Vim-like behaviour";

    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.ardumont ];
  };

}

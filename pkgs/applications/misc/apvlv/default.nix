{ stdenv
, fetchurl
, cmake
, pkgconfig
, gtk2
, poppler
, poppler_data
# , poppler_utils
, freetype
, libpthreadstubs
, libXdmcp
, libxshmfence
, libxkbcommon
, epoxy
# , git
# , tree
}:

stdenv.mkDerivation rec {
  version = "0.1.f7f7b9c";
  # version = "0.1.5";
  name = "apvlv-${version}";

  src = fetchurl {
    url = "https://github.com/downloads/naihe2010/apvlv/${name}-Source.tar.gz";
    sha256 = "125nlcfjdhgzi9jjxh9l2yc9g39l6jahf8qh2555q20xkxf4rl0w";
    # url = "https://github.com/naihe2010/apvlv/archive/v${version}.tar.gz";
    # sha256 = "12ha212a8c9z02q3in47ggf1762l4vm52isisq9fr7rwwrbq3afw";
  };

  preConfigure = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -I${poppler}/include/poppler"
  '';

  buildInputs = [
    pkgconfig cmake
     poppler poppler_data
     freetype gtk2 libpthreadstubs libXdmcp libxshmfence libxkbcommon epoxy
   ];

  installPhase = ''
    # echo "pwd: `pwd`"
    # tree ..
    # echo "out: $out"
    # tree $out

    # binary
    mkdir -p $out/bin
    cp src/apvlv $out/bin/apvlv
    chmod +x $out/bin/apvlv

    # pdf startup as doc
    mkdir -p $out/share/doc/apvlv/
    cp ../Startup.pdf $out/share/doc/apvlv/Startup.pdf
    # cp ../main_menubar.glade $out/share/doc/apvlv/
  '';

  meta = {
    homepage = "http://naihe2010.github.io/apvlv/";
    description = "PDF viewer with Vim-like behaviour";

    platforms = stdenv.lib.platforms.unix;
    maintainers = [ stdenv.lib.maintainers.ardumont ];
  };

}

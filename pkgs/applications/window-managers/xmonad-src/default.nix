{ stdenv, fetchdarcs, ghc, libXext, libX11, libXinerama}:

stdenv.mkDerivation rec {
  version = "0.12";
  name = "xmonad-src-${version}";

  src = fetchdarcs {
    url = http://code.haskell.org/xmonad;
  };

  libPath = stdenv.lib.makeLibraryPath [ libXext libX11 libXinerama ];

  meta = with stdenv.lib; {
    homepage = "http://xmonad.org";
    description = "A tiling window manager";
    license = licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = with lib.maintainers; [ ardumont ];
  };
}

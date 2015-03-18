{ stdenv, fetchurl, haskellPackages }:

stdenv.mkDerivation rec {
  version = "0.12";
  name = "xmonad-snapshot-${version}";

  src = fetchurl {
    url = "http://code.haskell.org/xmonad/xmonad.tar.gz";
    sha256 = "1hy8s3zjiy8l64s1zvcjlixx1d7y2bpljqvzf6s0fkf2x5238qbk";
  };

  buildInputs = [ haskellPackages.cabalInstall ];

  buildPhase = ''
    ${haskellPackages.cabalInstall}/bin/cabal install ${src}
  '';

  meta = with stdenv.lib; {
    homepage = "http://xmonad.org";
    description = "A tiling window manager";
    license = licenses.bsd3;
    platforms = self.ghc.meta.platforms;
    maintainers = [ lib.maintainers.ardumont ];
  };
}

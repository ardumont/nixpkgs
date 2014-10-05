{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  stable-version = "1.2";
  urlName = "TuxGuitar-${stable-version}";
  name = "tux-guitar-${stable-version}";

  src = fetchurl {
    # url = "http://downloads.sourceforge.net/project/tuxguitar/TuxGuitar/${urlName}/${name}-linux-x86.tar.gz?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Ftuxguitar%2F&ts=1412497814&use_mirror=freefr";
    url = "http://downloads.sourceforge.net/project/tuxguitar/TuxGuitar/${urlName}/${name}-linux-x86.tar.gz";
    sha256 = "8bfecd91ac33e63f29bd1503a7082533f631b6835b5bb2dfb1178d026628abe2";
  };

  doCheck = true;

  meta = {
    description = "A free/open source Guitar tablature editor.";
    longDescription = ''
      TuxGuitar is a multitrack guitar tablature editor and player written in Java-SWT. 
      It can open GuitarPro, PowerTab and TablEdit files.
    '';
    homepage = http://sourceforge.net/projects/tuxguitar/;
    license = stdenv.lib.licenses.gpl2;
    maintainers = [ stdenv.lib.maintainers.ludo ];
    platforms = stdenv.lib.platforms.all;
  };
}

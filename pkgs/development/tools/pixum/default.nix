{ stdenv, makeWrapper, requireFile, libX11, zlib, sqlite, libxml2, glib,
  gstreamer, gst_plugins_base, expat, libxcb, libSM, libICE, fontconfig,
  freetype, libXrender, xkeyboardconfig, dbus_libs }:

stdenv.mkDerivation rec {
  name = "pixum";
  version = "0.0.1";

  src = requireFile {
    message = ''
      Please download pixum and then use nix-prefetch-url file:///path/to/${name}-${version}.tar.gz
    '';
    name = "${name}-${version}.tar.gz";
    sha256 = "0lzyn2h9lmn1di5bkn0qsrkd8sw0hyyjpmhwv84x7ffsxfdx32l6";
  };

  unpackPhase = ''
    mkdir $out
    tar xf $src -C $out
    mv $out/Univers* $out/pixum
  '';

   buildInputs = [ makeWrapper ];

   libPath = stdenv.lib.makeLibraryPath [
     stdenv.cc.cc.lib libX11 zlib sqlite libxml2 glib
     gstreamer gst_plugins_base
     expat
     libSM libICE fontconfig freetype libXrender dbus_libs
   ];

  installPhase = ''
    patchelf --interpreter ${stdenv.glibc.out}/lib/ld-linux-x86-64.so.2 \
      $out/pixum

    # --prefix QT_PLUGIN_PATH : "$out/platforms" \
    # --prefix QT_QPA_PLATFORM_PLUGIN_PATH : "$out/platforms" \
    # --prefix QT_DEBUG_PLUGINS : "1" \

    wrapProgram $out/pixum \
      --prefix QT_XKB_CONFIG_ROOT : "${xkeyboardconfig}" \
      --prefix LD_LIBRARY_PATH : "$out:${libPath}:\$LD_LIBRARY_PATH"
  '';

  phases = "unpackPhase installPhase";

  meta = with stdenv.lib; {
    description = "Pixum";
    homepage = "https://www.pixum.com/";
    license = licenses.unfree;
    maintainers = [ maintainers.ardumont ];
    platforms = platforms.linux;
  };
}

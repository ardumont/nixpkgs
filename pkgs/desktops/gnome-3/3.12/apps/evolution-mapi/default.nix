{ pkgs ? (import <nixpkgs> {})
, stdenv
, fetchurl
, gcr
, evolution
}:

# { stdenv, intltool, fetchurl, libxml2, webkitgtk, highlight
# , pkgconfig, gtk3, glib, hicolor_icon_theme, libnotify, gtkspell3
# , makeWrapper, itstool, shared_mime_info, libical, db, gcr
# , gnome3, librsvg, gdk_pixbuf, libsecret, nss, nspr, icu, libtool
# , libcanberra_gtk3, bogofilter, gst_all_1, procps, p11_kit }:

stdenv.mkDerivation rec {
  name = "EVOLUTION_MAPI_3_12_5";

  src = fetchurl {
    # sha256 = "9c38917cfe769e7848f84ce890643cf4d6dfb08491cf66282548a046ab060a31";
    sha256 = "1ync13x57d3l3cr5z4izrams2pfi09bp6bdwsvznpz0jmfnricfq";
    url = "https://github.com/GNOME/evolution-mapi/archive/${name}.tar.gz";
    # sha256 = "d8b198adab12fc6bffd6bc2d735702d15da1abca3f925f321b74b453fa08ccfa";
    # url = "http://ftp.acc.umu.se/pub/gnome/sources/evolution-mapi/3.12/${name}.tar.xz";
  };

  buildInputs = with pkgs; [
    gnome3_12.evolution_data_server
    gnome3_12.evolution
    gnome3_12.gnome_common pkgconfig glib intltool
    gtk3 itstool libxml2 libtool
    # gdk_pixbuf librsvg db icu
    # libsecret libical gcr
    # webkitgtk shared_mime_info gtkspell3
    # libcanberra_gtk3 bogofilter
    # gst_all_1.gstreamer gst_all_1.gst-plugins-base p11_kit
    # hicolor_icon_theme
    # nss nspr libnotify procps highlight makeWrapper
    # gnome3_12.gnome_desktop gnome3_12.gtkhtml gnome3_12.libgdata
    # gnome3_12.gnome_icon_theme_symbolic gnome3_12.gsettings_desktop_schemas
    # gnome3_12.libgweather gnome3_12.gnome_icon_theme
  ];

  #configureFlags = [ "--disable-spamassassin" "--disable-pst-import" ];

  # NIX_CFLAGS_COMPILE = "-I${nspr}/include/nspr -I${nss}/include/nss -I${glib}/include/gio-unix-2.0";
  #EVOLUTION_DATA_SERVER_CFLAGS EVOLUTION_DATA_SERVER_LIBS

  buildPhase = ''
    ./autogen.sh --prefix=$out
  '';

  # doCheck = true;

  enableParallelBuilding = true;

  meta = {
    description = "Evolution Mapi, a plugin to enhance Evolution with MS abilities.";
    longDescription = ''
      Evolution Mapi is an open source, freely distributed and portable software
      project, a plugin for the powerful and award-winning Evolution email and
       calendar application used in the GNOME desktop environment.
    '';
    homepage = https://github.com/GNOME/evolution-mapi;
    license = stdenv.lib.licenses.gpl3Plus;
#    maintainers = [ stdenv.lib.maintainers.ludo ];
    platforms = stdenv.lib.platforms.all;
  };
}

{ stdenv
, fetchFromGitLab
, meson
, ninja
, pkg-config
, wrapGAppsHook
, libinput
, gnome3
, glib
, gtk3
, wayland
, dbus
, cmake
, libdrm
, libxkbcommon
, wlroots
}:

stdenv.mkDerivation rec {
  pname = "phoc";
  version = "0.4.1";

  src = fetchFromGitLab {
    domain = "source.puri.sm";
    owner = "Librem5";
    repo = pname;
    rev = "v${version}";
    sha256 = "194qkri8k8nwyynyd4d9w7h6hvxxh6dnck57c99yfns08sa1z0bj";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wrapGAppsHook
  ];

  buildInputs = [
    libdrm.dev
    libxkbcommon
    libinput
    glib
    gtk3
    gnome3.gnome-desktop
    # For keybindings settings schemas
    gnome3.mutter
    wayland
    wlroots
  ];

  mesonFlags = ["-Dembed-wlroots=disabled"];

  postInstall = ''
    ${glib.dev}/bin/glib-compile-schemas $out/share/glib-2.0/schemas
  '';

  meta = with stdenv.lib; {
    description = "Wayland compositor for mobile phones like the Librem 5";
    homepage = "https://source.puri.sm/Librem5/phoc";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ masipcat ];
    platforms = platforms.linux;
  };
}

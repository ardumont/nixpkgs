{ stdenv, lib, fetchFromGitHub, coreutils, ubootOdroidN2, runtimeShell, hardkernel-u-boot }:

stdenv.mkDerivation {
  name = "odroid-n2-bootloader-2015-01";

  src = hardkernel-u-boot;

  buildCommand = ''
    install -Dm644 -t $out/lib/sd_fuse-n2 $src/sd_fuse/hardkernel_1mb_uboot/{bl2,tzsw}.*
    install -Dm644 -t $out/lib/sd_fuse-n2 $src/sd_fuse/hardkernel/bl1.*
    ln -sf ${ubootOdroidN2}/u-boot-dtb.bin $out/lib/sd_fuse-n2/u-boot-dtb.bin

    install -Dm755 $src/sd_fuse/hardkernel_1mb_uboot/sd_fusing.1M.sh $out/bin/sd_fuse-n2
    sed -i \
      -e '1i#!${runtimeShell}' \
      -e '1iPATH=${lib.makeBinPath [ coreutils ]}:$PATH' \
      -e '/set -x/d' \
      -e 's,.\/sd_fusing\.sh,sd_fuse-n2,g' \
      -e "s,\./,$out/lib/sd_fuse-n2/,g" \
      $out/bin/sd_fuse-n2
  '';

  meta = with stdenv.lib; {
    platforms = platforms.linux;
    license = licenses.unfreeRedistributableFirmware;
    description = "Secure boot enabled boot loader for ODROID-N2";
    maintainers = with maintainers; [ ardumont ];
  };
}

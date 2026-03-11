{ stdenv, lib, kernel, fetchFromGitHub }:

stdenv.mkDerivation {
  pname = "simagic-ff";
  version = "52e73e7";

  src = fetchFromGitHub {
    owner = "JacKeTUs";
    repo = "simagic-ff";
    rev = "52e73e70b5b339f85cab5f7205838d480da27b2f";
    hash = "sha256-7i+emBQjQu5pjA/8utIJTPlMcepxTYXLkjSVfft94qs=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    install -D hid-simagic-ff.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/hid/hid-simagic-ff.ko
  '';

  meta = with lib; {
    description = "Linux kernel driver for Simagic force feedback devices";
    homepage = "https://github.com/JacKeTUs/simagic-ff";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}

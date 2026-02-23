{ lib, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation rec {
  pname = "izosevka";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "iztiev";
    repo = "Izosevka";
    rev = "HEAD";  # Use latest commit, or pin to a specific commit SHA
    sha256 = "sha256-j2LyD39r6KDLcHB7npYhmoeKx8m35safwO3Hi6FPAbc=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 Izosevka/TTF/*.ttf -t $out/share/fonts/truetype/izosevka

    runHook postInstall
  '';

  meta = with lib; {
    description = "Izosevka - Custom Iosevka font variant";
    homepage = "https://github.com/iztiev/Izosevka";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = [ ];
  };
}

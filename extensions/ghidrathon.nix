{ stdenv, ghidra, fetchFromGitHub, gradle, openjdk17, python3, python3Packages, unzip, ... }:
stdenv.mkDerivation rec {
  pname = "Ghidrathon";
  version = "4.0.0";

  src = fetchFromGitHub {
    owner = "mandiant";
    repo = "Ghidrathon";
    rev = "v${version}";
    hash = "sha256-RPAKiBxnHzonBQgQCP5iqN8Q+d3S385RcHAQh4Rx4HU=";
    name = pname;
  };

  sourceRoot = "${src.name}";

  postUnpack = ''
    cp ${python3Packages.jep}/${python3.sitePackages}/jep/jep-${python3Packages.jep.version}.jar $sourceRoot/lib/
  '';

  nativeBuildInputs = [
    gradle
  ];

  buildPhase = ''
    gradle --offline --no-daemon --info -PGHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra -Dorg.gradle.java.home=${openjdk17}
  '';

  installPhase = ''
    mkdir -p $out/lib/ghidra/Ghidra/Extensions/
    ${unzip}/bin/unzip dist/*.zip -d $out/lib/ghidra/Ghidra/Extensions/
  '';

  postFixup = ''
    ${python3.withPackages (ps: [ python3Packages.jep ])}/bin/python3 ./util/ghidrathon_configure.py $out/lib/ghidra
  '';
}

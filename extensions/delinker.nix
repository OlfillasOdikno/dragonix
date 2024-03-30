{ stdenv, ghidra, perl, fetchurl, writeText, fetchFromGitHub, gradle, openjdk17, unzip, ... }:
let
  pname = "Delinker";
  version = "0.3.0";
  src = fetchFromGitHub rec {
    owner = "boricj";
    repo = "ghidra-delinker-extension";
    rev = "v${version}";
    name = repo;
    hash = "sha256-tGIFYaMbW8hxN64Sta4jUv3xME9XhezO8qC5dgRvUf8=";
    postFetch = ''
      sed -i 's/''${getGitHash()}/${version}/g' $out/build.gradle
    '';
  };

  deps = stdenv.mkDerivation {
    pname = "${pname}-deps";
    inherit version src;
    nativeBuildInputs = [ gradle perl ];
    buildPhase = ''
      export GRADLE_USER_HOME=$(mktemp -d)
      gradle --no-daemon -PGHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra -Dorg.gradle.java.home=${openjdk17} assemble
    '';
    # perl code mavenizes paths (com.squareup.okio/okio/1.13.0/a9283170b7305c8d92d25aff02a6ab7e45d06cbe/okio-1.13.0.jar -> com/squareup/okio/okio/1.13.0/okio-1.13.0.jar)
    installPhase = ''
      find $GRADLE_USER_HOME/caches/modules-2 -type f -regex '.*\.\(jar\|pom\)' \
        | perl -pe 's#(.*/([^/]+)/([^/]+)/([^/]+)/[0-9a-f]{30,40}/([^/\s]+))$# ($x = $2) =~ tr|\.|/|; "install -Dm444 $1 \$out/$x/$3/$4/$5" #e' \
        | sh

      mkdir -p $out/org/jetbrains/kotlin/{kotlin-stdlib-common,kotlin-stdlib-jdk8,kotlin-stdlib-jdk7}/1.5.31
      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.31/kotlin-stdlib-common-1.5.31.pom";
        hash = "sha256-thXpRrjD0r6pllLs2pfVfs+Dv180xl0oZ5CvI+USg8I=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.31/kotlin-stdlib-common-1.5.31.pom

      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.31/kotlin-stdlib-common-1.5.31.jar";
        hash = "sha256-36KhjiawKDiO4ZaNGZv28Wb3N6twScJaXi2mFEBOIq0=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-common/1.5.31/kotlin-stdlib-common-1.5.31.jar


      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk8/1.5.31/kotlin-stdlib-jdk8-1.5.31.pom";
        hash = "sha256-RREKqwB0eSuBWAewKy2vGNKzfodHrAaSqteg0C2ok98=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-jdk8/1.5.31/kotlin-stdlib-jdk8-1.5.31.pom

      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk8/1.5.31/kotlin-stdlib-jdk8-1.5.31.jar";
        hash = "sha256-tUj3dnqs8CnSQX5HRAdCvW0+vt4ZtgOG4jVUzlxMX9w=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-jdk8/1.5.31/kotlin-stdlib-jdk8-1.5.31.jar

      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk7/1.5.31/kotlin-stdlib-jdk7-1.5.31.pom";
        hash = "sha256-IxOEie4pOmgZcGiHd0X3AL+hGvmJGHvtPDB0zYwHl3g=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-jdk7/1.5.31/kotlin-stdlib-jdk7-1.5.31.pom

      cp ${fetchurl {
        url = "https://repo1.maven.org/maven2/org/jetbrains/kotlin/kotlin-stdlib-jdk7/1.5.31/kotlin-stdlib-jdk7-1.5.31.jar";
        hash = "sha256-olv0c1POiZ2EPL3e5RbWIac0c+f7qX+NAwHntK7XwV8=";
      }} $out/org/jetbrains/kotlin/kotlin-stdlib-jdk7/1.5.31/kotlin-stdlib-jdk7-1.5.31.jar
    '';
    dontStrip = true;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-PQytk8xyz25fTgCl76D6AJctSWFmSOyOPMhSlH+P/Bk=";
  };

  gradleInit = writeText "init.gradle" ''
    logger.lifecycle 'Replacing Maven repositories with empty directory...'
    gradle.projectsLoaded {
      rootProject.allprojects {
        buildscript {
          repositories {
            clear()
            maven { url '${deps}' }
          }
        }
        repositories {
          clear()
          maven { url '${deps}' }
        }
      }
    }
    settingsEvaluated { settings ->
      settings.pluginManagement {
        repositories {
          maven { url '${deps}' }
        }
      }
    }
  '';
in
stdenv.mkDerivation rec {

  inherit pname version src;

  sourceRoot = "${src.name}";

  nativeBuildInputs = [
    gradle
  ];

  buildPhase = ''
    gradle --offline --no-daemon --info -PGHIDRA_INSTALL_DIR=${ghidra}/lib/ghidra -Dorg.gradle.java.home=${openjdk17} --init-script ${gradleInit} buildExtension
  '';

  installPhase = ''
    mkdir -p $out/lib/ghidra/Ghidra/Extensions/
    ${unzip}/bin/unzip dist/*.zip -d $out/lib/ghidra/Ghidra/Extensions/
  '';
}

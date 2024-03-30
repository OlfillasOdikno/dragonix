{ python3Packages, fetchFromGitHub, openjdk17, ... }:
python3Packages.buildPythonPackage rec {
  pname = "jep";
  version = "4.2.0";
  src = fetchFromGitHub
    {
      owner = "ninia";
      repo = "jep";
      rev = "v${version}";
      hash = "sha256-RZX3OB3ocfVRKA3juYiOjcR+xDYUm1xsNmRxXOpPcSY=";
    };
  JAVA_HOME = openjdk17;
}

{ lib, openjdk17, gnused, symlinkJoin, makeWrapper, ghidra, extensions ? null, ... }:
symlinkJoin {
  name = "${ghidra.name}-with-extensions-${ghidra.version}";

  paths = [ ghidra ] ++ extensions;

  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    rm $out/lib/ghidra/support/launch.sh
    rm $out/lib/ghidra/ghidraRun
    cp ${ghidra}/lib/ghidra/ghidraRun $out/lib/ghidra/ghidraRun
    cp ${ghidra.src}/Ghidra/RuntimeScripts/Linux/support/launch.sh $out/lib/ghidra/support/launch.sh
    ${gnused}/bin/sed -i "/JAVA_CMD=/aCPATH=$out/lib/ghidra/Ghidra:\$CPATH" $out/lib/ghidra/support/launch.sh
    wrapProgram "$out/lib/ghidra/support/launch.sh" \
      --prefix PATH : ${lib.makeBinPath [ openjdk17 ]}
  '';

  meta = ghidra.meta // {
    # prefer wrapper over the package
    priority = (ghidra.meta.priority or 0) - 1;
  };
}

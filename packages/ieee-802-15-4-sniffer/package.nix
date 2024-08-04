{
  lib,
  stdenvNoCC,
  inputs,
  system,
}:

let 
  gnuradio = inputs.self.packages.${system}.gnuradio;
in
stdenvNoCC.mkDerivation {
  name = "oqpsk-sniffer";
  version = "1.0";
  src = ./.;

  nativeBuildInputs = [ gnuradio gnuradio.python.pkgs.wrapPython ];
  buildInputs = [ gnuradio.pythonEnv ];

  buildPhase = ''
    runHook preBuild
    export HOME=$TMPDIR
    GRCC="${lib.getExe' gnuradio "grcc"}"
    echo GRCC=$GRCC

    # Generate the flow graph both locally and in the (temporary) local gnuradio directory, so it can find it when building the next flow graph
    $GRCC ${gnuradio.pkgs.gr-ieee-802-15-4}/share/gr-ieee802_15_4/examples/ieee802_15_4_OQPSK_PHY.grc
    $GRCC -u ${gnuradio.pkgs.gr-ieee-802-15-4}/share/gr-ieee802_15_4/examples/ieee802_15_4_OQPSK_PHY.grc
    $GRCC soapy-oqpsk-sniffer.grc

    runHook postBuild
    '';


  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/${gnuradio.pythonEnv.sitePackages}
    cp ./*.py $out/${gnuradio.pythonEnv.sitePackages}
    cp ./oqpsk_sniffer.py $out/bin/802-15-4-sniffer
    runHook postInstall
  '';

  postFixup = ''
    patchShebangs $out/bin
    for cmd in $out/bin/*; do
      echo $cmd
      wrapProgram $cmd \
      --prefix PATH : "${gnuradio.pythonEnv}" \
      --prefix PYTHONPATH : "${gnuradio.pythonEnv}/${gnuradio.pythonEnv.sitePackages}:$out/${gnuradio.pythonEnv.sitePackages}"
    done
  '';
}


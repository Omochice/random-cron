{
  lib,
  stdenv,
  moonbit-bin,
}:
stdenv.mkDerivation {
  pname = "random-cron";
  version = "0.1.0";

  src = ./.;

  nativeBuildInputs = [
    moonbit-bin.moonbit.latest
  ];

  # `moon` keeps its caches under $HOME, which the sandbox leaves pointing at an
  # unwritable path. The export outlives this phase, so the check phase inherits
  # it too.
  preBuild = ''
    export HOME="$NIX_BUILD_TOP/moon-home"
    mkdir -p "$HOME"
  '';

  buildPhase = ''
    runHook preBuild
    moon build --release
    runHook postBuild
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    moon test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 _build/native/release/build/cmd/main/main.exe $out/bin/random-cron
    runHook postInstall
  '';

  meta = {
    description = "Generate a random cron expression for a schedule";
    license = lib.licenses.asl20;
    mainProgram = "random-cron";
    platforms = [
      # keep-sorted start
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
      # keep-sorted end
    ];
  };
}

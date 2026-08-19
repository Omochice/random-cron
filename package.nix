{
  lib,
  stdenv,
  moonbit,
}:
stdenv.mkDerivation {
  pname = "random-cron";
  # The release manifest is the only place the number is edited, and
  # release-please writes every other copy of it.
  version = lib.pipe ./.github/release-please-manifest.json [
    builtins.readFile
    builtins.fromJSON
    (lib.getAttr ".")
  ];

  src = ./.;

  nativeBuildInputs = [
    moonbit
  ];

  # Not left to the sandbox default: `moon` keeps caches under $HOME, which
  # points at an unwritable path there. The export outlives this phase, so the
  # check phase inherits it.
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
      "x86_64-linux"
      # keep-sorted end
    ];
  };
}

# KeyHint.app: the shortcut cheat sheet and the system-changes panel; its source is ./keyhint.
{
  lib,
  stdenv,
  swift,
  apple-sdk_26,
}:
stdenv.mkDerivation {
  pname = "keyhint";
  version = "0.1.0";
  src = ./keyhint;

  nativeBuildInputs = [swift];
  buildInputs = [apple-sdk_26];

  buildPhase = ''
    runHook preBuild
    # The wrapped swiftc targets the SDK's own macOS version unless told otherwise;
    # the app needs macOS 14 (SwiftUI FocusState) and nothing newer.
    swiftc -O -swift-version 5 -parse-as-library \
      -target ${stdenv.hostPlatform.darwinArch}-apple-macos14.0 \
      *.swift -o KeyHint
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    app=$out/Applications/KeyHint.app/Contents
    install -Dm755 KeyHint $app/MacOS/KeyHint
    install -Dm644 Info.plist $app/Info.plist
    mkdir -p $out/bin
    ln -s $app/MacOS/KeyHint $out/bin/keyhint
    runHook postInstall
  '';

  meta = {
    description = "Cheat sheet of the shortcuts for the frontmost app";
    platforms = lib.platforms.darwin;
    mainProgram = "keyhint";
  };
}

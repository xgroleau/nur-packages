{ lib, stdenv, writeText, fetchurl, autoPatchelfHook, fontconfig, freetype
, libICE, libSM, libX11, libXcursor, libXext, libXfixes, libXrandr, libXrender
, udev }:

stdenv.mkDerivation rec {
  pname = "j-link";
  version = "7.66c";

  urlOS = {
    aarch64-linux = "Linux";
    x86_64-linux = "Linux";
  }.${stdenv.hostPlatform.system} or (throw
    "Unsupported system: ${stdenv.hostPlatform.system}");

  urlPlatform = {
    aarch64-linux = "arm64";
    x86_64-linux = "x86_64";
  }.${stdenv.hostPlatform.system} or (throw
    "Unsupported system: ${stdenv.hostPlatform.system}");

  src = fetchurl {
    url = "https://www.segger.com/downloads/jlink/JLink_${urlOS}_V${
        (lib.replaceChars [ "." ] [ "" ] version)
      }_${urlPlatform}.tgz";

    sha256 = {
      aarch64-linux = "0fr8pki2g4bfk1rk90dzwql37d0b71ngzs9zyx0g2jainan3sqgv";
      x86_64-linux = "q2yw/QuNUB8lWpd5dDx4J0fT5O+J6HZkoA0meT4/mQ8=";
    }.${stdenv.hostPlatform.system} or (throw
      "Unsupported system: ${stdenv.hostPlatform.system}");
    curlOpts = "-d @${
        writeText "curldata.txt"
        "accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software"
      }";
  };

  nativeBuildInputs = [
    autoPatchelfHook

  ];

  buildInputs = [
    fontconfig
    freetype
    libICE
    libSM
    libX11
    libXcursor
    libXext
    libXfixes
    libXrandr
    libXrender
    stdenv.cc.cc.lib
    udev
  ];

  # Exe
  installPhase = ''
    mkdir -p $out/bin
    mv * $out
    ln -s $out/JFlash* $out/bin/
    ln -s $out/JLink* $out/bin/
    ln -s $out/JMem* $out/bin/
    ln -s $out/JRun* $out/bin/
    ln -s $out/JTAGLoad* $out/bin/

  '';

  # Udev rules
  postInstall = ''
    mkdir -p $out/udev
    rules="$out/99-jlink.rules"
    if [ ! -f "$rules" ]; then
        echo "$rules is missing, must update the Nix file."
        exit 1
    fi
    ln -s "$rules" "$out/etc/udev/rules.d/"
  '';

  meta = with lib; {
    description = "J-Link Debugger and Performance Analyzer";
    homepage = "https://www.segger.com/products/debug-probes/j-link/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

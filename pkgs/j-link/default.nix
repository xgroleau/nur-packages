{ lib, stdenv, writeText, fetchurl, autoPatchelfHook, fontconfig, freetype
, libICE, libSM, libX11, libXcursor, libXext, libXfixes, libXrandr, libXrender
, makeWrapper, systemd }:

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
      aarch64-linux = "FJ2Hk9G55RUWeQHQE1Gc3eManjtLhRVyLcLLLM4icmU=";
      x86_64-linux = "q2yw/QuNUB8lWpd5dDx4J0fT5O+J6HZkoA0meT4/mQ8=";
    }.${stdenv.hostPlatform.system} or (throw
      "Unsupported system: ${stdenv.hostPlatform.system}");
    curlOpts = "-d @${
        writeText "curldata.txt"
        "accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software"
      }";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    # Dependencies
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

    # Used to wrap with systemd
    makeWrapper
  ];

  # libudev.so library is contained with systemd and is required for USB communications during runtime
  runtimeLibs = lib.makeLibraryPath [ systemd ];

  # Copy all everything from the tarball and set executable permissions. Then
  # wrap all the executables with the correct path to find libudev (required for USB)
  installPhase = ''
    source $stdenv/setup
    export -f wrapProgram
    mkdir -p $out/bin
    cp -r . $out/bin
    chmod +x $out/bin
    for i in `find $out/bin -type f \( ! -name "*.so*" \) -perm /u=x,g=x,o=x`
    do
      wrapProgram $i --prefix LD_LIBRARY_PATH ":" ${runtimeLibs}
    done

    mkdir -p $out/lib/udev/rules.d
    ln -s 99-jlink.rules $out/lib/udev/rules.d
  '';

  meta = with lib; {
    description = "J-Link Debugger and Performance Analyzer";
    homepage = "https://www.segger.com/products/debug-probes/j-link/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" "aarch64-linux" ];
  };
}

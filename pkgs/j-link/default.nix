{ lib, stdenv, writeText, fetchurl, udev }:

stdenv.mkDerivation rec {
  pname = "j-link";
  version = "7.66c";

  src = fetchurl {
    url = "https://www.segger.com/downloads/jlink/JLink_Linux_${
        (lib.replaceChars [ "." ] [ "" ] version)
      }_x86_64.tgz";
    sha256 = "y1IvmSWLARP91r3g1lp6YM/HuBDs3k6e4eTAsb1BNSg=";
    curlOpts = [
      "-d"
      "@${
        writeText "cdata.txt"
        "accept_license_agreement=accepted&non_emb_ctr=confirmed&submit=Download+software"
      }"
    ];
  };

  rpath = lib.makeLibraryPath [ udev ] + ":${stdenv.cc.cc.lib}/lib64";

  installPhase = ''
    mkdir -p $out/bin
    mv Lib lib
    mv * $out
    ln -s $out/JLink $out/bin
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$out/JLink" \
      --set-rpath ${rpath}:$out/lib "$out/JLink"
    for file in $(find $out/lib -maxdepth 1 -type f -and -name \*.so\*); do
      patchelf --set-rpath ${rpath}:$out/lib $file
    done
  '';

  meta = with lib; {
    description = "J-Link Debugger and Performance Analyzer";
    longDescription = ''
      JLink is a cross-platform debugger and performance analyzer for J-Link
      and J-Trace.
        - Stand-alone graphical debugger
        - Debug output of any tool chain and IDE 1
        - C/C++ source level debugging and assembly instruction debugging
        - Debug information windows for any purpose: disassembly, memory,
          globals and locals, (live) watches, CPU and peripheral registers
        - Source editor to fix bugs immediately
        - High-speed programming of the application into the target
        - Direct use of J-Link built-in features (Unlimited Flash
          Breakpoints, Flash Download, Real Time Terminal, Instruction Trace)
        - Scriptable project files to set up everything automatically
          - New project wizard to ease the basic configuration of new projects
      1 JLink has been tested with the output of the following compilers:
      GCC, Clang, ARM, IAR. Output of other compilers may be supported but is
      not guaranteed to be.
    '';
    homepage = "https://www.segger.com/products/debug-probes/j-link/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}

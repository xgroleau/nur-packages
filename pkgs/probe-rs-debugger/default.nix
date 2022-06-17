{ lib, stdenv, rustPlatform, fetchFromGitHub, openssl, pkg-config, libusb1 }:

let
  fenix = import (fetchTarball {
    url =
      "https://github.com/nix-community/fenix/archive/720b54260dee864d2a21745bd2bb55223f58e297.tar.gz";
    sha256 = "1mmhavhaacfcfy475j9zl831ds72q8jqavavk3z85af0pm80dj1i";
  }) { system = "x86_64-linux"; };
in rustPlatform.buildRustPackage rec {
  pname = "probe-rs-debugger";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "probe-rs";
    repo = "probe-rs";
    rev = "2fa97dc5554cf14f306109a74dc11ceaccd4daf8";
    sha256 = "sha256-OE+x8xRnEEtDCo7xmGNB7Llx2pHeRJd87v5LclOvjW8=";
  };

  cargoBuildFlags = [ "--package" "probe-rs-debugger" ];
  cargoTestFlags = cargoBuildFlags;

  cargoLock = { lockFile = ./Cargo.lock; };
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ pkg-config fenix.minimal.toolchain ];
  buildInputs = [ libusb1 openssl.dev ];

  meta = with lib; {
    description =
      "Debugger that uses probe-rs library to provide interactive debugging experience";
    homepage = "https://probe.rs/";
    changelog =
      "https://github.com/probe-rs/probe-rs/blob/v${version}/CHANGELOG.md";
    license = with licenses; [
      asl20 # or
      mit
    ];
    maintainers = with maintainers; [ xgroleau ];
  };
}

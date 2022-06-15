{ lib, stdenv, rustPlatform, fetchFromGitHub, openssl, pkg-config, libusb1 }:

with import <nixpkgs> {
  overlays = [
    (import (fetchTarball
      "https://github.com/oxalica/rust-overlay/archive/master.tar.gz"))
  ];
};

rustPlatform.buildRustPackage rec {
  pname = "probe-rs-debugger";
  version = "nightly";

  src = fetchFromGitHub {
    owner = "probe-rs";
    repo = "probe-rs";
    rev = "master";
    sha256 = "sha256-OE+x8xRnEEtDCo7xmGNB7Llx2pHeRJd87v5LclOvjW8=";
  };

  cargoLock = { lockFile = ./Cargo.lock; };
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  cargoSha256 = lib.fakeSha256;
  doCheck = false;

  nativeBuildInputs = [ pkg-config rust-bin.stable."1.60.0".minimal ];
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

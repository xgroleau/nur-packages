{ lib, stdenv, rustPlatform, fetchFromGitHub, openssl, pkg-config, libusb1 }:

rustPlatform.buildRustPackage rec {
  pname = "probe-rs-debugger";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "probe-rs";
    repo = "probe-rs";
    rev = "01f9a2175f3757eedf4b05a116ff21d38ca9c612";
    sha256 = "Gx1znhXGkZHjycDphak82ip+kTi6e2U8dc6IUaNHh2Q=";
  };

  cargoBuildFlags = [ "--package" "probe-rs-debugger" ];
  cargoTestFlags = cargoBuildFlags;

  cargoLock = { lockFile = ./Cargo.lock; };
  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [ pkg-config ];
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
  };
}

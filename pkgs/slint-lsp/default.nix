{ lib, stdenv, rustPlatform, fetchCrate, pkg-config, cmake, fontconfig, libGL
, libxcb, libX11, libXcursor, libXi, libXrandr }:

let rpathLibs = [ fontconfig libGL libxcb libX11 libXcursor libXrandr libXi ];
in rustPlatform.buildRustPackage rec {
  pname = "slint-lsp";
  version = "0.3.0";

  src = fetchCrate {
    inherit pname version;
    sha256 = "sha256-dZYkiYrotW8td5dxnPSvDzkWf+xV4ceISVLRZx2goXo=";
  };

  cargoSha256 = "sha256-9zbA9JXfLdosCU6gVsrsAyiyX8Qh6x5wMw1W4QKqbp4=";

  nativeBuildInputs = [ cmake pkg-config ];
  buildInputs = rpathLibs ++ [ libxcb.dev fontconfig ];

  postInstall = ''
    patchelf --set-rpath ${lib.makeLibraryPath rpathLibs} $out/bin/${pname}
  '';

  dontPatchELF = true;

  meta = with lib; {
    description = "";
    homepage = "https://slint-ui.com/";
    changelog =
      "https://github.com/slint-ui/slint/blob/v${version}/CHANGELOG.md";
    # license = with licenses; [ gpl ];
    #maintainers = with maintainers; [ xgroleau ];
  };
}

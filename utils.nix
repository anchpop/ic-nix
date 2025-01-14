{ pkgs, sources }:
with pkgs;
let
  stdenv = llvmPackages_11.libcxxStdenv;
  linker = callPackage ./nix/static-linker.nix { inherit stdenv; };
  buildInputs = [ ] ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ DiskArbitration Foundation ]);
  mkDrv = name: cargoSha256:
    rustPlatform.buildRustPackage {
      inherit name cargoSha256;
      src = sources."${name}";
      buildInputs = [ openssl-static ] ++ lib.optionals stdenv.isDarwin
        (with darwin.apple_sdk.frameworks; [ Security ]);
      nativeBuildInputs = [ pkg-config ];
      RUSTFLAGS = lib.optionals stdenv.isDarwin [
        "-Clinker=${linker}"
        "-Lnative=${libcxxabi}/lib"
      ];
    };
in rec {
  icx-proxy =
    mkDrv "icx-proxy" "sha256-vprJ3E8vv+AWrEiajMQLVB2wTlckFYQeDQnDDoft2EI="; # cargoSha256
  vessel =
    mkDrv "vessel" "sha256-YKLDYEdIkMFtM5ZTOzRJxXi3YAmGtzH+2kPyLSHV1Ok="; # cargoSha256
  ic-repl =
    mkDrv "ic-repl" "sha256-r1E7nWTgPOXO/XQFzWPg1aiPMOKqupIS0//0cY/TyHE="; # cargoSha256
  candid =
    mkDrv "candid" "sha256-KejEkKUUPyZvgGp/KHcVxCpzy17cAfABUw4FLIu9N8c="; # cargoSha256

  shell = icx-proxy;
}

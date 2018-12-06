with import <nixpkgs> {};

with pkgs;
with lib;
with builtins;
let

  deploy-branches = [
                  "master"
                  "dev"
  ];

  test-step = writeShellScriptBin "test-step" ''
    echo "Running tests now"
    false
  '';

  on-deploy-branch = writeShellScriptBin "on-deploy-branch" ''
    if [ -z "$BRANCH_NAME" ]; then
      exit 1
    fi
    echo "$BRANCH_NAME" | \
      grep -E '${concatMapStringsSep "|" (s: "^${s}$") deploy-branches}' >/dev/null
  '';

  deploy-step = writeShellScriptBin "deploy-step" ''
    echo "Running deploy now"
  '';

in
  stdenv.mkDerivation {
   name = "pipeline";
   buildInputs = [ stdenv ps curl coreutils bashInteractive
                   test-step deploy-step on-deploy-branch
                 ];
  }
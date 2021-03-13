{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;

  elixir = beam.packages.erlangR22.elixir_1_10;
  nodejs = nodejs-13_x;
  postgresql = postgresql_12;

  # This line imports the necessary Chrome dependancy, which can then be included in your build input
  chrome_headless = (import ./default.nix {})."chrome-headless-render-pdf-1.8.4";
in

mkShell {
  buildInputs = [ elixir nodejs yarn git postgresql cmake chrome_headless ]
    ++ optional stdenv.isLinux inotify-tools # For file_system on Linux.
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      # For file_system on macOS.
      CoreFoundation
      CoreServices
    ]);
}

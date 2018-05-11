# This file was generated by https://github.com/kamilchm/go2nix v1.2.1
{ stdenv, buildGoPackage, fetchgit, fetchhg, fetchbzr, fetchsvn }:

buildGoPackage rec {
  name = "tendermint-unstable-${version}";
  version = "2018-05-10";
  rev = "21724243a6ae55a6e842308748c92ab1cb6384d1";

  goPackagePath = "github.com/tendermint/tendermint";

  src = fetchgit {
    inherit rev;
    url = "https://github.com/tendermint/tendermint.git";
    sha256 = "1m00fji1bdiph25xqr8myra3488703wlzfdcvg279pcg1xj3v7k8";
  };

  goDeps = ./deps.nix;

  # TODO: add metadata https://nixos.org/nixpkgs/manual/#sec-standard-meta-attributes
  meta = {
  };
}
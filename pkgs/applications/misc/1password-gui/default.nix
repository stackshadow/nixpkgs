{ stdenv
, callPackage
, channel ? "stable"
, fetchurl
, lib
# This is only relevant for Linux, so we need to pass it through
, polkitPolicyOwners ? [ ] }:

let

  pname = "1password";
  version = if channel == "stable" then "8.10.7" else "8.10.7-11.BETA";

  sources = {
    stable = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/x86_64/1password-${version}.x64.tar.gz";
        sha256 = "sha256-5KMAzstoPmNgFejp21R8PcdrmUtkX3qxHYX3rV5JqyE=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/stable/aarch64/1password-${version}.arm64.tar.gz";
        sha256 = "sha256-Tmof+ma1SJMQRSV1T5flLeXfe6W1a2U2mYzi+MrxvJM=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        sha256 = "sha256-jtqgJJy1ZhyaEUEafT1ywD529aKGDqc0J3mgYSGVTWU=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        sha256 = "sha256-qLqK6CZcqDfIGX0FzEnAZP3Rkxw8CNtT6sFy8u0IqwM=";
      };
    };
    beta = {
      x86_64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/x86_64/1password-${version}.x64.tar.gz";
        sha256 = "sha256-O7dzNRukIk654FoS1HxqHYcB8mLNORvz59p3skRXuYM=";
      };
      aarch64-linux = {
        url = "https://downloads.1password.com/linux/tar/beta/aarch64/1password-${version}.arm64.tar.gz";
        sha256 = "sha256-npEVlGwMmYXH4wW6VvAhPzWNFOZl1LvuCnOgvm94rds=";
      };
      x86_64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-x86_64.zip";
        sha256 = "sha256-Z0IZNEU8ggSF20SZziT5UTEMiWPNdVWY82nhuGyeFVU=";
      };
      aarch64-darwin = {
        url = "https://downloads.1password.com/mac/1Password-${version}-aarch64.zip";
        sha256 = "sha256-qy1Vr6nDJo44Qd7mKZYR65+tIaSq0YOjjw84/mg1RgE=";
      };
    };
  };

  src = fetchurl {
    inherit (sources.${channel}.${stdenv.system}) url sha256;
  };

  meta = with lib; {
    description = "Multi-platform password manager";
    homepage = "https://1password.com/";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ timstott savannidgerinel maxeaubrey sebtm ];
    platforms = builtins.attrNames sources.${channel};
  };

in if stdenv.isDarwin
then callPackage ./darwin.nix { inherit pname version src meta; }
else callPackage ./linux.nix { inherit pname version src meta polkitPolicyOwners; }

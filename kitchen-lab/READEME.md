# Kiosk Flake Configuration from Sub-folder

This configuration uses a flake stored in the `kitchen-lab` sub-folder of the `nix-flakes` repository to configure a simple kiosk setup that launches Firefox in kiosk mode.

## Steps to Integrate


```
# configuration.nix

{ config, pkgs, ... }:

let
  remoteFlake = builtins.getFlake "github:KiwiKid/nix-flake";
in
{
  imports = [
    remoteFlake.nixosConfigurations.kiosk
  ];

  networking.hostName = "kitchen-lab";
  time.timeZone = "Auckland/Pacific";
}

```
{
  description = "A (wip) simple NixOS flake to launch Firefox in kiosk mode";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.kiosk = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          services.xserver.enable = true;
          services.xserver.displayManager.auto.startx.enable = true;
          services.xserver.windowManager.default = "none";

          # Enable Firefox and configure it to start in kiosk mode
          programs.firefox.enable = true;
          services.xserver.displayManager.sessionCommands = ''
            ${inputs.nixpkgs}/bin/firefox --kiosk www.google.com &
          '';
        }
      ];
    };
  };
}
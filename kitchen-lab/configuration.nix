{ config, pkgs, ... }:

{
  networking.hostName = "kitchen-lab";

  # Configure the user
  users.users.kitchen = {
    isNormalUser = true;
    home = "/home/kitchen";
    shell = pkgs.bash;
    extraGroups = [ "lp" ];
  };

  # Configure the second admin user for VSCode
  users.users.admin = {
    isNormalUser = true;
    home = "/home/admin";
    shell = pkgs.bash;
    extraGroups = [ "wheel" "lp" ];  # Add to the 'wheel' group for admin access
  };


  # Enable printing
  services.printing.enable = true;

  # Firefox in kiosk mode to show the kitchen dashboard
  systemd.user.services.firefox-kiosk = {
    wantedBy = [ "default.target" ];
    script = "${pkgs.firefox}/bin/firefox --kiosk http://192.168.1.5:8123/kitchen-display";
  };

  # Define a service for pulling the latest configuration from GitHub and copying kitchen-lab subfolder
  systemd.services.update-nixos-config = {
    description = "Update NixOS Configuration from GitHub (kitchen-lab folder)";
    serviceConfig = {
      ExecStart = "${pkgs.bash}/bin/bash -c ''"
        + ''
          repo_dir="/etc/nixos/repo"
          target_dir="/etc/nixos"

          # Clone the repo if it doesn't exist
          if [ ! -d "$repo_dir/.git" ]; then
            mkdir -p "$repo_dir"
            git clone https://github.com/KiwiKid/nix-flakes.git "$repo_dir"
          fi

          # Pull the latest changes
          cd "$repo_dir"
          git pull origin main

          # Copy the kitchen-lab folder to /etc/nixos if there are changes
          rsync -a --delete "$repo_dir/kitchen-lab/" "$target_dir/"
          
          # Rebuild NixOS
          nixos-rebuild switch
        '';
    };
  };

  # Set up a timer to run the update service daily
  systemd.timers.update-nixos-config = {
    description = "Run update-nixos-config daily";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "daily";
    timerConfig.Persistent = true;
  };
}

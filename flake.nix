{
  description = "ASUS ROG / Sway workstation - declarative Home Manager setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # The native RuneScape 3 client still links OpenSSL 1.1, which was removed
    # from nixpkgs as end-of-life. Pin an older nixpkgs just to source it.
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      # Build a Home Manager configuration for a given user/host.
      #
      # To reproduce this setup on another machine, either edit the defaults
      # below or add another entry to `homeConfigurations`.
      mkHome =
        {
          username ? "okra",
          homeDirectory ? "/home/${username}",
          hostname ? "nixos",
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config = {
              allowUnfree = true;
              # bolt-launcher marks itself broken with enableRS3 because RS3
              # needs OpenSSL 1.1; we supply it ourselves, so ignore the warning.
              problems.handlers.bolt-launcher.broken = "ignore";
            };
          };

          extraSpecialArgs = {
            inherit
              inputs
              username
              homeDirectory
              hostname
              ;
          };

          modules = [ ./home ];
        };
    in
    {
      homeConfigurations = {
        # The current laptop (ASUS ROG, hostname nixos)
        "okra" = mkHome { };

        # Example second machine - uncomment and adjust:
        # "workstation" = mkHome {
        #   username = "alice";
        #   homeDirectory = "/home/alice";
        #   hostname = "desk";
        # };
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;
    };
}

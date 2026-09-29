{
  description = "Framework 16 / i3 workstation - declarative Home Manager setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          username ? "labanos",
          homeDirectory ? "/home/${username}",
          hostname ? "framework16",
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
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
        # The current laptop (~/projects/nix-station)
        "labanos" = mkHome { };

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

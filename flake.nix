{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, zmk-nix }: let
    forAllSystems = nixpkgs.lib.genAttrs (nixpkgs.lib.attrNames zmk-nix.packages);
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      buildKeyboard = zmk-nix.legacyPackages.${system}.buildKeyboard;
      
      # We extract the zephyrDepsHash so we can easily update it
      # When you update west.yml, you will need to change this hash.
      # You can leave it empty to let the build fail and tell you the correct hash.
      zephyrDepsHash = "sha256-k4TeWuSyRS9idSvf4xO1zZB/r09iqDtrLMBFTc+EfsA=";
      
      src = nixpkgs.lib.sourceFilesBySuffices self [ ".board" ".cmake" ".conf" ".defconfig" ".dts" ".dtsi" ".json" ".keymap" ".overlay" ".shield" ".yml" "_defconfig" ];
      
      meta = {
        description = "ZMK firmware for eyelash_sofle";
        license = nixpkgs.lib.licenses.mit;
        platforms = nixpkgs.lib.platforms.all;
      };
    in rec {
      default = pkgs.linkFarm "sofle-firmware" [
        { name = "left.uf2"; path = "${left}/zmk.uf2"; }
        { name = "right.uf2"; path = "${right}/zmk.uf2"; }
        { name = "studio.uf2"; path = "${studio}/zmk.uf2"; }
        { name = "settings_reset.uf2"; path = "${settings_reset}/zmk.uf2"; }
      ];

      left = buildKeyboard {
        name = "eyelash_sofle_left";
        inherit src zephyrDepsHash meta;
        board = "eyelash_sofle_left";
        shield = "nice_view";
      };

      right = buildKeyboard {
        name = "eyelash_sofle_right";
        inherit src zephyrDepsHash meta;
        board = "eyelash_sofle_right";
        shield = "nice_view_custom";
      };

      studio = buildKeyboard {
        name = "eyelash_sofle_studio_left";
        inherit src zephyrDepsHash meta;
        board = "eyelash_sofle_left";
        shield = "nice_view";
        extraCMakeFlags = [
          "-DCONFIG_ZMK_STUDIO=y"
          "-DCONFIG_ZMK_STUDIO_LOCKING=n"
          "-DSNIPPET=studio-rpc-usb-uart"
        ];
      };

      settings_reset = buildKeyboard {
        name = "settings_reset";
        inherit src zephyrDepsHash meta;
        board = "eyelash_sofle_left";
        shield = "settings_reset";
      };

      update = zmk-nix.packages.${system}.update;
    });

    devShells = forAllSystems (system: {
      default = zmk-nix.devShells.${system}.default;
    });
  };
}

# justfile for ZMK firmware compilation

# List available commands
default:
    @just --list

# Build all firmware targets
build-all:
    nix build .#default

# Build left firmware
build-left:
    nix build .#left

# Build right firmware
build-right:
    nix build .#right

# Build left firmware with ZMK Studio support
build-studio:
    nix build .#studio

# Build settings reset firmware
build-settings-reset:
    nix build .#settings_reset

# Update west dependencies
update:
    nix run .#update

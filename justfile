flake := justfile_directory()
rebuild := if os() == "macos" { "sudo darwin-rebuild" } else { "sudo nixos-rebuild" }

[private]
default:
    @just --list --unsorted


[group('rebuild')]
[private]
builder goal *args:
    {{ rebuild }} {{ goal }} \
    --flake {{ flake }} \
    {{ args }} \
    
[group('rebuild')]
switch *args: (builder "switch" args)


[group('dev')]
update *input:
    nix flake update {{ input }} \
    --refresh \
    --commit-lock-file \
    --commit-lockfile-summary \
    "chore(flake): updated {{ if input == "" { "all inputs" } else { input } }}"


[group('utils')]
verify *args:
    nix-store --verify {{ args }}

[group('utils')]
repair: (verify "--check-contents --repair")

[group('utils')]
check *args:
    nix flake check --option allow-import-from-derivation false {{ args }}

[group('utils')]
clean:
    nix-collect-garbage --delete-older-than 3d
    nix store optimise
       

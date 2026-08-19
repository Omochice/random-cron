{
  description = "Generate a random cron expression for a schedule";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur-packages = {
      url = "github:Omochice/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    moonbit-overlay = {
      url = "github:moonbit-community/moonbit-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      flake-utils,
      nur-packages,
      git-hooks,
      moonbit-overlay,
    }:
    let
      # moonbit overlays supports only below:
      moonbitSystems = [
        # keep-sorted start
        "aarch64-darwin"
        "x86_64-linux"
        # keep-sorted end
      ];
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            moonbit-overlay.overlays.default
            nur-packages.overlays.default
          ];
        };
        supportsMoonbit = builtins.elem system moonbitSystems;
        moonbit = pkgs.moonbit-bin.moonbit.latest;
        random-cron = pkgs.callPackage ./package.nix { inherit moonbit; };
        treefmt = treefmt-nix.lib.evalModule pkgs (
          { ... }:
          {
            settings.global.excludes = [ ];
            settings.formatter = {
              tombi = {
                command = pkgs.lib.getExe pkgs.tombi;
                # Not left online: the formatting check runs in a sandbox with
                # no network, where fetching the schema catalog fails the run.
                options = [
                  "format"
                  "--offline"
                ];
                includes = [
                  "*.toml"
                  "moon.mod"
                ];
              };
            }
            // pkgs.lib.optionalAttrs supportsMoonbit {
              moonfmt = {
                command = "${pkgs.lib.getExe' moonbit "moon"}";
                options = [ "fmt" ];
                includes = [ "*.mbt" ];
              };
            };
            programs = {
              # keep-sorted start block=yes
              keep-sorted.enable = true;
              nixfmt.enable = true;
              rumdl-format.enable = true;
              yamlfmt = {
                enable = true;
                settings = {
                  formatter = {
                    type = "basic";
                    retain_line_breaks_single = true;
                  };
                };
              };
              # keep-sorted end
            };
          }
        );
        pre-commit-check = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            # Claude Code sets CLAUDECODE; humans are covered by the pre-push hook
            gitleaks-commit = {
              enable = true;
              name = "gitleaks (claude commit)";
              entry = pkgs.lib.getExe (
                pkgs.writeShellApplication {
                  name = "gitleaks-when-claude";
                  runtimeInputs = [ pkgs.gitleaks ];
                  text = ''
                    if [ -z "''${CLAUDECODE:-}" ]; then
                      exit 0
                    fi
                    gitleaks git --pre-commit --staged --no-banner --redact
                  '';
                }
              );
              pass_filenames = false;
              stages = [ "pre-commit" ];
            };
            gitleaks-push = {
              enable = true;
              name = "gitleaks";
              entry = "${pkgs.lib.getExe pkgs.gitleaks} git --no-banner --redact";
              pass_filenames = false;
              stages = [ "pre-push" ];
            };
            treefmt = {
              enable = true;
              packageOverrides.treefmt = treefmt.config.build.wrapper;
              stages = [ "pre-push" ];
            };
          }
          // pkgs.lib.optionalAttrs supportsMoonbit {
            moon-check = {
              enable = true;
              name = "moon check";
              entry = "${pkgs.lib.getExe' moonbit "moon"} check";
              pass_filenames = false;
              stages = [ "pre-push" ];
            };
          };
        };
        devPackages = rec {
          # keep-sorted start block=yes
          actions = with pkgs; [
            actionlint
            ghalint
            zizmor
          ];
          toolchain = nixpkgs.lib.optionals supportsMoonbit [ moonbit ];
          # keep-sorted end
          default = [
            treefmt.config.build.wrapper
          ]
          ++ actions
          ++ toolchain;
        };
        checkPackages = {
          # keep-sorted start
          actions =
            pkgs.runCommand "check-actions"
              {
                buildInputs = with pkgs; [
                  actionlint
                  ghalint
                  zizmor
                ];
                src = self;
              }
              ''
                cd $src
                actionlint .github/**/*.{yaml,yml}
                ghalint run
                zizmor .github/
                touch $out
              '';
          formatting = treefmt.config.build.check self;
          pre-commit = pre-commit-check;
          renovate =
            pkgs.runCommand "validate-renovate-config"
              {
                buildInputs = with pkgs; [
                  renovate
                ];
                src = self;
              }
              ''
                cd $src
                renovate-config-validator --strict renovate.json5
                touch $out
              '';
          # keep-sorted end
        }
        // pkgs.lib.optionalAttrs supportsMoonbit {
          # Not a check of its own: `nix flake check` builds `checks` but only
          # evaluates `packages`, and the package already runs `moon test`.
          build = random-cron;
        };
      in
      {
        # keep-sorted start block=yes
        checks = checkPackages;
        devShells = pkgs.lib.pipe devPackages [
          (pkgs.lib.attrsets.mapAttrs (
            name: buildInputs:
            pkgs.mkShell {
              buildInputs = buildInputs ++ pre-commit-check.enabledPackages;
              inherit (pre-commit-check) shellHook;
            }
          ))
        ];
        formatter = treefmt.config.build.wrapper;
        # keep-sorted end
      }
      // nixpkgs.lib.optionalAttrs supportsMoonbit {
        packages = {
          default = random-cron;
          inherit random-cron;
        };
      }
    );
}

let
  pkgs = import <nixpkgs> { };

  version = "3.0.4";
  src = pkgs.fetchFromGitHub {
    owner = "inbucket";
    repo = "inbucket";
    rev = "v${version}";
    hash = "sha256-hbNP2ajkaxl3FlGhPEtHnNj0VpbGe4JiqsnbAu1vm5U=";
  };

  frontend = pkgs.mkYarnPackage ({
    inherit version;
    src = "${src}/ui";
    pname = "inbucket-ui";

    offlineCache = pkgs.fetchYarnDeps {
      sha256 = "sha256-JiCW35udb3wjpPGY1W1cmQwD/rX/Q++iHGaYBK5hrs0=";
    };

    configurePhase = ''
      runHook preConfigure
      ln -s $node_modules node_modules
      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export HOME=$(mktemp -d)
      yarn --offline run build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/dist
      cp -r dist/** $out/dist

      runHook postInstall
    '';

    doDist = false;
  }
  );

  backend = pkgs.buildGoModule
    {
      inherit version src;
      pname = "inbucket";
      vendorHash = "sha256-+jf3opIZ1K5LojCx0qpX6TK/bKXp4U6RC8NzAlJcmi4=";

      ldflags = [
        "-s"
        "-w"
        "-X main.Version=${version}"
      ];
    };
in
frontend

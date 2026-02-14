{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sidecar";
  version = "0-unstable-2025-02-12";

  src = fetchFromGitHub {
    owner = "boozedog";
    repo = "sidecar";
    rev = "ba7af53a1fca3b3dc298b58e757c3d27e2961ddc"; # develop branch
    hash = "sha256-u0TaoNjCMJnehYpNnT/EWMZY7A0q49wqQalDhrJLGuM=";
  };

  vendorHash = "sha256-R/AjNJ4x4t1zXXzT+21cjY+9pxs4DVXU4xs88BQvHx4=";

  subPackages = [ "cmd/sidecar" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "Sidecar for CLI agents - diffs, file trees, conversation history, and task management";
    homepage = "https://github.com/boozedog/sidecar";
    mainProgram = "sidecar";
  };
}

{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sidecar";
  version = "0.71.1-23-g998cbea"; # git describe --tags --always 998cbea

  src = fetchFromGitHub {
    owner = "boozedog";
    repo = "sidecar";
    rev = "998cbea0f7acbcbc73438bb2582821e0d48a9786"; # develop branch
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

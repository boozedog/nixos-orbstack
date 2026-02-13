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
    rev = "d276109a5b74aafe46ce1e74c4e4880d9b07a8aa";
    hash = "sha256-x37sZdz0Vuhm9nN68xg61ahYY4WTAH18tKomQC7cYyE=";
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

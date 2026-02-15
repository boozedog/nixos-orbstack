{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "sidecar";
  version = "0.72.0-14-g490acf5"; # git describe --tags --always 490acf5

  src = fetchFromGitHub {
    owner = "boozedog";
    repo = "sidecar";
    rev = "490acf5356eb3ac786f359148d4583ac9e6f73a0"; # develop branch
    hash = "sha256-9Q7KySa9rux6zykymd5yDhZk6hpvax6vMLZ771QOY70=";
  };

  vendorHash = "sha256-E9SFghqsVxJO+fVoGWk36Qq+J64GVqUeAo66yPT1E/E=";

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

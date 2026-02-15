{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "td";
  version = "0.36.0";

  src = fetchFromGitHub {
    owner = "marcus";
    repo = "td";
    rev = "2dadd1b2996243c9827786dc6de6aeb36835d9d6";
    hash = "sha256-r8jOoLkQrKvnItmTzKd/zd1xrT+xiSWGkpHUpeX9nyo=";
  };

  vendorHash = "sha256-Rp0lhnBLJx+exX7VLql3RfthTVk3LLftD6n6SsSWzVY=";

  # tests require git and network access
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "A minimalist CLI for tracking tasks across AI coding sessions";
    homepage = "https://github.com/marcus/td";
    mainProgram = "td";
  };
}

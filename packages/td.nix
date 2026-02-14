{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "td";
  version = "0.34.0-4-g1653f43";

  src = fetchFromGitHub {
    owner = "marcus";
    repo = "td";
    rev = "1653f43e2c0a43382b7f1c7c3c4c5f392460c770";
    hash = "sha256-0m7V3fjZ25W4LM1pML37yjaf3C8laW9tQ434sMdP1Kc=";
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

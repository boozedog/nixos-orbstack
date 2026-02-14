{
  lib,
  buildNpmPackage,
  fetchurl,
}:

buildNpmPackage rec {
  pname = "pi-coding-agent";
  version = "0.52.12";

  src = fetchurl {
    url = "https://registry.npmjs.org/@mariozechner/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    sha256 = "0rl67qgbjzvnv0d857ddf7v64vskj465jsdxk091nza9s6xj6an6";
  };

  sourceRoot = "package";

  postPatch = ''
    cp ${./pi-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-su8vkH4Q1IHEqRm5QofeS9A44Sr7rIJHaMLfyasdnfk=";

  # dist/ is pre-built in the npm tarball, no build needed
  dontNpmBuild = true;

  meta = {
    description = "Pi - a minimal, extensible terminal coding agent";
    homepage = "https://pi.dev";
    license = lib.licenses.mit;
    mainProgram = "pi";
  };
}

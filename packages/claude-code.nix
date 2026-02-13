# Claude Code Package
#
# Installs Claude Code with its own Node.js runtime to ensure
# it's available regardless of project-specific Node.js versions.
{
  lib,
  stdenv,
  fetchurl,
  nodejs_24,
  cacert,
  bash,
}:

let
  version = "2.1.41";

  # Pre-fetch the npm package as a Fixed Output Derivation
  # To update: nix-prefetch-url https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-VERSION.tgz
  claudeCodeTarball = fetchurl {
    url = "https://registry.npmjs.org/@anthropic-ai/claude-code/-/claude-code-${version}.tgz";
    sha256 = "sha256-xouJ8RZC8CEYxb6DpMZa9cpTNDo5VHAxPVCDbwGCdpk=";
  };
in
stdenv.mkDerivation {
  pname = "claude-code";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [
    nodejs_24
    cacert
  ];

  buildPhase = ''
    export HOME=$TMPDIR
    mkdir -p $HOME/.npm

    export SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt
    export NODE_EXTRA_CA_CERTS=$SSL_CERT_FILE

    ${nodejs_24}/bin/npm config set cafile $SSL_CERT_FILE
    ${nodejs_24}/bin/npm config set offline true
    ${nodejs_24}/bin/npm install -g --prefix=$out ${claudeCodeTarball}
  '';

  installPhase = ''
        rm -f $out/bin/claude

        mkdir -p $out/bin
        cat > $out/bin/claude << 'EOF'
    #!${bash}/bin/bash
    export NODE_PATH="@out@/lib/node_modules"
    export CLAUDE_EXECUTABLE_PATH="$HOME/.local/bin/claude"
    export DISABLE_AUTOUPDATER=1

    exec ${nodejs_24}/bin/node --no-warnings --enable-source-maps "@out@/lib/node_modules/@anthropic-ai/claude-code/cli.js" "$@"
    EOF
        chmod +x $out/bin/claude

        substituteInPlace $out/bin/claude \
          --replace '@out@' "$out"
  '';

  meta = with lib; {
    description = "Claude Code - AI coding assistant in your terminal";
    homepage = "https://www.anthropic.com/claude-code";
    license = licenses.unfree;
    platforms = platforms.all;
  };
}

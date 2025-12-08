{ pkgs, ... }:
let
  brave-search-mcp = pkgs.callPackage ../packages/brave-search-mcp.nix { };

  # Base MCP config (without secrets that need runtime injection)
  mcpConfig = builtins.toJSON {
    mcpServers = {
      brave-search = {
        type = "stdio";
        command = "${brave-search-mcp}/bin/brave-search-mcp";
        args = [ ];
        env = { };
      };
      context7 = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
        env = { };
      };
      # chrome-devtools = {
      #   type = "stdio";
      #   command = "npx";
      #   args = [ "chrome-devtools-mcp@latest" ];
      #   env = { };
      # };
      # deepwiki = {
      #   serverUrl = "https://mcp.deepwiki.com/sse";
      # };
      # n8n-mcp = {
      #   command = "npx";
      #   args = [ "n8n-mcp" ];
      #   env = {
      #     MCP_MODE = "stdio";
      #     LOG_LEVEL = "error";
      #     DISABLE_CONSOLE_OUTPUT = "true";
      #   };
      # };
      # nixos = {
      #   command = "uvx";
      #   args = [ "mcp-nixos" ];
      # };
      # Ref MCP - API key injected at activation time from agenix secret
      reftools = {
        type = "http";
        url = "https://api.ref.tools/mcp";
        headers = {
          x-ref-api-key = "__REF_API_KEY_PLACEHOLDER__";
        };
      };
      # shadcn = {
      #   command = "npx";
      #   args = [
      #     "shadcn@latest"
      #     "mcp"
      #   ];
      # };
    };
  };
in
{
  # Claude Code installed via nix derivation (packages/claude-code.nix)
  home = {
    # uv provides uvx, needed for mcp-nixos server
    packages = [ pkgs.uv ];

    # Settings go in .claude/settings.json (plugins, preferences)
    file.".claude/settings.json".text = builtins.toJSON {
      enabledPlugins = {
        "frontend-design@claude-code-plugins" = true;
      };
      alwaysThinkingEnabled = true;
    };

    # MCP servers must be configured in ~/.claude.json (not settings.json)
    # This file is also used by Claude for runtime state, so we preserve
    # other keys but completely replace mcpServers with our config.
    # API keys are injected from agenix secrets at activation time.
    activation.claudeMcpServers = ''
      CLAUDE_JSON="$HOME/.claude.json"

      # Read API key from agenix secret
      REF_API_KEY=""
      if [ -f "/run/agenix/ref-api-key" ]; then
        REF_API_KEY=$(cat /run/agenix/ref-api-key)
      fi

      # Prepare config with injected secrets
      MCP_CONFIG='${mcpConfig}'
      if [ -n "$REF_API_KEY" ]; then
        MCP_CONFIG=$(echo "$MCP_CONFIG" | ${pkgs.gnused}/bin/sed "s/__REF_API_KEY_PLACEHOLDER__/$REF_API_KEY/g")
      fi

      if [ -f "$CLAUDE_JSON" ]; then
        # Replace mcpServers entirely while preserving other keys
        ${pkgs.jq}/bin/jq --argjson servers "$MCP_CONFIG" '.mcpServers = $servers.mcpServers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        echo "$MCP_CONFIG" > "$CLAUDE_JSON"
      fi
    '';
  };
}

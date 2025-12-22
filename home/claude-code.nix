{ pkgs, ... }:
let
  mcpConfig = builtins.toJSON {
    mcpServers = {
      context7 = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@upstash/context7-mcp"
        ];
        env = { };
      };
    };
  };
in
{
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

    # MCP servers configured in ~/.claude.json
    activation.claudeMcpServers = ''
      CLAUDE_JSON="$HOME/.claude.json"

      MCP_CONFIG='${mcpConfig}'

      if [ -f "$CLAUDE_JSON" ]; then
        ${pkgs.jq}/bin/jq --argjson servers "$MCP_CONFIG" '.mcpServers = $servers.mcpServers' "$CLAUDE_JSON" > "$CLAUDE_JSON.tmp" && mv "$CLAUDE_JSON.tmp" "$CLAUDE_JSON"
      else
        echo "$MCP_CONFIG" > "$CLAUDE_JSON"
      fi
    '';
  };
}

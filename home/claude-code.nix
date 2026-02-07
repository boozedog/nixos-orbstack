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
      # enabledPlugins = {
      #   "frontend-design@claude-code-plugins" = true;
      # };
      alwaysThinkingEnabled = true;
      statusLine = {
        type = "command";
        command = ''input=$(cat); cwd=$(echo "$input" | jq -r '.workspace.current_dir'); project=$(echo "$input" | jq -r '.workspace.project_dir'); model=$(echo "$input" | jq -r '.model.display_name'); remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // 100'); rel_path=''${cwd#$project}; [ "$rel_path" = "$cwd" ] && display_path=$(basename "$cwd") || display_path="$(basename "$project")$rel_path"; parts=""; if cd "$cwd" 2>/dev/null; then git_branch=$(git -c core.useBuiltinFSMonitor=false branch --show-current 2>/dev/null); if [ -n "$git_branch" ]; then git -c core.useBuiltinFSMonitor=false diff-index --quiet HEAD -- 2>/dev/null || dirty="*"; upstream=$(git -c core.useBuiltinFSMonitor=false rev-parse --abbrev-ref @{upstream} 2>/dev/null); if [ -n "$upstream" ]; then counts=$(git -c core.useBuiltinFSMonitor=false rev-list --left-right --count HEAD...@{upstream} 2>/dev/null); ahead=$(echo "$counts" | cut -f1); behind=$(echo "$counts" | cut -f2); aheadbehind=""; [ "$ahead" -gt 0 ] && aheadbehind="↑$ahead"; [ "$behind" -gt 0 ] && aheadbehind="''${aheadbehind}↓$behind"; [ -n "$aheadbehind" ] && aheadbehind=" $aheadbehind"; fi; parts="$parts $(printf '\033[35m')on $(printf '\033[1;35m')$git_branch$dirty$aheadbehind$(printf '\033[0m')"; fi; fi; [ -n "$model" ] && parts="$parts $(printf '\033[36m')[$model]$(printf '\033[0m')"; if [ "$remaining" -gt 66 ]; then pct_color="32"; elif [ "$remaining" -gt 33 ]; then pct_color="33"; else pct_color="31"; fi; parts="$parts $(printf "\033[''${pct_color}m")''${remaining}%$(printf '\033[0m')"; printf "$(printf '\033[34m')%s$(printf '\033[0m')%s" "$display_path" "$parts"'';
      };
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

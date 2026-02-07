{ pkgs, ... }:
{
  home.stateVersion = "25.05";

  programs = {
    git = {
      enable = true;
      settings = {
        user = {
          name = "boozedog";
          email = "code@booze.dog";
        };
        "credential \"https://gitea.tail9fdd65.ts.net\"" = {
          helper = "!tea login helper get";
        };
      };
    };

    fzf.enable = true;

    zsh = {
      enable = true;
      plugins = [
        {
          name = "forgit";
          src = pkgs.zsh-forgit;
          file = "share/zsh/zsh-forgit/forgit.plugin.zsh";
        }
      ];
    };

    fish = {
      enable = true;
      plugins = [
        {
          name = "forgit";
          inherit (pkgs.fishPlugins.forgit) src;
        }
      ];
    };
  };
}

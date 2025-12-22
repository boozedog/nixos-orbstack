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

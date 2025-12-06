{ config, pkgs, ... }:

{
  home.stateVersion = "25.05";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "boozedog";
        email = "code@booze.dog";
      };
    };
  };
}

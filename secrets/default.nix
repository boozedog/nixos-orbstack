_: {
  age = {
    identityPaths = [ "/home/david/.ssh/id_ed25519_agenix" ];

    secrets = {
      brave-api-key = {
        file = ./brave-api-key.age;
        owner = "david";
        mode = "0400";
      };

      ref-api-key = {
        file = ./ref-api-key.age;
        owner = "david";
        mode = "0400";
      };
    };
  };
}

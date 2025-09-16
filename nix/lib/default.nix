{ inputs, ... }:
{
  mkDarwinUser = user: {
    users.knownUsers = [ user ];

    users.users.${user} = {
      name = user;
      home = "/Users/${user}";
      isHidden = false;
      uid = 501;
    };

    system.primaryUser = user;
  };

  mkNixPackages =
    {
      lib,
      pkgs,
      manifestFile,
      darwinMode ? false,
    }:
    let
      manifest = lib.importTOML manifestFile;
      packages = manifest.install or { };

      systemFilteredPackages = lib.filterAttrs (
        name: attrs:
        if darwinMode then
          attrs ? systems && lib.elem pkgs.system attrs.systems
        else
          !attrs ? systems || lib.elem pkgs.system attrs.systems
      ) packages;

      # Convert dot notation to nested attribute access
      getPackage =
        pkgPath:
        let
          parts = if builtins.isList pkgPath then pkgPath else lib.splitString "." pkgPath;
        in
        lib.attrByPath parts null pkgs;

      # Process regular packages
      regularPackages = lib.filterAttrs (n: v: !v ? flake) systemFilteredPackages;
      regularList = lib.filter (p: p != null) (
        lib.mapAttrsToList (name: attrs: getPackage attrs.pkg-path) regularPackages
      );

      # Process flake packages
      flakePackages = lib.filterAttrs (n: v: v ? flake) systemFilteredPackages;
      flakeList = lib.mapAttrsToList (
        name: _: inputs.${name}.packages.${pkgs.system}.default or null
      ) flakePackages;
    in
    {
      home.packages = regularList ++ (lib.filter (p: p != null) flakeList);
    };

  mkBrewPackages =
    {
      lib,
      manifestFile,
      mappingFile,
    }:
    let
      manifest = lib.importTOML manifestFile;
      mapping = lib.importTOML mappingFile;
      originalPackages = manifest.install or { };

      packages = lib.filterAttrs (name: attrs: !attrs ? systems) originalPackages;

      normalizePath =
        pkgPath: if builtins.isList pkgPath then builtins.concatStringsSep "." pkgPath else pkgPath;

      nixToBrew = lib.listToAttrs (
        map (e: {
          name = e.nix;
          value = e;
        }) mapping.package
      );

      converted = lib.mapAttrsToList (
        name: attrs:
        let
          lookupKey = attrs.flake or (normalizePath attrs.pkg-path);
          brewInfo =
            nixToBrew.${lookupKey} or {
              brew = lookupKey;
              type = "formula";
            };
        in
        brewInfo
      ) packages;

      formatBrew =
        p:
        if p ? args then
          {
            name = p.brew;
            args = p.args;
          }
        else
          p.brew;
    in
    {
      homebrew.brews = map formatBrew (lib.filter (p: (p.type or "formula") == "formula") converted);
      homebrew.casks = map (p: p.brew) (lib.filter (p: p ? "type" && p.type == "cask") converted);
    };
}

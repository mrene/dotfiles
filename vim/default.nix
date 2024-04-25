{ inputs, self, config, ... }:

{
  perSystem = { pkgs, system, ... }:
  let
    nixvim = inputs.nixvim;
    nixvimLib = nixvim.lib.${system};
    nixvim' = nixvim.legacyPackages.${system};
    nixvimModule = {
      inherit pkgs;
      module = import ./config; # import the module directly
      # You can use `extraSpecialArgs` to pass additional arguments to your module files
      extraSpecialArgs = {
          inherit inputs;
        };
      };
      nvim = nixvim'.makeNixvimWithModule nixvimModule;
  in
  {
    packages.nvim = nvim;
  };
}

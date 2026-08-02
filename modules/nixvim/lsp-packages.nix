# Packages backing the enabled nixvim LSP servers, for reuse outside neovim.
{ config, lib }:
lib.optionals config.programs.nixvim.enable (
  lib.pipe config.programs.nixvim.lsp.servers [
    (lib.filterAttrs (name: _: name != "*"))
    builtins.attrValues
    (builtins.filter (server: server.enable && (server.package or null) != null))
    (map (server: server.package))
    lib.unique
  ]
)

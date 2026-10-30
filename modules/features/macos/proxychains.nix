# proxychains-ng through a local proxy, SOCKS5 on 20170 and HTTP on 20171: `proxy <command>`.
{
  flake.modules.darwin.proxychains = {
    homebrew.brews = ["proxychains-ng"];
  };

  flake.modules.homeManager.proxychains = {
    home.file.".proxychains/proxychains.conf".text = ''
      [ProxyList]
      socks5  127.0.0.1 20170
      http    127.0.0.1 20171
    '';
    home.shellAliases.proxy = "proxychains4";
  };
}

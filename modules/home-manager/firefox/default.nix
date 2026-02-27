{ pkgs, inputs, ... }:

{
  # ── Firefox with Declarative Extensions ──
  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      DisablePocket = true;
      SearchBar = "unified";

      Preferences = {
        # Privacy settings
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.pinned" = "";
        "browser.topsites.contile.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.system.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };
    };
    profiles.default = {
      isDefault = true;
      extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
#        styl-us
      ];
      settings = {
        "browser.contentblocking.category" = "strict";
        "extensions.pocket.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.ping-centre.telemetry" = false;
        "toolkit.telemetry.enabled" = false;

        # Zoom settings
        "layout.css.devPixelsPerPx" = "1.0";
        "browser.zoom.siteSpecific" = true;  # Remember per-site zoom levels
        "browser.zoom.full" = true;          # Full page zoom (not text-only)
        "zoom.defaultPercent" = 150;
        "zoom.default" = 1.5;

        # Disable password saving and autofills
        "signon.rememberSignons" = false;    # Disable password manager
        "signon.autofillForms" = false;      # Disable autofill for login forms
        "browser.formfill.enable" = false;   # Disable form autofill
        "browser.aboutConfig.showWarning" = false;
        "browser.compactmode.show" = true;

        # Disable tab groups
        "browser.tabs.groups.enabled" = false;

        # Block all notification permission requests
        "permissions.default.desktop-notification" = 2;

        # SOCKS5 proxy
        "network.proxy.type" = 1;
        "network.proxy.socks" = "127.0.0.1";
        "network.proxy.socks_port" = 1080;
        "network.proxy.socks_version" = 5;
        "network.proxy.socks_remote_dns" = true;
      };
    };
  };
}

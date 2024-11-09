# Quadlets

Quadlets go in `~/.config/containers/systemd`.

## Weechat

### Attach and configure

> [!TIP] Detach key sequence: `ctrl-p` `ctrl-q`.

```bash
ssh -t $remotehost sh -lc 'cd; podman attach weechat'
/set irc.look.smart_filter on
/set irc.server_default.msg_part ""
/set irc.server_default.msg_quit ""
/set irc.ctcp.clientinfo ""
/set irc.ctcp.finger ""
/set irc.ctcp.source ""
/set irc.ctcp.time ""
/set irc.ctcp.userinfo ""
/set irc.ctcp.version ""
/set irc.ctcp.ping ""
/plugin unload xfer
/set weechat.plugin.autoload "*,!xfer"
/filter add irc_smart * irc_smart_filter *
/server add mam irc.myanonamouse.net/6697
/set irc.server.mam.username $irc_username
/set irc.server_default.autojoin_dynamic on
/set irc.server.mam.autojoin "#anonamouse.net"
/set irc.server.mam.nicks "$irc_nick1,$irc_nick2"
/set irc.server.mam.autoconnect on
/connect mam
```

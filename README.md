# <p align="center">merbot

<p align="center">A Telegram Group Peace Keeper Bot

Bot Commands
------------
<table>
  <thead>
    <tr>
      <td><strong>Name</strong></td>
      <td><strong>Description</strong></td>
      <td><strong>Usage</strong></td>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>banhammer.lua</td>
      <td>Plugin to manage bans, kicks and white/black lists.</td>
      <td><code>!whitelist &lt;enable&gt;/&lt;disable&gt;</code> : Enable or disable whitelist mode<br>
          <code>!whitelist user &lt;user_id&gt;</code> : Allow user to use the bot when whitelist mode is enabled<br>
          <code>!whitelist user &lt;username&gt;</code> : Allow user to use the bot when whitelist mode is enabled<br>
          <code>!whitelist chat </code>: Allow everybody on current chat to use the bot when whitelist mode is enabled<br>
          <code>!whitelist delete user &lt;user_id&gt;</code> : Remove user from whitelist<br>
          <code>!whitelist delete chat </code>: Remove chat from whitelist<br>
          <code>!ban user &lt;user_id&gt;</code> : Kick user from chat and kicks it if joins chat again<br>
          <code>!ban user &lt;username&gt;</code> : Kick user from chat and kicks it if joins chat again<br>
          <code>!ban delete &lt;user_id&gt;</code> : Unban user<br>
          <code>!kick</code>: Kick replied user<br>
          <code>!kickme</code>: Bot kick user<br>
          <code>!kick &lt;user_id&gt;</code> : Kick user from chat group by id<br>
          <code>!kick &lt;username&gt;</code> : Kick user from chat group by username<br>
          <code>!superban user &lt;user_id&gt;</code> : Kick user from all chat and kicks it if joins again<br>
          <code>!superban user &lt;username&gt;</code> : Kick user from all chat and kicks it if joins again<br>
          <code>!superban delete &lt;user_id&gt;</code> : Unban user<br></td>
    </tr>
    <tr>
      <td>channels.lua</td>
      <td>Plugin to manage channels.<br>
          Enable or disable channel.</td>
      <td><code>!channel enable</code> : enable current channel<br>
          <code>!channel disable</code> : disable current channel<br></td>
    </tr>
    <tr>
      <td>groupmanager.lua</td>
      <td>Plugin to manage group chat.</td>
      <td><code>!group create &lt;group_name&gt;</code> : Create a new group (admin only)<br>
          <code>!group set about &lt;description&gt;</code> : Set group description<br>
          <code>!group about</code> : Read group description<br>
          <code>!group link get</code> : Get invite link.<br>
          <code>!group link revoke</code> : Revoke (remove and replace by newly generated) invite link.<br>
          <code>!group set rules &lt;rules&gt;</code> : Set group rules<br>
          <code>!group rules </code>: Read group rules<br>
          <code>!group set name &lt;new_name&gt;</code> : Set group name<br>
          <code>!group set photo </code>: Set group photo<br>
          <code>!group &lt;lock|unlock&gt; name </code>: Lock/unlock group name<br>
          <code>!group &lt;lock|unlock&gt; photo </code>: Lock/unlock group photo<br>
          <code>!group &lt;lock|unlock&gt; member </code>: Lock/unlock group member<br>
          <code>!group &lt;lock|unlock&gt; spam </code>: Enable/disable spam protection<br>
          <code>!group settings </code>: Show group settings<br></td>
    </tr>
    <tr>
      <td>help.lua</td>
      <td>Help plugin.<br>
          Get info from other plugins.</td>
      <td><code>!help </code>: Show list of plugins.<br>
          <code>!help all </code>: Show all commands for every plugin.<br>
          <code>!help [plugin name] </code>: Commands for that plugin.<br></td>
    </tr>
    <tr>
        <td>id.lua</td>
        <td>Know your id or the id of a chat members.</td>
        <td><code>!id </code>: Return your ID and the chat id if you are in one.<br>
            <code>!id(s) chat </code>: Return the IDs of the chat members.<br></td>
    </tr>
    <tr>
      <td>invite.lua</td>
      <td>Invite other user to the chat group</td>
      <td><code>!invite name [user_name]</code><br>
          <code>!invite id [user_id]</code><br></td>
    </tr>
    <tr>
      <td>moderation.lua</td>
      <td>Moderation plugin.</td>
      <td><code>!promote &lt;username&gt;</code> : Promote user as moderator<br>
          <code>!demote &lt;username&gt;</code> : Demote user from moderator<br>
          <code>!modlist </code>: List of moderators<br>
          <code>!modadd </code>: Add group to moderation list<br>
          <code>!modrem </code>: Remove group from moderation list<br>
          <code>!adminprom &lt;username&gt;</code> : Promote user as admin (must be done from a group)<br>
          <code>!admindem &lt;username&gt;</code> : Demote user from admin (must be done from a group)<br></td>
    </tr>
    <tr>
      <td>plugins.lua</td>
      <td>Plugin to manage other plugins. Enable, disable or reload.</td>
      <td><code>!plugins </code>: list all plugins.<br>
          <code>!plugins enable [plugin] </code>: enable plugin.<br>
          <code>!plugins disable [plugin] </code>: disable plugin.<br>
          <code>!plugins disable [plugin] chat </code>: disable plugin only this chat.<br>
          <code>!plugins reload </code>: reloads all plugins.<br></td>
    </tr>
    <tr>
      <td>stats.lua</td>
      <td>Plugin to update user stats.</td>
      <td><code>!stats </code>: Returns a list of username message number</td>
    </tr>
    <tr>
      <td>version.lua</td>
      <td>Shows bot version</tdd>
      <td><code>!version </code>: Shows bot version</td>
    </tr>
  </tbody>
</table>

[Installation](https</code>://github.com/yagop/telegram-bot/wiki/Installation)
------------
```bash
# Tested on Debian 8, for other OSs check out https://github.com/yagop/telegram-bot/wiki/Installation
sudo apt update
sudo apt upgrade
sudo apt install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev libjansson-dev libpython-dev make unzip git redis-server g++
```

```bash
# After those dependencies, lets install the bot
cd $HOME
git clone https://github.com/rizaumami/merbot.git
cd merbot
./launch.sh install
./launch.sh # Will ask you for a phone number & confirmation code.
```

Enable more [`plugins`](https</code>://github.com/rizaumami/merbot/tree/master/plugins)
-------------
See the plugins list with `!plugins` command.

Enable a disabled plugin by `!plugins enable [name]`.

Disable an enabled plugin by `!plugins disable [name]`.

Those commands require a privileged user, privileged users are defined inside `data/config.lua` (generated by the bot), stop the bot and edit if necessary.

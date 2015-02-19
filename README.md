telegram-bot
============

A Telegram Bot based on plugins using [tg](https://github.com/vysheng/tg).

Multimedia
----------
- When user sends image (png, jpg, jpeg) URL download and send it to origin.
- When user sends media (gif, mp4, pdf, etc.) URL download and send it to origin.
- When user sends twitter URL, send text and images to origin. Requires OAuth Key.
- When user sends youtube URL, send to origin video image.

![http://i.imgur.com/0FGUvU0.png](http://i.imgur.com/0FGUvU0.png) ![http://i.imgur.com/zW7WWWt.png](http://i.imgur.com/zW7WWWt.png) ![http://i.imgur.com/zW7WWWt.png](http://i.imgur.com/kPK7paz.png)

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
         <td>9gag.lua</td>
         <td>9GAG for telegram</td>
         <td>!9gag: Send random image from 9gag</td>
      </tr>
      <tr>
         <td>btc.lua</td>
         <td>Bitcoin global average market value (in EUR or USD)</td>
         <td>!btc [EUR|USD] [amount]</td>
      </tr>
      <tr>
         <td>echo.lua</td>
         <td>Simplest plugin ever!</td>
         <td>!echo [whatever]: echoes the msg</td>
      </tr>
      <tr>
         <td>eur.lua</td>
         <td>EURUSD market value</td>
         <td>!eur [USD]</td>
      </tr>
      <tr>
         <td>fortunes_uc3m.lua</td>
         <td>Fortunes from Universidad Carlos III</td>
         <td>!uc3m</td>
      </tr>
      <tr>
         <td>get.lua</td>
         <td>Retrieves variables saved with !set</td>
         <td>!get (value_name): Returns the value_name value.</td>
      </tr>
      <tr>
         <td>giphy.lua</td>
         <td>GIFs from telegram with Giphy API</td>
         <td>!gif (term): Search and sends GIF from Giphy. If no param, sends a trending GIF.<br>!giphy (term): Search and sends GIF from Giphy. If no param, sends a trending GIF.<br></td>
      </tr>
      <tr>
         <td>google.lua</td>
         <td>Searches Google and send results</td>
         <td>!google [terms]: Searches Google and send results</td>
      </tr>
      <tr>
         <td>gps.lua</td>
         <td>generates a map showing the given GPS coordinates</td>
         <td>!gps latitude,longitude: generates a map showing the given GPS coordinates</td>
      </tr>
      <tr>
         <td>hello.lua</td>
         <td>Says hello to someone</td>
         <td>say hello to [name]</td>
      </tr>
      <tr>
         <td>help.lua</td>
         <td>Help plugin. Get info from other plugins. </td>
         <td>!help: Show all the help<br>!help md: Generate a GitHub Markdown table<br></td>
      </tr>
      <tr>
         <td>images.lua</td>
         <td>When user sends image URL (ends with png, jpg, jpeg) download and send it to origin.</td>
         <td></td>
      </tr>
      <tr>
         <td>imdb.lua</td>
         <td>Imdb plugin for telegram</td>
         <td>!imdb [movie]</td>
      </tr>
      <tr>
         <td>img_google.lua</td>
         <td>Search image with Google API and sends it.</td>
         <td>!img [term]: Random search an image with Google API.</td>
      </tr>
      <tr>
         <td>invite.lua</td>
         <td>Invite other user to the chat group</td>
         <td>!invite name [user_name]<br>!invite id [user_id]<br></td>
      </tr>
      <tr>
         <td>location.lua</td>
         <td>Gets information about a location, maplink and overview</td>
         <td>!loc (location): Gets information about a location, maplink and overview</td>
      </tr>
      <tr>
         <td>media.lua</td>
         <td>When user sends media URL (ends with gif, mp4, pdf, etc.) download and send it to origin.</td>
         <td></td>
      </tr>
      <tr>
         <td>ping.lua</td>
         <td>If domain is offline, send msg to peer</td>
         <td></td>
      </tr>
      <tr>
         <td>plugins.lua</td>
         <td>Plugin to manage other plugins. Enable, disable or reload.</td>
         <td>!plugins: list all plugins<br>!plugins enable [plugin]: enable plugin<br>!plugins disable [plugin]: disable plugin<br>!plugins reload: reloads all plugins<br></td>
      </tr>
      <tr>
         <td>quotes.lua</td>
         <td>Quote plugin, you can create and retrieves random quotes</td>
         <td>!addquote [msg]<br>!quote<br></td>
      </tr>
      <tr>
         <td>rae.lua</td>
         <td>Spanish dictionary</td>
         <td>!rae [word]: Search that word in Spanish dictionary. Powered by https://github.com/javierhonduco/dulcinea</td>
      </tr>
      <tr>
         <td>set.lua</td>
         <td>Plugin for saving values. get.lua plugin is necesary to retrieve them.</td>
         <td>!set [value_name] [data]: Saves the data with the value_name name.</td>
      </tr>
      <tr>
         <td>stats.lua</td>
         <td>Plugin to update user stats.</td>
         <td>!stats: Returns a list of Username [telegram_id]: msg_num</td>
      </tr>
      <tr>
         <td>time.lua</td>
         <td>Displays the local time in an area</td>
         <td>!time [area]: Displays the local time in that area</td>
      </tr>
      <tr>
         <td>twitter.lua</td>
         <td>When user sends twitter URL, send text and images to origin. Requieres OAuth Key.</td>
         <td></td>
      </tr>
      <tr>
         <td>twitter_send.lua</td>
         <td>Sends a tweet</td>
         <td>!tw [text]: Sends the Tweet with the configured accout.</td>
      </tr>
      <tr>
         <td>version.lua</td>
         <td>Shows bot version</td>
         <td>!version: Shows bot version</td>
      </tr>
      <tr>
         <td>weather.lua</td>
         <td>weather in that city (Madrid is default)</td>
         <td>!weather (city)</td>
      </tr>
      <tr>
         <td>xkcd.lua</td>
         <td>Send comic images from xkcd</td>
         <td>!xkcd (id): Send an xkcd image and tigle. If not id, send a random one<br></td>
      </tr>
      <tr>
         <td>youtube.lua</td>
         <td>Sends YouTube info and image.</td>
         <td></td>
      </tr>
   </tbody>
</table>

Installation
------------
```bash
# Tested on Ubuntu 14.04, for other OSs check out https://github.com/vysheng/tg#installation
$ sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev unzip git
$ cd /tmp
$ wget http://luarocks.org/releases/luarocks-2.2.0.tar.gz
$ tar -xzvf luarocks-2.2.0.tar.gz
$ cd luarocks-2.2.0/
$ ./configure
$ make && sudo make install
$ sudo luarocks install oauth
$ sudo luarocks install luasocket
```
```bash
# After those dependencies, lets install the bot
$ cd $HOME
$ git clone https://github.com/yagop/telegram-bot.git --recursive
$ cd telegram-bot/tg
$ ./configure && make && cd ..
$ ./launch.sh # Will ask you for a phone number & confirmation code.
```

Enable more [`plugins`](https://github.com/yagop/telegram-bot/tree/master/plugins)
-------------
See the plugins list with `!plugins` command.

Enable a disabled plugin by `!plugins enable [name]`.

Disable an enabled plugin by `!plugins disable [name]`.

Those commands require a privileged user, privileged users are defined inside `data/config.lua` (generated by the bot), stop de bot and edit if necessary.


Run it as a daemon
------------
If your linux/unix comes with [upstart](http://upstart.ubuntu.com/) you can run the bot by this way
```bash
$ sed -i "s/yourusername/$(whoami)/g" etc/telegram.conf
$ sed -i "s_telegrambotpath_$(pwd)_g" etc/telegram.conf
$ sudo cp etc/telegram.conf /etc/init/
$ sudo start telegram # To start it
$ sudo stop telegram # To stop it
```

Contact me
------------
You can contact me [via Telegram](https://telegram.me/yago_perez) but if you have an issue please [open](https://github.com/yagop/telegram-bot/issues) one.

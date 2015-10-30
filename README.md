telegram-bot
============

[![Join the chat at https://gitter.im/yagop/telegram-bot](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/yagop/telegram-bot?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

[![](https://travis-ci.org/yagop/telegram-bot.svg?branch=master)](https://travis-ci.org/yagop/telegram-bot)
[![Donate button](https://img.shields.io/badge/nepal-donate-yellow.svg)](http://www.nrcs.org/donate-nrcs "Donate to Nepal Red Cross Society")

A Telegram Bot based on plugins using [tg](https://github.com/vysheng/tg).

Multimedia
----------
- When user sends image (png, jpg, jpeg) URL download and send it to origin.
- When user sends media (gif, mp4, pdf, etc.) URL download and send it to origin.
- When user sends twitter URL, send text and images to origin. Requires OAuth Key.
- When user sends YouTube URL, send to origin video image.

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
      <td>boobs.lua</td>
      <td>Gets a random boobs or butts pic</td>
      <td>!boobs: Get a boobs NSFW image. :underage:<br>!butts: Get a butts NSFW image. :underage:<br></td>
    </tr>
    <tr>
      <td>btc.lua</td>
      <td>Bitcoin global average market value (in EUR or USD)</td>
      <td>!btc [EUR|USD] [amount]</td>
    </tr>
    <tr>
      <td>bugzilla.lua</td>
      <td>Lookup bugzilla status update</td>
      <td>/bot bugzilla [bug number]</td>
    </tr>
    <tr>
      <td>calculator.lua</td>
      <td>Calculate math expressions with mathjs API</td>
      <td>!calc [expression]: evaluates the expression and sends the result.</td>
    </tr>
    <tr>
      <td>channels.lua</td>
      <td>Plugin to manage channels. Enable or disable channel.</td>
      <td>!channel enable: enable current channel<br>!channel disable: disable current channel<br></td>
    </tr>
    <tr>
      <td>danbooru.lua</td>
      <td>Gets a random fresh or popular image from Danbooru</td>
      <td>!danbooru - gets a random fresh image from Danbooru :underage:<br>!danboorud - random daily popular image :underage:<br>!danbooruw - random weekly popular image :underage:<br>!danboorum - random monthly popular image :underage:<br></td>
    </tr>
    <tr>
      <td>dogify.lua</td>
      <td>Create a doge image with words.</td>
      <td>!dogify (words/or phrases/separated/by/slashes) - Create a doge image with the words.</td>
    </tr>
    <tr>
      <td>download_media.lua</td>
      <td>When bot receives a media msg, download the media.</td>
      <td></td>
    </tr>
    <tr>
      <td>echo.lua</td>
      <td>Simplest plugin ever!</td>
      <td>!echo [whatever]: echoes the msg</td>
    </tr>
    <tr>
      <td>eur.lua</td>
      <td>Real-time EURUSD market price</td>
      <td>!eur [USD]</td>
      </tr>
    <tr>
      <td>expand.lua</td>
      <td>Expand a shorten URL to the original.</td>
      <td>!expand [url]</td>
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
      <td>gnuplot.lua</td>
      <td>Gnuplot plugin</td>
      <td>!gnuplot [single variable function]: Plot single variable function.</td>
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
      <td>hackernews.lua</td>
      <td>Show top 5 hacker news (ycombinator.com)</td>
      <td>!hackernews</td>
    </tr>
    <tr>
      <td>hello.lua</td>
      <td>Says hello to someone</td>
      <td>say hello to [name]</td>
    </tr>
    <tr>
      <td>help.lua</td>
      <td>Help plugin. Get info from other plugins. </td>
      <td>!help: Show list of plugins.<br>!help all: Show all commands for every plugin.<br>!help [plugin name]: Commands for that plugin.<br></td>
    </tr>
    <tr>
        <td>id.lua</td>
        <td>Know your id or the id of a chat members.</td>
        <td>!id: Return your ID and the chat id if you are in one.<br>!id(s) chat: Return the IDs of the chat members.<br></td>
    </tr>
    <tr>
      <td>images.lua</td>
      <td>When user sends image URL (ends with png, jpg, jpeg) download and send it to origin.</td>
      <td></td>
    </tr>
    <tr>
      <td>imdb.lua</td>
      <td>IMDB plugin for Telegram</td>
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
      <td>isup.lua</td>
      <td>Check if a website or server is up.</td>
      <td>!isup [host]: Performs a HTTP request or Socket (ip:port) connection<br>!isup cron [host]: Every 5mins check if host is up. (Requires privileged user)<br>!isup cron delete [host]: Disable checking that host.<br></td>
    </tr>
    <tr>
      <td>location.lua</td>
      <td>Gets information about a location, maplink and overview</td>
      <td>!loc (location): Gets information about a location, maplink and overview</td>
    </tr>
    <tr>
      <td>magic8ball.lua</td>
      <td>Magic 8Ball</td>
      <td>!magic8ball</td>
    </tr>
    <tr>
      <td>media.lua</td>
      <td>When user sends media URL (ends with gif, mp4, pdf, etc.) download and send it to origin.</td>
      <td></td>
    </tr>
    <tr>
      <td>meme.lua</td>
      <td>Generate a meme image with up and bottom texts.</td>
      <td>
      !meme search (name): Return the name of the meme that match.<br>!meme list: Return the link where you can see the memes.<br>!meme listall: Return the list of all memes. Only admin can call it.<br>!meme [name] - [text_up] - [text_down]: Generate a meme with the picture that match with that name with the texts provided.<br>!meme [name] "[text_up]" "[text_down]": Generate a meme with the picture that match with that name with the texts provided.<br>
      </td>
    </tr>
    <tr>
      <td>minecraft.lua</td>
      <td>Searches Minecraft server and sends info</td>
      <td>!mine [ip]: Searches Minecraft server on specified IP and sends info. Default port: 25565<br>!mine [ip] [port]: Searches Minecraft server on specified IP and port and sends info.<br></td>
      </tr>
    <tr>
      <td>pili.lua</td>
      <td>Shorten an URL with pili.la service</td>
      <td>!pili [url]: Short the url</td>
    </tr>
    <tr>
      <td>plugins.lua</td>
      <td>Plugin to manage other plugins. Enable, disable or reload.</td>
      <td>!plugins: list all plugins.<br>!plugins enable [plugin]: enable plugin.<br>!plugins disable [plugin]: disable plugin.<br>!plugins disable [plugin] chat: disable plugin only this chat.<br>!plugins reload: reloads all plugins.<br></td>
    </tr>
    <tr>
      <td>qr.lua</td>
      <td>Given a text it returns a qr code</td>
      <td>!qr [text] : returns a black and white qr code <br> !qr "[background color]" "[data color]" [text] : returns a colored qr code (see !help qr to see how specify colors).</td>
    </tr>
    <tr>
      <td>quotes.lua</td>
      <td>Quote plugin, you can create and retrieves random quotes</td>
      <td>!addquote [msg]<br>!quote<br></td>
    </tr>
    <tr>
      <td>rae.lua</td>
      <td>Spanish dictionary</td>
      <td>!rae [word]: Search that word in Spanish dictionary.</td>
    </tr>
    <tr>
      <td>roll.lua</td>
      <td>Roll some dice!</td>
      <td>
        !roll d
        <sides>
        |
        <count>
        d
        <sides>
      </td>
    </tr>
    <tr>
      <td>rss.lua</td>
      <td>Manage User/Chat RSS subscriptions.</td>
      <td>!rss: Get the rss subscriptions.<br>!rss subscribe (url): Subscribe to that url.<br>!rss unsubscribe (id): Unsubscribe of that id.<br>!rss sync: Sync the rss subscriptios now. Only sudo users can use this option.<br></td>
    </tr>
    <tr>
      <td>search_youtube.lua</td>
      <td>Search video on YouTube and send it.</td>
      <td>!youtube [term]: Search for a YouTube video and send it.</td>
    </tr>
    <tr>
      <td>set.lua</td>
      <td>Plugin for saving values. get.lua plugin is necessary to retrieve them.</td>
      <td>!set [value_name] [data]: Saves the data with the value_name name.</td>
    </tr>
    <tr>
      <td>stats.lua</td>
      <td>Plugin to update user stats.</td>
      <td>!stats: Returns a list of Username [telegram_id]: msg_num</td>
    </tr>
    <tr>
      <td>steam.lua</td>
      <td>Grabs Steam info for Steam links.</td>
      <td></td>
    </tr>
    <tr>
      <td>tex.lua</td>
      <td>Convert LaTeX equation to image</td>
      <td>!tex [equation]: Convert LaTeX equation to image</td>
    </tr>
    <tr>
      <td>time.lua</td>
      <td>Displays the local time in an area</td>
      <td>!time [area]: Displays the local time in that area</td>
    </tr>
    <tr>
      <td>translate.lua</td>
      <td>Translate some text</td>
      <td>!translate text. Translate the text to English.<br>!translate target_lang text.<br>!translate source,target text<br></td>
    </tr>
    <tr>
      <td>tweet.lua</td>
      <td>Random tweet from user</td>
      <td>!tweet id [id]: Get a random tweet from the user with that ID<br>!tweet id [id] last: Get a random tweet from the user with that ID<br>!tweet name [name]: Get a random tweet from the user with that name<br>!tweet name [name] last: Get a random tweet from the user with that name<br></td>
    </tr>
    <tr>
      <td>twitter.lua</td>
      <td>When user sends twitter URL, send text and images to origin. Requires OAuth Key.</td>
      <td></td>
    </tr>
    <tr>
      <td>twitter_send.lua</td>
      <td>Sends a tweet</td>
      <td>!tw [text]: Sends the Tweet with the configured account.</td>
    </tr>
    <tr>
      <td>version.lua</td>
      <td>Shows bot version</tdd>
      <td>!version: Shows bot version</td>
    </tr>
    <tr>
      <td>vote.lua</td>
      <td>Plugin for voting in groups.</td>
      <td>!voting reset: Reset all the votes.<br>!vote [number]: Cast the vote.<br>!voting stats: Shows the statistics of voting.<br></td>
    </tr>
    <tr>
      <td>weather.lua</td>
      <td>weather in that city (Madrid is default)</td>
      <td>!weather (city)</td>
      </tr>
    <tr>
      <td>webshot.lua</td>
      <td>Take an screenshot of a web.</td>
      <td>!webshot [url]</td>
    </tr>
    <tr>
      <td>wiki.lua</td>
      <td>Searches Wikipedia and send results</td>
      <td>!wiki [terms]: Searches wiki and send results<br>!wiki_set [wiki]: sets the wikimedia site for this chat<br>!wiki_get: gets the current wikimedia site<br></td>
    </tr>
    <tr>
      <td>xkcd.lua</td>
      <td>Send comic images from xkcd</td>
      <td>!xkcd (id): Send an xkcd image and title. If not id, send a random one<br></td>
    </tr>
    <tr>
      <td>youtube.lua</td>
      <td>Sends YouTube info and image.</td>
      <td></td>
    </tr>
  </tbody>
</table>

[Installation](https://github.com/yagop/telegram-bot/wiki/Installation)
------------
```bash
# Tested on Ubuntu 14.04, for other OSs check out https://github.com/yagop/telegram-bot/wiki/Installation
sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev make unzip git redis-server g++ libjansson-dev libpython-dev expat libexpat1-dev
```

```bash
# After those dependencies, lets install the bot
cd $HOME
git clone https://github.com/yagop/telegram-bot.git
cd telegram-bot
./launch.sh install
./launch.sh # Will ask you for a phone number & confirmation code.
```

Enable more [`plugins`](https://github.com/yagop/telegram-bot/tree/master/plugins)
-------------
See the plugins list with `!plugins` command.

Enable a disabled plugin by `!plugins enable [name]`.

Disable an enabled plugin by `!plugins disable [name]`.

Those commands require a privileged user, privileged users are defined inside `data/config.lua` (generated by the bot), stop the bot and edit if necessary.


Run it as a daemon
------------
If your Linux/Unix comes with [upstart](http://upstart.ubuntu.com/) you can run the bot by this way
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

[Join](https://telegram.me/joinchat/ALJ3iwFAhOCh4WNUHAyzXQ) on the TelegramBot Discussion Group.

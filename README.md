telegram-bot
============

Bot for telegram with tg [tg](https://github.com/vysheng/tg).

Requires liblua-socket, there isn't liblua5.2-socket for ubuntu 12.04, but you can use Lua 5.1

```Shell
sudo apt-get remove lua5.2 liblua5.2-dev # If you installed lua5.2
sudo apt-get install lua5.1 liblua5.1-dev liblua5.1-socket2 libreadline-dev libconfig-dev libssl-dev fortunes
git submodule update --init --recursive
cd tg
./configure
make
../launch.sh
```

**!help** for command list.


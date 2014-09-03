telegram-bot
============

Bot for telegram with [tg](https://github.com/vysheng/tg).


Requires sudo apt-get install lua-socket:

```bash
sudo apt-get install lua-socket libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev
git submodule update --init --recursive
cd tg
./configure
make
../launch.sh
```

Command list
```
!help : print this help
!ping : bot sends pong
!sh (text) : send commands to bash (only privileged users)
!echo (text) : echo the msg
!version : version info
!cpu : status (uname + top)
!fwd : forward msg
!forni : send text to group Fornicio
!fortune : print a random adage
!weather [city] : weather in that city (Madrid if not city)
!9gag : send random image from 9gag
!uc3m : fortunes from Universidad Carlos III
```

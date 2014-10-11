telegram-bot
============

A telegram bot using https://github.com/vysheng/tg.

Installation
------------

* Requirements
```bash
# Tested on Ubuntu 14.04
$ sudo apt-get install libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev fortune curl luarocks
```

* Clone the repo & compile the telegram library
```bash
$ git clone https://github.com/yagop/telegram-bot --recursive && cd telegram-bot/tg
$ ./configure && make
$ cd .. && ./launch.sh # Will ask you for a telegram enabled number phone & confirmation code.
```

Command list
```
!help : print command list
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
!rae (word): Spanish dictionary
!eur : EURUSD market value
!img (text) : search image with Google API and sends it
!uc3m : fortunes from Universidad Carlos III
```

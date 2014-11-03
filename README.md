telegram-bot
============

A telegram bot using https://github.com/vysheng/tg.

Installation
------------
```bash
# Tested on Ubuntu 14.04, for other OSs check out https://github.com/vysheng/tg#installation
$ sudo apt-get install lua-socket libreadline-dev libconfig-dev libssl-dev lua5.2 liblua5.2-dev libevent-dev fortune
$ git clone https://github.com/yagop/telegram-bot --recursive
$ cd telegram-bot/tg
$ ./configure && make
$ cd .. && ./launch.sh # Will ask you for a phone number & confirmation code.
```

Command list
------------
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
!weather (city) : weather in that city (Madrid is default)
!9gag : send random url image from 9gag
!rae (word) : Spanish dictionary
!eur (USD) : EURUSD market value
!img (text) : search image with Google API and sends it
!uc3m : fortunes from Universidad Carlos III
!set [variable_name] [value] : store for !get
!get (variable_name) : retrieves variables saved with !set
```

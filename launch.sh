#!/bin/sh

cd "$(dirname "$0")"

if [ ! -f ./tg/telegram.h ]; then
    echo "Download tg first:"
    echo "git submodule update --init --recursive"
    exit
fi

if [ ! -f ./tg/telegram ]; then
    echo "Compile telegram first:"
    echo "cd tg && ./configure && make"
    exit
fi

./tg/telegram -k tg/tg-server.pub -s ./bot/bot.lua

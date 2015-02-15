#!/bin/sh

cd "$(dirname "$0")"

if [ ! -f ./tg/telegram.h ]; then
    echo "Download tg first:"
    echo "git submodule update --init --recursive"
    exit
fi

if [ ! -f ./tg/bin/telegram-cli ]; then
    echo "Compile telegram first:"
    echo "cd tg && ./configure && make"
    exit
fi

./tg/bin/telegram-cli -k tg/tg-server.pub -s ./bot/bot.lua -l 1

--[[
                     _   _        _
     _ __ ___   __ _| |_| |_ __ _| |_ __ _
    | '_ ` _ \ / _` | __| __/ _` | __/ _` |
    | | | | | | (_| | |_| || (_| | || (_| |
    |_| |_| |_|\__,_|\__|\__\__,_|\__\__,_|

    Configuration file for mattata v1.1.0

    Copyright 2017 Matthew Hesketh <wrxck0@gmail.com>
    This code is licensed under the MIT. See LICENSE for details.

    Each value in an array should be comma separated, with the exception of the last value!
    Make sure you always update your configuration file after pulling changes from GitHub!

]]

local get_plugins = function(extension, directory)
    extension = extension and tostring(extension) or 'mattata'
    if extension:match('^%.') then
        extension = extension:match('^%.(.-)$')
    end
    directory = directory and tostring(directory) or 'plugins'
    if directory:match('/$') then
        directory = directory:match('^(.-)/$')
    end
    local plugins = {}
    local all = io.popen('mkdir -p ' .. directory .. '; ls ' .. directory .. '/'):read('*all')
    for plugin in all:gmatch('[%w_-]+%.' .. extension .. ' ?') do
        plugin = plugin:match('^([%w_-]+)%.' .. extension .. ' ?$')
        table.insert(plugins, plugin)
    end
    return plugins
end

return { -- Rename this file to configuration.lua for the bot to work!
    ['bot_token'] = '620472523:AAF-6nir55yctdZ8P3n_A3YZp_b5Q0I3Uc8', -- In order for the bot to actually work, you MUST insert the Telegram
    -- bot API token you received from @BotFather.
    -- The following two tokens will require you to have setup payments with @BotFather, and
    -- a Stripe account with @stripe!
    ['stripe_live_token'] = '', -- Payment token you receive from @BotFather.
    ['stripe_test_token'] = '', -- Test payment token you receive from @BotFather.
    ['admins'] = '401643149'  {  -- Here you need to specify the numerical ID of the users who shall have
    -- FULL control over the bot, this includes access to server files via the lua and shell plugins.
        nil
    },
    ['language'] = 'en', -- The two character locale to set your default language to.
    ['log_chat'] = '-1001266807872', -- This needs to be the numerical identifier of the chat you wish to log
    -- errors into. If it's not a private chat it should begin with a '-' symbol.
    ['log_admin_actions'] = true, -- Should administrative actions be logged? [true/false]
    ['log_channel'] = nil, -- This needs to be the numerical identifier of the channel you wish
    -- to log administrative actions in by default. It should begin with a '-' symbol.
    ['bug_reports_chat'] = nil, -- This needs to be the numerical identifier of the chat you wish to send
    -- bug reports into. If it's not a private chat it should begin with a '-' symbol.
    ['counter_channel'] = nil, -- This needs to be the numerical identifier of the channel you wish
    -- to forward messages into, for use with the /counter command. It should begin with a '-' symbol.
    ['download_location'] = '/tmp/', -- The location to save all downloaded media to.
    ['respond_to_misc'] = true, -- Respond to shitpostings/memes in mattata.lua? [true/false]
    ['max_copypasta_length'] = 300, -- The maximum number of characters a message can have to be
    -- able to have /copypasta used on it.
    ['debug'] = false, -- Turn this on to print EVEN MORE information to the terminal.
    ['plugins'] = get_plugins(),
    ['redis'] = { -- Configurable options for connecting the bot to redis. Do NOT modify
    -- these settings if you don't know what you're doing!
        ['host'] = '127.0.0.1',
        ['port'] = 6379,
        ['password'] = nil,
        ['db'] = 2
    },
    ['keys'] = { -- API keys needed for the full functionality of several plugins.
        ['cats'] = '', -- http://thecatapi.com/api-key-registration.html
        ['translate'] = '', -- https://tech.yandex.com/keys/get/?service=trnsl
        ['lyrics'] = '', -- https://developer.musixmatch.com/admin/applications
        ['lastfm'] = '', -- http://www.last.fm/api/account/create
        ['weather'] = '', -- https://darksky.net/dev/register
        ['youtube'] = '', -- https://console.developers.google.com/apis
        ['bing'] = '', -- https://datamarket.azure.com/account/keys
        ['flickr'] = '', -- https://www.flickr.com/services/apps/create/noncommercial/?
        ['news'] = '', -- https://newsapi.org/
        ['twitch'] = '', -- https://twitchapps.com/tmi/
        ['pastebin'] = '', -- https://pastebin.com/api
        ['dictionary'] = {  -- https://developer.oxforddictionaries.com/
            ['id'] = '',
            ['key'] = ''
        },
        ['adfly'] = { -- https://login.adf.ly/login
            ['apikey'] = '',
            ['userid'] = ''
        },
        ['pasteee'] = '', -- https://paste.ee/
        ['google'] = { -- https://console.developers.google.com/apis
            ['api_key'] = '',
            ['cse_key'] = ''
        },
        ['steam'] = '', -- https://steamcommunity.com/dev/apikey
        ['spotify'] = { -- https://developer.spotify.com/my-applications/#!/applications/create
            ['client_id'] = '',
            ['client_secret'] = '',
            ['redirect_uri'] = ''
        },
        ['twitter'] = { -- https://apps.twitter.com/app/new
            ['consumer_key'] = '',
            ['consumer_secret'] = ''
        },
        ['imgur'] = { -- https://api.imgur.com/oauth2/addclient
            ['client_id'] = '',
            ['client_secret'] = ''
        }
    },
    ['errors'] = { -- Messages to provide a more user-friendly approach to errors.
        ['connection'] = 'Connection error.',
        ['results'] = 'I couldn\'t find any results for that.',
        ['supergroup'] = 'This command can only be used in supergroups.',
        ['admin'] = 'You need to be a moderator or an administrator in this chat in order to use this command.',
        ['unknown'] = 'I don\'t recognise that user. If you would like to teach me who they are, forward a message from them to any chat that I\'m in.',
        ['generic'] = 'An unexpected error occured. Please report this error using /bugreport.'
    },
    ['voteban'] = { -- Values used in plugins/administration.lua, for plugins/voteban.lua functionality.
        ['upvotes'] = {
            ['maximum'] = 50,
            ['minimum'] = 2
        },
        ['downvotes'] = {
            ['maximum'] = 50,
            ['minimum'] = 2
        }
    },
    ['administration'] = { -- Values used in plugins/administration.lua.
        ['warnings'] = {
            ['maximum'] = 10,
            ['minimum'] = 2
        }
    },
    ['join_messages'] = { -- Values used in plugins/administration.lua.
        'Welcome, NAME!',
        'Hello, NAME!',
        'Enjoy your stay, NAME!',
        'I\'m glad you joined, NAME!',
        'Howdy, NAME!',
        'Hi, NAME!'
    },
    ['stickers'] = { -- Values used in mattata.lua, for administrative plugin functionality.
    -- These are the file_id values for stickers which are binded to the relevant command.
        ['ban'] = {
            'CAADBAADzwIAAlAYNw1h7nezc1nH7gI',
            'CAADBAAD0AIAAlAYNw13TaMgAYaXywI'
        },
        ['warn'] = {
            'CAADBAAD0QIAAlAYNw1wPS6g_arjDgI',
            'CAADBAAD0gIAAlAYNw2-pLQLQonbCQI'
        },
        ['kick'] = {
            'CAADBAAD0wIAAlAYNw3KIKm0bVviWwI'
        }
    }
}

--[[

    End of configuration, you're good to go.
    Use `./launch.sh` to start the bot.
    If you can't execute the script, try running `chmod +x launch.sh`

]]

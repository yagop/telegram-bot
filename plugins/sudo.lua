do

  local function cb_getdialog(extra, success, result)
    vardump(extra)
    vardump(result)
  end

  local function parsed_url(link)
    local parsed_link = URL.parse(link)
    local parsed_path = URL.parse_path(parsed_link.path)

    for k,segment in pairs(parsed_path) do
      if segment == 'joinchat' then
        invite_link = parsed_path[k+1]:gsub('[ %c].+$', '')
        break
      end
    end
    return invite_link
  end

  local function action_by_reply(extra, success, result)
    local hash = parsed_url(result.text)
    join = import_chat_link(hash, ok_cb, false)
  end

--------------------------------------------------------------------------------

  function run(msg, matches)

    if not is_sudo(msg.from.peer_id) then
      return
    end

    if matches[1] == 'bin' then
      local input = matches[2]:gsub('—', '--')
      local header = '<b>$</b> <code>' .. input .. '</code>\n'
      local stdout = io.popen(input):read('*all')

      bot_sendMessage(get_receiver_api(msg), header .. '<code>' .. stdout .. '</code>', true, msg.id, 'html')
    end

    if matches[1] == 'bot' then
      if matches[2] == 'token' then
        if not _config.bot_api then
          _config.bot_api = {key = '', uid = '', uname = '', master = ''}
        end
        local botid = api_getme(matches[3])
        _config.bot_api.key = matches[3]
        _config.bot_api.uid = botid.id
        _config.bot_api.uname = botid.username
        save_config()
        send_message(msg, '<b>Bot API key has been saved</b>', 'html')
      end
    end
    if matches[1] == "block" then
      block_user("user#id" .. matches[2], ok_cb, false)

      if is_mod(matches[2], msg.to.peer_id) then
        return "You can't block moderators."
      end
      if is_admin(matches[2]) then
        return "You can't block administrators."
      end
      block_user("user#id" .. matches[2], ok_cb, false)
      return "User blocked"
    end

    if matches[1] == "unblock" then
      unblock_user("user#id" .. matches[2], ok_cb, false)
      return "User unblocked"
    end

    if matches[1] == "join" then
      if msg.reply_id then
        get_message(msg.reply_id, action_by_reply, msg)
      elseif matches[2] then
        local hash = parsed_url(matches[2])
        join = import_channel_link(hash, ok_cb, false)
      end
    end

    if matches[1] == 'setlang' then
      _config.lang = matches[2]
      save_config()

      send_message(msg, 'Set bot language to ' .. matches[2], 'html')
    end
  end

  --------------------------------------------------------------------------------

  return {
    description = 'Various sudo commands.',
    usage = {
      sudo = {
        '<code>!bin [command]</code>',
        'Run a system command.',
        '',
        '<code>!block [user_id]</code>',
        'Block user_id to PM.',
        '',
        '<code>!unblock [user_id]</code>',
        'Allowed user_id to PM.',
        '',
        '<code>!bot restart</code>',
        'Restart bot.',
        '',
        '<code>!bot status</code>',
        'Print bot status.',
        '',
        '<code>!bot token [bot_api_key]</code>',
        'Input bot API key.',
        '',
        '<code>!join</code>',
        'Join a group by replying a message containing invite link.',
        '',
        '<code>!join [invite_link]</code>',
        'Join into a group by providing their [invite_link].',
        '',
        '<code>!version</code>',
        'Shows bot version',
      },
    },
    patterns = {
      '^!(bin) (.*)$',
      '^!(block) (.*)$',
      '^!(unblock) (.*)$',
      '^!(block) (%d+)$',
      '^!(unblock) (%d+)$',
      '^!(bot) (%g+) (.*)$',
      '^!(join)$',
      '^!(join) (.*)$',
      '^!(setlang) (%g+)$'
    },
    run = run
  }

end
do

  -- Returns true if is not empty
  local function has_usage_data(dict)
    if (dict.usage == nil or dict.usage == '') then
      return false
    end
    return true
  end

  -- Get commands for that plugin
  local function plugin_help(name, number, requester)
    local plugin = ''

    if number then
      local i = 0

      for name in pairsByKeys(plugins) do
        if plugins[name].hidden then
          name = nil
        else
          i = i + 1
          if i == tonumber(number) then
            plugin = plugins[name]
          end
        end
      end
    else
      plugin = plugins[name]
      if not plugin then return nil end
    end

    local text = ''

    if (type(plugin.usage) == 'table') then
      for ku,usage in pairs(plugin.usage) do
        if ku == 'user' then -- usage for user
          if (type(plugin.usage.user) == 'table') then
            for k,v in pairs(plugin.usage.user) do
              text = text .. v .. '\n'
            end
          elseif has_usage_data(plugin) then -- Is not empty
            text = text .. plugin.usage.user .. '\n'
          end
        elseif ku == 'moderator' then -- usage for moderator
          if requester == 'moderator' or requester == 'owner' or requester == 'admin' or requester == 'sudo' then
            if (type(plugin.usage.moderator) == 'table') then
              for k,v in pairs(plugin.usage.moderator) do
                text = text .. v .. '\n'
              end
            elseif has_usage_data(plugin) then -- Is not empty
              text = text .. plugin.usage.moderator .. '\n'
            end
          end
        elseif ku == 'owner' then -- usage for owner
          if requester == 'owner' or requester == 'admin' or requester == 'sudo' then
            if (type(plugin.usage.owner) == 'table') then
              for k,v in pairs(plugin.usage.owner) do
                text = text .. v .. '\n'
              end
            elseif has_usage_data(plugin) then -- Is not empty
              text = text .. plugin.usage.owner .. '\n'
            end
          end
        elseif ku == 'admin' then -- usage for admin
          if requester == 'admin' or requester == 'sudo' then
            if (type(plugin.usage.admin) == 'table') then
              for k,v in pairs(plugin.usage.admin) do
                text = text .. v .. '\n'
              end
            elseif has_usage_data(plugin) then -- Is not empty
              text = text .. plugin.usage.admin .. '\n'
            end
          end
        elseif ku == 'sudo' then -- usage for sudo
          if requester == 'sudo' then
            if (type(plugin.usage.sudo) == 'table') then
              for k,v in pairs(plugin.usage.sudo) do
                text = text .. v .. '\n'
              end
            elseif has_usage_data(plugin) then -- Is not empty
              text = text .. plugin.usage.sudo .. '\n'
            end
          end
        else
          text = text .. usage .. '\n'
        end
      end
    elseif has_usage_data(plugin) then -- Is not empty
      text = text .. plugin.usage
    end
    return text
  end


  -- !help command
  local function telegram_help(msg)
    local i = 0
    local text = '<b>Plugins</b>\n\n'
    -- Plugins names
    for name in pairsByKeys(plugins) do
      if plugins[name].hidden then
        name = nil
      else
      i = i + 1
      text = text .. '<b>' .. i .. '</b>. ' .. name .. '\n'
      end
    end
    text = text .. '\n' .. 'There are <b>' .. i .. '</b> plugins help available.\n'
           .. '<b>-</b> <code>!help [plugin name]</code> for more info.\n'
           .. '<b>-</b> <code>!help [plugin number]</code> for more info.\n'
           .. '<b>-</b> <code>!help all</code> to show all info.'

    bot_sendMessage(get_receiver_api(msg), text, true, msg.id, 'html')
  end

--  -- !help all command
--  local function help_all(requester)
--    local ret = ''
--    for name in pairsByKeys(plugins) do
--      if plugins[name].hidden then
--        name = nil
--      else
--        ret = ret .. plugin_help(name, nil, requester)
--      end
--    end
--    return ret
--  end

  --------------------------------------------------------------------------------

  local function run(msg, matches)
    local uid = msg.from.peer_id
    local gid = msg.to.peer_id

    if is_sudo(uid) then
      requester = 'sudo'
    elseif is_admin(uid) then
      requester = 'admin'
    elseif is_owner(msg, gid, uid) then
      requester = 'owner'
    elseif is_mod(msg, gid, uid) then
      requester = 'moderator'
    else
      requester = 'user'
    end

    if msg.text == '!help' then
      return telegram_help(msg)
    elseif matches[1] == 'all' then
      send_message(msg, 'Please read @thefinemanual', 'html')
      --return help_all(requester)
    else
      local text = ''

      if tonumber(matches[1])  then
        text = plugin_help(nil, matches[1], requester)
      else
        text = plugin_help(matches[1], nil, requester)
      end
      if not text then
        send_message(msg, 'No help entry for "' .. matches[1] .. '".\n'
            .. 'Please visit @thefinemanual for the complete list.', 'html')
        return
      end
      if text == 'text' then
        send_message(msg, 'The plugins is not for your privilege.', 'html')
        return
      end

      bot_sendMessage(get_receiver_api(msg), text, true, msg.id, 'html')
    end
  end

  --------------------------------------------------------------------------------

  return {
    description = 'Help plugin. Get info from other plugins.',
    usage = {
      '<code>!help</code>',
      'Show list of plugins.',
      '',
      '<code>!help all</code>',
      'Show all commands for every plugin.',
      '',
      '<code>!help [plugin_name]</code>',
      'Commands for that plugin.',
      '',
      '<code>!help [number]</code>',
      'Commands for that plugin. Type !help to get the plugin number.'
    },
    patterns = {
      '^!help$',
      '^!help (%g+)$',
    },
    run = run
  }

end

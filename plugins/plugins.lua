do

  -- Returns the key (index) in the config.enabled_plugins table
  local function plugin_enabled(name)
    for k,v in pairs(_config.enabled_plugins) do
      if name == v then
        return k
      end
    end
    -- If not found
    return false
  end

  -- Returns true if file exists in plugins folder
  local function plugin_exists(name)
    for k,v in pairs(plugins_names()) do
      if name .. '.lua' == v then
        return true
      end
    end
    return false
  end

  local function list_plugins(only_enabled, msg)
    local text = ''
    local psum = 0
    for k, v in pairs(plugins_names()) do
      --  ✅ enabled, ❌ disabled
      local status = '❌'
      psum = psum+1
      pact = 0
      -- Check if is enabled
      for k2, v2 in pairs(_config.enabled_plugins) do
        if v == v2 .. '.lua' then
          status = '✅'
        end
        pact = pact+1
      end
      if not only_enabled or status == '✅' then
        -- get the name
        v = v:match('(.*)%.lua')
        text = text .. status .. '  ' .. v .. '\n'
      end
    end
    local text = text .. '\n' .. psum .. '  plugins installed.\n'
        .. '✅  ' .. pact .. ' enabled.\n❌  ' .. psum-pact .. ' disabled.'
    reply_msg(msg.id, text, ok_cb, true)
  end

  local function reload_plugins(only_enabled, msg)
    plugins = {}
    load_plugins()
    return list_plugins(true, msg)
  end

--------------------------------------------------------------------------------

  local function run(msg, matches)
    local plugin = matches[2]
    local receiver = get_receiver(msg)

    if is_sudo(msg.from.peer_id) then

      -- Enable a plugin
      if not matches[3] then
        if matches[1] == 'enable' then
          print("enable: " .. plugin)
          print('checking if ' .. plugin .. ' exists')

          -- Check if plugin is enabled
          if plugin_enabled(plugin) then
            reply_msg(msg.id, 'Plugin ' .. plugin .. ' is enabled', ok_cb, true)
          end

          -- Checks if plugin exists
          if plugin_exists(plugin) then
            -- Add to the config table
            table.insert(_config.enabled_plugins, plugin)
            print(plugin .. ' added to _config table')
            save_config()
            -- Reload the plugins
            return reload_plugins(false, msg)
          else
            reply_msg(msg.id, 'Plugin ' .. plugin .. ' does not exists', ok_cb, true)
          end
        end

        -- Disable a plugin
        if matches[1] == 'disable' then
          print("disable: " .. plugin)

          -- Check if plugins exists
          if not plugin_exists(plugin) then
            reply_msg(msg.id, 'Plugin ' .. plugin .. ' does not exists', ok_cb, true)
          end

          local k = plugin_enabled(plugin)
          -- Check if plugin is enabled
          if not k then
            reply_msg(msg.id, 'Plugin ' .. plugin .. ' not enabled', ok_cb, true)
          end

          -- Disable and reload
          table.remove(_config.enabled_plugins, k)
          save_config( )
          return reload_plugins(true, msg)
        end
      end

      -- Reload all the plugins!
      if matches[1] == 'reload' then
        return reload_plugins(false, msg)
      end
    end

    if is_mod(msg, msg.to.peer_id, msg.from.peer_id) then
      -- Show the available plugins
      if matches[1] == '!plugins' then
        return list_plugins(false, msg)
      end

      -- Re-enable a plugin for this chat
      if matches[3] == 'chat' then
        if matches[1] == 'enable' then
          print('enable ' .. plugin .. ' on this chat')
          if not _config.disabled_plugin_on_chat then
            reply_msg(msg.id, "There aren't any disabled plugins", ok_cb, true)
          end

          if not _config.disabled_plugin_on_chat[receiver] then
            reply_msg(msg.id, "There aren't any disabled plugins for this chat", ok_cb, true)
          end

          if not _config.disabled_plugin_on_chat[receiver][plugin] then
            reply_msg(msg.id, 'This plugin is not disabled', ok_cb, true)
          end

          _config.disabled_plugin_on_chat[receiver][plugin] = false
          save_config()
          reply_msg(msg.id, 'Plugin ' .. plugin .. ' is enabled again', ok_cb, true)
        end

        -- Disable a plugin on a chat
        if matches[1] == 'disable' then
          print('disable ' .. plugin .. ' on this chat')
          if not plugin_exists(plugin) then
            reply_msg(msg.id, "Plugin doesn't exists", ok_cb, true)
          end

          if not _config.disabled_plugin_on_chat then
            _config.disabled_plugin_on_chat = {}
          end

          if not _config.disabled_plugin_on_chat[receiver] then
            _config.disabled_plugin_on_chat[receiver] = {}
          end

          _config.disabled_plugin_on_chat[receiver][plugin] = true
          save_config()
          reply_msg(msg.id, 'Plugin ' .. plugin .. ' disabled on this chat', ok_cb, true)
        end
      end
    end
  end

--------------------------------------------------------------------------------

  return {
    description = 'Plugin to manage other plugins. Enable, disable or reload.',
    usage = {
      sudo = {
        '<code>!plugins enable [plugin]</code>',
        'Enable plugin.',
        '',
        '<code>!plugins disable [plugin]</code>',
        'Disable plugin.',
        '',
        '<code>!plugins reload</code>',
        'Reloads all plugins.'
      },
      moderator = {
        '<code>!plugins</code>',
        'List all plugins.',
        '',
        '<code>!plugins enable [plugin] chat</code>',
        'Re-enable plugin only this chat.',
        '',
        '<code>!plugins disable [plugin] chat</code>',
        'Disable plugin only this chat.'
      },
    },
    patterns = {
      '^!plugins$',
      '^!plugins? (enable) ([%w_%.%-]+)$',
      '^!plugins? (disable) ([%w_%.%-]+)$',
      '^!plugins? (enable) ([%w_%.%-]+) (chat)$',
      '^!plugins? (disable) ([%w_%.%-]+) (chat)$',
      '^!plugins? (reload)$'
    },
    run = run
  }

end

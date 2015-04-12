do

-- Retruns the key (index) in the config.enabled_plugins table
local function plugin_enabled( name )
  for k,v in pairs(_config.enabled_plugins) do
    if name == v then
      return k
    end
  end
  -- If not found
  return false
end

-- Returns true if file exists in plugins folder
local function plugin_exists( name )
  for k,v in pairs(plugins_names()) do
    if name..'.lua' == v then
      return true
    end
  end
  return false
end

local function list_plugins(only_enabled)
  local text = ''
  for k, v in pairs( plugins_names( )) do
    --  ✔ enabled, ❌ disabled
    local status = '❌'
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        status = '✔' 
      end
    end
    if not only_enabled or status == '✔' then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      text = text..v..'  '..status..'\n'
    end
  end
  return text
end

local function reload_plugins( )
  plugins = {}
  load_plugins()
  return list_plugins(true)
end


local function enable_plugin( filename )
  -- Check if plugin is enabled
  if plugin_enabled(filename) then
    return 'Plugin '..filename..' is enabled'
  end
  -- Checks if plugin exists
  if plugin_exists(filename) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, filename)
    save_config()
    -- Reload the plugins
    return reload_plugins( )
  else
    return 'Plugin '..filename..' does not exists'
  end
end

local function disable_plugin( name, chat )
  -- Check if plugins exists
  if not plugin_exists(name) then
    return 'Plugin '..name..' does not exists'
  end
  local k = plugin_enabled(name)
  -- Check if plugin is enabled
  if not k then
    return 'Plugin '..name..' not enabled'
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end

local function disable_plugin_on_chat(receiver, plugin)
  if not plugin_exists(plugin) then
    return "Plugin doesn't exists"
  end

  if not _config.disabled_plugin_on_chat then
    _config.disabled_plugin_on_chat = {}
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    _config.disabled_plugin_on_chat[receiver] = {}
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = true

  save_config()
  return 'Plugin '..plugin..' disabled on this chat'
end

local function reenable_plugin_on_chat(receiver, plugin)
  if not _config.disabled_plugin_on_chat then
    return 'There aren\'t any disabled plugin.'
  end

  if not _config.disabled_plugin_on_chat[receiver] then
    return 'There aren\'t any disabled plugin for this chat.'
  end

  if not _config.disabled_plugin_on_chat[receiver][plugin] then
    return 'This plugin is not disabled'
  end

  _config.disabled_plugin_on_chat[receiver][plugin] = false
  return 'Plugin '..plugin..' is enabled again'
end

local function run(msg, matches)
  -- Show the available plugins 
  if matches[1] == '!plugins' then
    return list_plugins()
  end

  -- Reenable a plugin for this chat
  if matches[1] == 'enable' and matches[3] == 'chat' then
    local receiver = get_receiver(msg)
    local plugin = matches[2]
    print("enable "..plugin..' on this chat')
    return reenable_plugin_on_chat(receiver, plugin)
  end

  -- Enable a plugin
  if matches[1] == 'enable' then
    print("enable: "..matches[2])
    return enable_plugin(matches[2])
  end

  -- Disable a plugin on a chat
  if matches[1] == 'disable' and matches[3] == 'chat' then
    local plugin = matches[2]
    local receiver = get_receiver(msg)
    print("disable "..plugin..' on this chat')
    return disable_plugin_on_chat(receiver, plugin)
  end

  -- Disable a plugin
  if matches[1] == 'disable' then
    print("disable: "..matches[2])
    return disable_plugin(matches[2])
  end

  -- Reload all the plugins!
  if matches[1] == 'reload' then
    return reload_plugins(true)
  end
end

return {
  description = "Plugin to manage other plugins. Enable, disable or reload.", 
  usage = {
    "!plugins: list all plugins.", 
    "!plugins enable [plugin]: enable plugin.",
    "!plugins disable [plugin]: disable plugin.",
    "!plugins disable [plugin] chat: disable plugin only this chat.",
    "!plugins reload: reloads all plugins." },
  patterns = {
    "^!plugins$",
    "^!plugins? (enable) ([%w_%.%-]+)$",
    "^!plugins? (disable) ([%w_%.%-]+)$",
    "^!plugins? (disable) ([%w_%.%-]+) (chat)",
    "^!plugins? (enable) ([%w_%.%-]+) (chat)",
    "^!plugins? (reload)$" }, 
  run = run,
  privileged = true
}

end
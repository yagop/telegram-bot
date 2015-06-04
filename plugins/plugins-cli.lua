do

----------------------------------
----> start tg-cli interface <----
----------------------------------

local cli_output_columns = 3 -- Maximum: 6 // Minimum: 1

-- Returns the key (index) in the config.enabled_plugins table
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

-- local function disable_plugin_on_chat(receiver, plugin)
  -- if not plugin_exists(plugin) then
    -- return "Plugin doesn't exists"
  -- end

  -- if not _config.disabled_plugin_on_chat then
    -- _config.disabled_plugin_on_chat = {}
  -- end

  -- if not _config.disabled_plugin_on_chat[receiver] then
    -- _config.disabled_plugin_on_chat[receiver] = {}
  -- end

  -- _config.disabled_plugin_on_chat[receiver][plugin] = true

  -- save_config()
  -- return 'Plugin '..plugin..' disabled on this chat'
-- end

-- local function reenable_plugin_on_chat(receiver, plugin)
  -- if not _config.disabled_plugin_on_chat then
    -- return 'There aren\'t any disabled plugins'
  -- end

  -- if not _config.disabled_plugin_on_chat[receiver] then
    -- return 'There aren\'t any disabled plugins for this chat'
  -- end

  -- if not _config.disabled_plugin_on_chat[receiver][plugin] then
    -- return 'This plugin is not disabled'
  -- end

  -- _config.disabled_plugin_on_chat[receiver][plugin] = false
  -- save_config()
  -- return 'Plugin '..plugin..' is enabled again'
-- end

local function list_plugins(only_enabled)
  local color = ""
  local columns = cli_output_columns
  local columns_pattern = ""
  local pluginList = {}
  for i = 1,columns,1 do columns_pattern = columns_pattern .. "%-30s" end
  for k, v in pairs(plugins_names()) do
    --  ✔ enabled, ❌ disabled
    local isEnabled = false
    -- Check if is enabled
    for k2, v2 in pairs(_config.enabled_plugins) do
      if v == v2..'.lua' then 
        isEnabled = true
      end
    end
    if not only_enabled or isEnabled == true then
      -- get the name
      v = string.match (v, "(.*)%.lua")
      if isEnabled then color = '\27['.."92m" else color = '\27['.."91m" end
      table.insert(pluginList, color..' '..v..'\27['.."0m")
    end
  end
  local lastPrinted = #pluginList
  for i = #pluginList,columns,columns * (-1) do
    print(string.format(columns_pattern, pluginList[i], pluginList[i-1], pluginList[i-2],
    pluginList[i-3], pluginList[i-4], pluginList[i-5], pluginList[i-6], pluginList[i-6]))
    lastPrinted = i - (columns - 1)
  end
  for i = lastPrinted - 1,1,-1 do
    print(string.format("%-30s", pluginList[i]))
    lastPrinted = pluginList[i]
  end
end

local function reload_plugins()
  plugins = {}
  load_plugins()
  return list_plugins(true)
end

local function enable_plugin( plugin_name )
  if plugin_enabled(plugin_name) then
    print('Plugin \27[95m'..plugin_name..'\27[0m is already enabled')
    return
  end
  -- Checks if plugin exists
  if plugin_exists(plugin_name) then
    -- Add to the config table
    table.insert(_config.enabled_plugins, plugin_name)
    print('\27[92m'..plugin_name..'\27[0m added to _config table')
    save_config()
    -- Reload the plugins
    return reload_plugins( )
  else
    print('Plugin \27[91m'..plugin_name..'\27[0m does not exist')
    return
  end
end

local function disable_plugin(plugin_name)
  -- Check if plugins exists
  if not plugin_exists(plugin_name) then
    print('Plugin \27[91m'..plugin_name..'\27[0m does not exist')
    return
  end
  local k = plugin_enabled(plugin_name)
  -- Check if plugin is enabled
  if not k then
    print('Plugin \27[95m'..plugin_name..'\27[0m is not enabled')
    return
  end
  -- Disable and reload
  table.remove(_config.enabled_plugins, k)
  save_config( )
  return reload_plugins(true)    
end

local function cli_plugins(cb_arg, action)
  if action:lower() == "list" then
    list_plugins()
  elseif action:lower() == "reload" then
    reload_plugins(true)
  else
    print("Arg #1 should be \"list\" or \"reload\".")
  end
end

local function cli_plugin(cb_arg, action, pluginName)
  if action:lower() == "enable" then
    enable_plugin(pluginName)
  elseif action:lower() == "disable" then
    disable_plugin(pluginName)
  else
    print("Arg #1 should be \"enable\" or \"disable\".")
  end
end

local function run_cli()
  register_interface_function("plugins", cli_plugins, false, '\27[94m'.."plugins <list|reload>     List lua plugins"..'\27[33m', "string")
  register_interface_function("plugin", cli_plugin, false, '\27[94m'.."plugin <enable|disable> <plugin-name>     Enables/Disables the plugin."..'\27[33m', "string", "string")
end



if not _config then
  print("It seems this script is not being executed from telegram-bot")
else
  if os.time() < now + 5 then -- Check if the bot started at least 5 seconds ago. Prevents duplication of commands in tg-cli terminal if this plugin gets reloaded.
    local cli = run_cli()
    loaded = true
  end
end


----------------------------------
---->  end tg-cli interface  <----
----------------------------------

local function run(msg, matches)
  if matches[1]:lower() == "set col" then
    if matches[2] ~= nil then
      if tonumber(matches[2]) >= 1 and tonumber(matches[2]) <= 6 then
        cli_output_columns = tonumber(matches[2])
        return "cli_output_columns = " .. cli_output_columns
      else
        return "Error: the number should be between 1 and 6"
      end
    else
      return "Error: Provide one more value"
    end
  end
end

return {
  description = "Plugin to manage other plugins. Enable, disable or reload.", 
  usage = {
    "!plug-cli set col [n]: set number of columns."
  },
  patterns = {
    "^!plug[-]cli (set col) (%d)$",
  },
  run = run,
  privileged = true,
  onLoad = run_cli, -- Does nothing, but it might be useful... sometime.... ;)
  reloadOnReladPlugins = false -- It would be interesting if this plugin was not reloaded: If reloaded, commands in tg-cli terminal duplicate.
}

end

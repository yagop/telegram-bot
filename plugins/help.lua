do
 
function pairsByKeys(t, f)
      local a = {}
      for n in pairs(t) do table.insert(a, n) end
      table.sort(a, f)
      local i = 0      -- iterator variable
      local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
      end
      return iter
    end
 
-- Returns true if is not empty
local function has_usage_data(dict)
  if (dict.usage == nil or dict.usage == '') then
    return false
  end
  return true
end
 
-- Get commands for that plugin
local function plugin_help(name,number)
  local plugin = ""
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
 
    local text = ""
    if (type(plugin.usage) == "table") then
      for ku,usage in pairs(plugin.usage) do
        text = text..usage..'\n'
      end
      text = text..'======================\n'
    elseif has_usage_data(plugin) then -- Is not empty
      text = text..plugin.usage..'\n======================\n'
    end
    return text
end
 
 
-- !help command
local function telegram_help()
  local i = 0
  local text = "Plugins list:\n\n"
  -- Plugins names
  for name in pairsByKeys(plugins) do
    if plugins[name].hidden then
      name = nil
    else
    i = i + 1
    text = text..i..'. '..name..'\n'
    end
  end
  text = text..'\n'..'There are '..i..' plugins enabled.'
  text = text..'\n'..'Write "!help [plugin name]" or "!help [plugin number]" for more info.'
  text = text..'\n'..'Or "!help all" to show all info.'
  return text
end
 
 
-- !help all command
local function help_all()
  local ret = ""
  for name in pairsByKeys(plugins) do
    if plugins[name].hidden then
      name = nil
    else
      ret = ret .. plugin_help(name)
    end
  end
  return ret
end
 
local function run(msg, matches)
  if matches[1] == "!help" then
    return telegram_help()
  elseif matches[1] == "!help all" then
    return help_all()
  else
 
    local text = ""
    if tonumber(matches[1])  then
      text = plugin_help(nil,matches[1])
    else
      text = plugin_help(matches[1])
    end
    if not text then
      text = telegram_help()
    end
    return text
  end
end
 
return {
  description = "Help plugin. Get info from other plugins.  ",
  usage = {
    "!help: Show list of plugins.",
    "!help all: Show all commands for every plugin.",
    "!help [plugin name]: Commands for that plugin.",
    "!help [number]: Commands for that plugin. Type !help to get the plugin number."
  },
  patterns = {
    "^!help$",
    "^!help all",
    "^!help (.+)"
  },
  run = run
}
 
end

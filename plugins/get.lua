local _file_values = './data/values.lua'

function read_file_values( )
  local f = io.open(_file_values, "r+")
  -- If file doesn't exists
  if f == nil then
    -- Create a new empty table
    print ('Created value file '.._file_values)
    serialize_to_file({}, _file_values)
  else
    print ('Values loaded: '.._file_values)
    f:close() 
  end
  return loadfile (_file_values)()
end

_values = read_file_values()

function fetch_value(chat, value_name)
  -- Chat non exists
  if _values[chat] == nil then
    return nil
  end

  if value_name == nil then
    return nil
  end 

  local value = _values[chat][value_name]
  return value
end

function get_value(chat, value_name)

  -- If chat values is empty
  if (_values[chat] == nil) then
    return "There isn't any data"
  end

  -- If there is not value name, return all the values.
  if (value_name == nil ) then
    local text = ""
    for key,value in pairs(_values[chat]) do
      text = text..key.." = "..value.."\n"
    end
    return text
  end 
  local value = _values[chat][value_name]
  if ( value == nil) then
    return "Can't find "..value_name
  end
  return value_name.." = "..value
end

function run(msg, matches)
  local chat_id = tostring(msg.to.id)
  if matches[1] == "!get" then
    return get_value(chat_id, nil)
  end  
   return get_value(chat_id, matches[1])
end

function lex(msg)

  if msg.text then
    local text = msg.text
    local chat_id = tostring(msg.to.id)
    local s, e = text:find("%$%a+")

    if s then
      local var = text:sub(s + 1, e)
      local value = fetch_value(chat_id, var)
      
      if (value == nil) then
        value = "(unknown value " .. var .. ")"
      end

      msg.text = text:sub(0, s - 1) .. value .. text:sub(e + 1)
    end
  end

  return msg
end

return {
    description = "Retrieves variables saved with !set", 
    usage = "!get (value_name): Returns the value_name value.",
    patterns = {
      "^!get (%a+)$",
      "^!get$"},
    run = run,
    pre_process = lex
}


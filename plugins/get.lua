local f = io.open('./res/values.json', "r+")
if f == nil then
  f = io.open('./res/values.json', "w+")
  f:write("{}") -- Write empty table
  f:close()
  _values = {}
else
  local c = f:read "*a"
  f:close()
  _values = json:decode(c)
end

function get_value( value_name )
  -- If there is not value name, return all the values.
  if (value_name == nil ) then
    local text = ""
    for key,value in pairs(_values) do
      text = text..key.." = "..value.."\n"
    end
    return text
  end 
  local value = _values[value_name]
  if ( value == nil) then
    return "Can't find "..value_name
  end
  return value_name.." = "..value
end

function run(msg, matches)
  if matches[1] == "!get" then
    return get_value(nil)
  end  
   return get_value(matches[1])
end

return {
    description = "retrieves variables saved with !set", 
    usage = "!get (value_name)",
    patterns = {
      "^!get (%a+)$",
      "^!get$"}, 
    run = run 
}

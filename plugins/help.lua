-- Generate an HTML table for GitHub
function html_help()
  local text = [[<table>
    <thead>
      <tr>
        <td><strong>Name</strong></td>
        <td><strong>Description</strong></td>
        <td><strong>Usage</strong></td>
      </tr>
    </thead>
    <tbody>]]

  for k,v in pairs(plugins_names()) do
    t = loadfile("plugins/"..v)()
    text = text.."<tr>"
    text = text.."<td>"..v.."</td>"
    text = text.."<td>"..t.description.."</td>"
    text = text.."<td>"
    if (type(t.usage) == "table") then
      for ku,vu in pairs(t.usage) do
        text = text..vu.."<br>"
      end
    else
      text = text..t.usage
    end
    text = text.."</td>"
    text = text.."</tr>"
  end
  text = text.."</tbody></table>"
  return text
end

function has_usage_data(dict)
  if (dict.usage == nil or dict.usage == '') then
    return false
  end
  return true
end

function telegram_help( )
  local ret = ""
  for k, dict in pairs(plugins) do
    if (type(dict.usage) == "table") then
      for ku,usage in pairs(dict.usage) do
        ret = ret..usage..'\n'
      end
      ret = ret..'\n'
    elseif has_usage_data(dict) then -- Is not empty
      ret = ret..dict.usage..'\n\n'
    end
  end
  return ret
end

function run(msg, matches)
  if matches[1] == "!help md" then
    return html_help()
  else
    return telegram_help()
  end
end

return {
    description = "Help plugin. Get info from other plugins.  ", 
    usage = {
      "!help: Show all the help",
      "!help md: Generate a GitHub Markdown table"
    },
    patterns = {
      "^!help$",
      "^!help md$"
    }, 
    run = run 
}
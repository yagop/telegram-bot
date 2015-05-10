local sudo_required_for_wiki_set = false
local wiki_plugin_usage = {
   "!wiki [terms]: Searches wiki and send results",
   "!wiki_set [wiki]: sets the wikimedia site for this chat",
   "!wiki_get: gets the current wikimedia site"
}
local _file_wiki = './data/wikiSites.lua'
local _wikiSites = load_from_file(_file_wiki)
local _defaultWikiSite = "wikipedia.org/wiki"

local function save_value(chat, searchSite)
	if _wikiSites[chat] == nil then _wikiSites[chat] = {} end
	_wikiSites[chat] = searchSite
	serialize_to_file(_wikiSites, _file_wiki)
  return "set "..searchSite.." as search site"
end

local function fetch_value(chat)
  _wikiSites = load_from_file(_file_wiki)
  if _wikiSites[chat] == nil then
    save_value(chat, _defaultWikiSite)
    _wikiSites = load_from_file(_file_wiki)
    return _defaultWikiSite
  end
  return _wikiSites[chat]
end



local function wikiSearch(searchTerm, chat)
  local api = "http://"..fetch_value(chat)
  if string.sub(api, -1) ~= "/" then api = api.."/" end
  local parameters = (URL.escape(searchTerm) or "")
  local url = api..parameters
  local http = require("socket.http")
  local respbody = {} 
  local ltn12 = require "ltn12"
  local body, code, headers, status = http.request{
    url = url,
    method = "GET",
    --headers = headers,
    --source = ltn12.source.string(reqBody),
    redirect = true,
    sink = ltn12.sink.table(respbody)
  }
  --for key, value in pairs (headers) do
  --  print(key.."->"..value)
  --end
  
  
  local body = table.concat(respbody)
  if (status == nil) then return "ERROR: status = nil" end
  if code == 404 then return api.." does not have info about \""..searchTerm.."\"" end 
  if code ~=200 then return "ERROR: "..status end -- "ERROR: "..code..". Status: "..status
  if body == nil then return "ERROR: body = nil" end
  local location = headers.location
  local wikiContent = string.match(body, "<div id%=\"mw%-content%-text\".->(.-)<div class=\"printfooter\".->")
  if (wikiContent == nil) then return "ERROR: couldn't parse output." end -- return "ERROR: wikiContent = nil"
  wikiContent = string.gsub(wikiContent, "\n", "")
  wikiContent = string.gsub(wikiContent, "<a.->", "")
  wikiContent = string.gsub(wikiContent, "</a>", "")
  wikiContent = string.gsub(wikiContent, "<p.->(.-)</p>", "%1\n")
  wikiContent = string.gsub(wikiContent, "<b.->", "")
  wikiContent = string.gsub(wikiContent, "</b>", "")
  wikiContent = string.gsub(wikiContent, "<i.->", "")
  wikiContent = string.gsub(wikiContent, "</i>", "")
  wikiContent = string.gsub(wikiContent, "<sup.->", "")
  wikiContent = string.gsub(wikiContent, "</sup>", "")
  wikiContent = string.gsub(wikiContent, "<span.->", "")
  wikiContent = string.gsub(wikiContent, "</span>", "")
  wikiContent = string.gsub(wikiContent, "<div.->(.-)</div>", "%1\n")
  wikiContent = string.gsub(wikiContent, "[.-]", "")
  wikiContent = string.gsub(wikiContent, "<table.->.-</table>", "")
  wikiContent = string.gsub(wikiContent, "<li.->(.-)</li>", " - %1\n")
  wikiContent = string.gsub(wikiContent, "<.->", "")
  --wikiContent = string.gsub(wikiContent, "<.->.-</.->", "")
  if string.len(wikiContent) >= 500 then
     wikiContent = string.sub(wikiContent, 1, 500).." [...]"
  end
  wikiContent = wikiContent.."\nLink: "..location
  return wikiContent
end

local function parseText(chat, msg)
  local text = msg.text
  if (text == nil or text == "!wiki" or text == "!wiki_get") then
    return fetch_value(chat)
  end
  
  local value = string.match(text, "!wiki_set (.*)")
  if (value ~= nil) then
     if (is_sudo(msg) or (not sudo_required_for_wiki_set)) then
        return save_value(chat, value)
     else
        return "You do not have permission!"
     end
  end
  
  -- Search here:
  searchTerm = string.match(text, "!wiki (.*)")
  if (searchTerm == nil) then
     return wiki_plugin_usage
  end
  return wikiSearch(searchTerm, chat)
end


local function run(msg, matches)
  local chat_id = tostring(msg.to.id)
  local result = parseText(chat_id, msg)
  return result
end

return {
  description = "Searches Wikipedia and send results",
  usage = wiki_plugin_usage,
  patterns = {
    "^!wiki .*$",
    "^!wiki$",
    "^!wiki_set .*$",
    "^!wiki_get"
  },
  run = run
}

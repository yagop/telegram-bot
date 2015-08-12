--[[ NOT USED DUE TO SSL ERROR
-- See https://getstrike.net/api/
local function strike_search(query)
  local strike_base = 'http://getstrike.net/api/v2/torrents/'
  local url = strike_base..'search/?phrase='..URL.escape(query)
  print(url)
  local b,c = http.request(url)
  print(b,c)
  local search = json:decode(b)
  vardump(search)

  if c ~= 200 then 
    return search.message
  end

  vardump(search)
  local results = search.results
  local text = 'Results: '..results
  local results = math.min(results, 3)
  for i=1,results do
    local torrent = search.torrents[i]
    text = text..torrent.torrent_title
      ..'\n'..'Seeds: '..torrent.seeds
      ..' '..'Leeches: '..torrent.seeds
      ..'\n'..torrent.magnet_uri..'\n\n'
  end
  return text
end]]--

local function search_kickass(query)
  local url = 'http://kat.cr/json.php?q='..URL.escape(query)
  local b,c = http.request(url)
  local data = json:decode(b)

  local text = 'Results: '..data.total_results..'\n\n'
  local results = math.min(#data.list, 5)
  for i=1,results do
    local torrent = data.list[i]
    local link = torrent.torrentLink
    link = link:gsub('%?title=.+','')
    text = text..torrent.title
      ..'\n'..'Seeds: '..torrent.seeds
      ..' '..'Leeches: '..torrent.leechs
      ..'\n'..link
      --..'\n magnet:?xt=urn:btih:'..torrent.hash
      ..'\n\n'
  end
  return text
end

local function run(msg, matches)
  local query = matches[1]
  return search_kickass(query)
end

return {
  description = "Search Torrents",
  usage = "!torrent <search term>: Search for torrent",
  patterns = {
    "^!torrent (.+)$"
  },
  run = run
}

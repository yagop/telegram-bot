local https = require ('ssl.https')
local ltn12 = require ("ltn12")

local function search_kickass(query)
  local url = 'https://kat.cr/json.php?q='..URL.escape(query)

  local resp = {}

  local b,c = https.request
  {
    url = url,
    protocol = "tlsv1",
    sink = ltn12.sink.table(resp)
  }

  resp = table.concat(resp)

  local data = json:decode(resp)

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

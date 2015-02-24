require("./plugins/google")

function firstresult(results)
  return results[1][2]
end

function wikiapilink(wikiurl)
  local wikipattern="^http://en.wikipedia.org/wiki/(.*)$"
  local matches = { string.match(wikiurl, wikipattern) }
  local queryterm=matches[1]
  local apilink = "http://en.wikipedia.org/w/index.php?action=raw&title="..queryterm
  return apilink
end


function getwikifromapi(apilink)
  -- Do the request
  local res, code = https.request(apilink)
  if code ~=200 then return "An error occured" end
  local data = res
  local wikitext=data
  return wikitext
end

function plaintext(wikitext)
  local plaintext=string.gsub(wikitext,"{{Infobox.-\n}}\n","")
  plaintext=string.gsub(plaintext,"{{.-}}","")
  plaintext=string.gsub(plaintext,"[%[%|%]%]]","")
  plaintext=string.gsub(plaintext,"<ref.->.-</ref>","")
  local firstsectionindex=string.find(plaintext,"==")
  if firstsectionindex~=nil then
    plaintext=string.sub(plaintext,1,firstsectionindex-1)
  end
  return plaintext
end

function formatwikiforsending(wikitext,url)
  -- local stringtosend=title.."\n==="
  local stringtosend=plaintext(wikitext).."\n"
  stringtosend=stringtosend.."- "..url
  return stringtosend
end


function scrapewiki(results)
  local url=firstresult(results)
  local tosend=formatwikiforsending(getwikifromapi(wikiapilink(url)),url)
  return tosend
end

function run(msg, matches)
  vardump(matches)
  local results = googlethat(matches[1].." site:en.wikipedia.org")
  return scrapewiki(results)
end


return {
  description = "Gives you the wikipedia article you are looking for",
  usage = "!wiki terms",
  patterns = {
    "^!wiki (.*)$",
    "^%.[w|W]iki (.*)$"
    },
    run = run
  }


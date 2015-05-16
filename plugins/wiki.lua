-- http://git.io/vUA4M

local JSON = require "cjson"

local Wikipedia = {
   -- http://meta.wikimedia.org/wiki/List_of_Wikipedias
   wiki_server = "http://%s.wikipedia.org",
   wiki_path = "/w/api.php",
   wiki_params = {
       action = "query",
       prop = "extracts",
       format = "json",
       exchars = 300,
       exsectionformat = "plain",
       explaintext = "",
       redirects = ""
   },
   default_lang = "en",
}

function Wikipedia:getWikiServer(lang)
    return string.format(self.wiki_server, lang or self.default_lang)
end

--[[
--  return decoded JSON table from Wikipedia
--]]
function Wikipedia:loadPage(text, lang, intro, plain)
    local socket = require('socket')
    local url = require('socket.url')
    local http = require('socket.http')
    local https = require('ssl.https')
    local ltn12 = require('ltn12')

    local request, sink = {}, {}
    local query = ""

    self.wiki_params.explaintext = plain and "" or nil
    for k,v in pairs(self.wiki_params) do
        query = query .. k .. '=' .. v .. '&'
    end
    local parsed = url.parse(self:getWikiServer(lang))
    parsed.path = self.wiki_path
    parsed.query = query .. "titles=" .. url.escape(text)

    -- HTTP request
    request['url'] = url.build(parsed)
    print(request['url'])
    request['method'] = 'GET'
    request['sink'] = ltn12.sink.table(sink)
    http.TIMEOUT, https.TIMEOUT = 10, 10
    local httpRequest = parsed.scheme == 'http' and http.request or https.request
    local code, headers, status = socket.skip(1, httpRequest(request))

    if not headers or not sink then
        return nil
    end

    local content = table.concat(sink)
    if content ~= "" then
        local ok, result = pcall(JSON.decode, content)
        if ok and result then
            return result
        else
            return nil
        end
    else 
        return nil
    end
end

-- extract intro passage in wiki page
function Wikipedia:wikintro(text, lang)
    local result = self:loadPage(text, lang, true, true)

    vardump(result)

    if result and result.query then

        local query = result.query
        if query and query.normalized then
            text = query.normalized[1].to or text
        end

        local page = query.pages[next(query.pages)]

        if page and page.extract then
            return text..": "..page.extract
        else
            return "Extract not found for "..text
        end
    else
        return "Sorry an error happened"
    end
end


local function run(msg, matches)
    -- TODO: Remember language (i18 on future version)
    -- TODO: Support for non Wikipedias but Mediawikis
    local term = matches[2]
    local lang = matches[1] -- Can be nil
    if not term then
        term = lang
        lang = nil
    end
    -- TODO: Show the link
    local result = Wikipedia:wikintro(term, lang)
    return result
end

return {
    description = "Searches Wikipedia and send results",
    usage = {
        "!wiki [text]: Search on default Wikipedia (EN)",
        "!wiki(lang) [text]: Search on 'lang' wikipedia. Example: !wikies hola.",
    },
    patterns = {
        "^!wiki (.*)$",
        "^!wiki(%w+) (.*)$",
    },
    run = run
}
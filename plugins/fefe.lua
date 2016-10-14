local function getpost(id)
    local base_url = "http://blog.fefe.de/?ts="
    local res, code = http.request(base_url .. id)
    print('HTTP: ' .. base_url .. id)
    print(code)
    if code ~=200 then return nil  end
    return res
end

local function extracttext(results)
    if results == nil then
        return "Error :-("
    end
    -- match line containing text
    local line = string.sub( results, string.find(results, "<li><a href[^\n]+"))
    local text = line:gsub("<div style=.+", "")
    -- remove link at begin
    text = text:gsub("<li><a href=\"%?ts=%w%w%w%w%w%w%w%w\">%[l]</a>", "")
    -- replace "<p>" with newline; "<b>" and "</b>" with "*"
    text = text:gsub("<p>", "\n\n"):gsub("<p u>", "\n\n")
    text = text:gsub("<b>", "*"):gsub("</b>", "*")
    -- format quotes and links markdown-like
    text = text:gsub("<a href=\"", "("):gsub("\">", ")["):gsub("</a>", "]")
    text = text:gsub("<blockquote>", "\n\n> "):gsub("</blockquote>", "\n\n")
    return text
end

local function run(msg, matches)
    local results = getpost(matches[1])
    return extracttext(results)
end

return {
    description = "Sends blog.fefe.de post",
    usage = "!fefe [url|id]: sends blog.fefe.de post",
    patterns = {
        "^!fefe http://blog%.fefe%.de/%?ts=(%w%w%w%w%w%w%w%w)$",
        "^!fefe https://blog%.fefe%.de/%?ts=(%w%w%w%w%w%w%w%w)$",
        "^!fefe (%w%w%w%w%w%w%w%w)$"
    },
    run = run
}

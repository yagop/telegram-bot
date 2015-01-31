 
function traffic()
    local http = require("socket.http")
    http.TIMEOUT = 5
 
    r, c, h = http.request("http://cetsp1.cetsp.com.br/monitransmapa/agora/")
 
    if c ~= 200 then
        return nil
    end
 
    for str in r:gmatch("[^\r\n]+") do
        if str:find('id=\"hora\"') then
            h = str:gsub('<[^<>]*>', ''):gsub('%s', '')
        elseif str:find('id=\"lentidao\"') then
            l = str:gsub('<[^<>]*>', ''):gsub('%s', '')
        end
    end
    return l.." km de trânsito em São Paulo, atualizado as "..h
end
 
function run(msg, matches)
    return traffic()
end
 
return {
    description = "Shows São Paulo traffic information.",
    usage = "!transito",
    patterns = {"^!transito$"},
    run = run
}

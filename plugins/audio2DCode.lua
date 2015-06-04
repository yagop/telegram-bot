local MashapeKey = "KEY"

local function request(action,text)
    local api = ""
    local reqbody = ""
    if action == "encrypt" then
        api = "https://zhulianxing-audio-2d-code.p.mashape.com/upload.php"
        reqbody = "dataContent="..(URL.escape(text) or "")
    elseif action == "decrypt" then
        api = "https://zhulianxing-audio-2d-code.p.mashape.com/download.php"
        reqbody = "dataToken="..(URL.escape(text) or "")
    elseif action == "wave" then
        api = "https://zhulianxing-audio-2d-code.p.mashape.com/getwave.php"
        reqbody = "dataToken="..(URL.escape(text) or "")
    else
        return "Error"
    end
    local url = api
    local https = require("ssl.https")
    local respbody = {}
    local ltn12 = require "ltn12"
    local headers = {
        ["X-Mashape-Key"] = MashapeKey,
        ["Accept"] = "text/plain",
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Content-Length"] = string.len(reqbody)
    }
    print(url)
    local body, code, headers, status = https.request{
        url = url,
        method = "POST",
        headers = headers,
        sink = ltn12.sink.table(respbody),
        protocol = "tlsv1",
        source = ltn12.source.string(reqbody)
    }
    if code ~= 200 then return nil end
    local body = table.concat(respbody)
    return body
end

local function audioCallback(receiver, status)
    if status == 0 then
        send_large_msg(receiver, "There was an error. We couldn't send you the audio wave.")
    end
end

local function run(msg, matches)
    if matches[1]:lower() == "!enc2d" and matches[2] ~= nil then --encript
        return request("encrypt", matches[2])
    elseif matches[1]:lower() == "!enc2w" and matches[2] ~= nil then --encript
        if string.len(matches[2]) > 14 and string.len(matches[2]) < 18 then
           local waveUrl = request("wave", matches[2])
           if waveUrl ~= nil then
               local audioPath = download_to_file(waveUrl, false)
               send_audio(get_receiver(msg), audioPath, audioCallback, get_receiver(msg))
           end
        end
    else --decript
        if string.len(matches[1]) > 14 and string.len(matches[1]) < 18 then
            return request("decrypt", matches[1])
        end
    end
end

return {
    description = "Use Audio 2D Code",
    usage = {
        "!enc2d [text]: get code",
        "!enc2w [code]: get audio wave",
        "code: get text",
    },
    patterns = {
        "^(!enc2[d|D]) (.*)$",
        "^(!enc2[w|W]) (.*)$",
        "^(%w+)$"
    },
    run = run
}
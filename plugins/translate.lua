
--[[
-- Translate text using Yandex.com
-- https://translate.yandex.net/api/v1.5/tr.json/detect?key=APIkey&text=Hello+world
--~ https://translate.yandex.net/api/v1.5/tr/translate?key=APIkey&lang=en-ru&text=To+be,+or+not+to+be%3F&text=That+is+the+question.
--]]
do
function translate(source_lang, target_lang, text)
print(text)

  local path = "https://translate.yandex.net/api/v1.5/tr.json/translate"
  if api then
    local i = math.random(#api)
    api_key = api[i]
  else
    config = load_from_file('data/config.lua')
    for i=1,#config.sudo_users do
        send_msg("user#id"..config.sudo_users[i], "Valid API key is not provided in data/translate_api.lua\nGet an API key from https://tech.yandex.com/keys/get/?service=trnsl")
    end
    return "Valid API key is not provided. Contact owner."  
  end
  if not target_lang then target_lang = 'en' end
  -- URL query parameters
  local params = {
    lang = source_lang.."-"..target_lang,
    text = URL.escape(text),
  }
  local query = format_http_params(params, true)
  url = path..query.."&key="..api_key
vardump(url)
  local res, code = https.request(url)
  -- Return nil if error
  if code > 200 then
    message = "HTTP error code "..code
    if warning_lang then message = message.." and warning_lang true" end
  end
  
  local trans = json:decode(res)
  
  local sentences = ""
  -- Join multiple sentences
  --~ for k,sentence in pairs(trans.sentences) do
  --~ vardump(inpairs(trans))
  vardump(trans)
  vardump(res)
  for i=1,#trans.text do
    sentences = sentences..trans.text[i]..'\n'
  end

  return sentences
end
    --~ Auto detect language
function detect_language (text, target)
  target = target or 'en'
  url = "https://translate.yandex.net/api/v1.5/tr.json/detect?text="..URL.escape(text)
  if api then
    local i = math.random(#api)
    local api_key = api[i]
    if api_key then
      url = url.."&key="..api_key
    end
  else return "Valid API key is not provided in data/translate_api.lua"  
  end
  local res, code = https.request(url)
  local trans = json:decode(res)
  if code == 200 and trans.code == 200 then 
    return translate(trans.lang,target,text)
  else
    print( "ERROR: return code"..code..":"..trans.code)
    return nil
  end
end

function run(msg, matches)
  API_TRANS = load_from_file('data/translate_api.lua')
  api = API_TRANS
  --~ Get an api from https://tech.yandex.com/keys/get/?service=trnsl
  if api then
      -- Third pattern
      vardump(matches)
      if #matches == 1 then
        print("First")
        vardump(api)
        local text = matches[1]
        return detect_language(text)
      end
    
      -- Second pattern
      if #matches == 2 then
        if string.len(matches[1]) == 2 then
            warning_lang = true
            print("Second")
            local target = matches[1]
            local text = matches[2]
            return detect_language(text,target)
        else
            local text = matches[1]..matches[2]
            return detect_language(text)
        end
      end
      -- First pattern
      if #matches == 3 then
            print("Third")
            local source = matches[1]
            local target = matches[2]
            local text = matches[3]
            return translate(source, target, text)
      end
    end
end

return {
  description = "Translate some text", 
  usage = {
    "!translate text. Translate the text to English.",
    "!translate target_lang text.",
    "!translate source,target text",
  },
  patterns = {
    "^!translate ([%w]+),([%a]+) (.+)",
    "^!translate ([%w]+) (.+)",
    "^!translate (.+)",
  }, 
  run = run 
}

end

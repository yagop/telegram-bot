local helpers = require "OAuth.helpers"

local _file_memes = './data/memes.lua'
local _cache = {}

local function post_petition(url, arguments)
   local response_body = {}
   local request_constructor = {
      url = url,
      method = "POST",
      sink = ltn12.sink.table(response_body),
      headers = {},
      redirect = false
   }

   local source = arguments
   if type(arguments) == "table" then
      local source = helpers.url_encode_arguments(arguments)
   end
   request_constructor.headers["Content-Type"] = "application/x-www-form-urlencoded"
   request_constructor.headers["Content-Length"] = tostring(#source)
   request_constructor.source = ltn12.source.string(source)

   local ok, response_code, response_headers, response_status_line = http.request(request_constructor)

   if not ok then
      return nil
   end

   response_body = json:decode(table.concat(response_body))

   return response_body
end

local function upload_memes(memes)
   local base = "http://hastebin.com/"
   local pet = post_petition(base .. "documents", memes)
   if pet == nil then
      return '', ''
   end
   local key = pet.key
   return base .. key, base .. 'raw/' .. key
end

local function analyze_meme_list()
   local function get_m(res, n)
      local r = "<option.*>(.*)</option>.*"
      local start = string.find(res, "<option.*>", n)
      if start == nil then
         return nil, nil
      end
      local final = string.find(res, "</option>", n) + #"</option>"
      local sub = string.sub(res, start, final)
      local f = string.match(sub, r)
      return f, final
   end
   local res, code = http.request('http://apimeme.com/')
   local r = "<option.*>(.*)</option>.*"
   local n = 0
   local f, n = get_m(res, n)
   local ult = {}
   while f ~= nil do
      print(f)
      table.insert(ult, f)
      f, n = get_m(res, n)
   end
   return ult
end


local function get_memes()
   local memes = analyze_meme_list()
   return {
      last_time = os.time(),
      memes = memes
   }
end

local function load_data()
   local data = load_from_file(_file_memes)
   if not next(data) or data.memes == {}  or os.time() - data.last_time > 86400  then
      data = get_memes()
      -- Upload only if changed?
      link, rawlink = upload_memes(table.concat(data.memes, '\n'))
      data.link = link
      data.rawlink = rawlink
      serialize_to_file(data, _file_memes)
   end
   return data
end

local function match_n_word(list1, list2)
   local n = 0
   for k,v in pairs(list1) do
      for k2, v2 in pairs(list2) do
         if v2:find(v) then
            n = n + 1
         end
      end
   end
   return n
end

local function match_meme(name)
   local _memes = load_data()
   local name = name:lower():split(' ')
   local max = 0
   local id = nil
   for k,v in pairs(_memes.memes) do
      local n = match_n_word(name, v:lower():split(' '))
      if n > 0 and n > max then
         max = n
         id = v
      end
   end
   return id
end

local function generate_meme(id, textup, textdown)
   local base = "http://apimeme.com/meme"
   local arguments = {
      meme=id,
      top=textup,
      bottom=textdown
   }
   return base .. "?" .. helpers.url_encode_arguments(arguments)
end

local function get_all_memes_names()
   local _memes = load_data()
   local text = 'Last time: ' .. _memes.last_time .. '\n-----------\n'
   for k, v in pairs(_memes.memes) do
      text = text .. '- ' .. v .. '\n'
   end
   text = text .. '--------------\n' .. 'You can see the images here: http://apimeme.com/'
   return text
end

local function callback_send(cb_extra, success, data)
   if success == 0 then
      send_msg(cb_extra.receiver, "Something wrong happened, probably that meme had been removed from server: " .. cb_extra.url, ok_cb, false)
   end
end

local function run(msg, matches)
   local receiver = get_receiver(msg)
   if matches[1] == 'list' then
      local _memes = load_data()
      return 'I have ' .. #_memes.memes .. ' meme names.\nCheck this link to see all :)\n' .. _memes.link
   elseif matches[1] == 'listall' then
      if not is_sudo(msg) then
         return "You can't list this way, use \"!meme list\""
      else
         return get_all_memes_names()
      end
   elseif matches[1] == "search" then
      local meme_id = match_meme(matches[2])
      if meme_id == nil then
         return "I can't match that search with any meme."
      end
      return "With that search your meme is " .. meme_id
   end
   local searchterm = string.gsub(matches[1]:lower(), ' ', '')

   local meme_id = _cache[searchterm] or match_meme(matches[1])
   if not meme_id then
      return 'I don\'t understand the meme name "' .. matches[1] .. '"'
   end

   _cache[searchterm] = meme_id
   print("Generating meme: " .. meme_id .. " with texts " ..  matches[2] .. ' and ' .. matches[3])
   local url_gen = generate_meme(meme_id, matches[2], matches[3])
   send_photo_from_url(receiver, url_gen, callback_send, {receiver=receiver, url=url_gen})

   return nil
end

return {
   description = "Generate a meme image with up and bottom texts.",
   usage = {
      "!meme search (name): Return the name of the meme that match.",
      "!meme list: Return the link where you can see the memes.",
      "!meme listall: Return the list of all memes. Only admin can call it.",
      '!meme [name] - [text_up] - [text_down]: Generate a meme with the picture that match with that name with the texts provided.',
      '!meme [name] "[text_up]" "[text_down]": Generate a meme with the picture that match with that name with the texts provided.',
   },
   patterns = {
      "^!meme (search) (.+)$",
      '^!meme (list)$',
      '^!meme (listall)$',
      '^!meme (.+) "(.*)" "(.*)"$',
      '^!meme "(.+)" "(.*)" "(.*)"$',
      "^!meme (.+) %- (.*) %- (.*)$"
   },
   run = run
}

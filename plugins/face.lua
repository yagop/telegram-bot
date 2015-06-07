local function request(imageUrl)
   local api = "https://faceplusplus-faceplusplus.p.mashape.com/detection/detect?"
   local parameters = "attribute=gender%2Cage%2Crace"
   parameters = parameters .. "&url="..(URL.escape(imageUrl) or "")
   local url = api..parameters
   local https = require("ssl.https")
   local respbody = {}
   local ltn12 = require "ltn12"
   local headers = {
      ["X-Mashape-Key"] = "5j2cydo37tmshgTnssARJN6VuGqkp1ggaTojsnP2fharkD2Uir",
      ["Accept"] = "Accept: application/json"
   }
   print(url)
   local body, code, headers, status = https.request{
      url = url,
      method = "GET",
      headers = headers,
      sink = ltn12.sink.table(respbody),
      protocol = "tlsv1"
   }
   if code ~= 200 then return "", code end
   local body = table.concat(respbody)
   return body, code
end

local function parseData(data)
   local jsonBody = json:decode(data)
   local response = ""
   if jsonBody.error ~= nil then
      if jsonBody.error == "IMAGE_ERROR_FILE_TOO_LARGE" then
         response = response .. "The image is too big. Provide a smaller image."
      elseif jsonBody.error == "IMAGE_ERROR_FAILED_TO_DOWNLOAD" then
         response = response .. "Is that a valid url for an image?"
      else
         response = response .. jsonBody.error
      end
   elseif jsonBody.face == nil or #jsonBody.face == 0 then
      response = response .. "No faces found"
   else
      response = response .. #jsonBody.face .." face(s) found:\n\n"
      for k,face in pairs(jsonBody.face) do
         local raceP = ""
         if face.attribute.race.confidence > 85.0 then
            raceP = face.attribute.race.value:lower()
         elseif face.attribute.race.confidence > 50.0 then
            raceP = "(probably "..face.attribute.race.value:lower()..")"
         else
            raceP = "(posibly "..face.attribute.race.value:lower()..")"
         end
         if face.attribute.gender.confidence > 85.0 then
            response = response .. "There is a "
         else
            response = response .. "There may be a "
         end
         response = response .. raceP .. " " .. face.attribute.gender.value:lower() .. " "
         response = response .. ", " .. face.attribute.age.value .. "(±".. face.attribute.age.range ..") years old \n"
      end
   end
   return response
end

local function run(msg, matches)
   --return request('http://www.uni-regensburg.de/Fakultaeten/phil_Fak_II/Psychologie/Psy_II/beautycheck/english/durchschnittsgesichter/m(01-32)_gr.jpg')
   local data, code = request(matches[1])
   if code ~= 200 then return "There was an error. #"..code end
   return parseData(data)
end

return {
   description = "Who is in that photo?",
   usage = {
      "!face [url]",
      "!recognise [url]"
   },
   patterns = {
      "^!face (.*)$",
      "^!recognise (.*)$"
   },
   run = run
}

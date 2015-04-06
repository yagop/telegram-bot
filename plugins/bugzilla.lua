do

local BASE_URL = "https://bugzilla.mozilla.org/rest/"

function bugzilla_login()
  local url = BASE_URL.."login?login=" .. _config.bugzilla.username .. "&password=" .. _config.bugzilla.password
  print("accessing " .. url)
  local res,code  = https.request( url )
  data = json:decode(res)
  return data
end

function bugzilla_check(id)
  -- data = bugzilla_login()
  vardump(data)
  local url = BASE_URL.."bug/" .. id .. "?api_key=" .. _config.bugzilla.apikey
  -- print(url)
  local res,code  = https.request( url )
  data = json:decode(res)
  return data
end

function bugzilla_listopened(email)
  local url = BASE_URL.."bug?include_fields=id,summary,status,whiteboard,resolution&email1=" .. email .. "&email2=" .. email .. "&emailassigned_to2=1&emailreporter1=1&emailtype1=substring&emailtype2=substring&f1=bug_status&f2=bug_status&n1=1&n2=1&o1=equals&o2=equals&resolution=---&v1=closed&v2=resolved&api_key=" .. _config.bugzilla.apikey
  local res,code  = https.request( url )
  print(res)
  local data = json:decode(res)
  return data
end

function run(msg, matches)

  local response = ""

  if matches[1] == "status" then
    data = bugzilla_check(matches[2])
    vardump(data)
    if data.error == true then
      return "Sorry, API failed with message: " .. data.message
    else
      response = "Bug #"..matches[1]..":\nReporter: "..data.bugs[1].creator
      response = response .. "\n Last update: "..data.bugs[1].last_change_time
      response = response .. "\n Status: "..data.bugs[1].status.." "..data.bugs[1].resolution
       response = response .. "\n Whiteboard: "..data.bugs[1].whiteboard
       response = response .. "\n Access: https://bugzilla.mozilla.org/show_bug.cgi?id=" .. matches[1]
       print(response)
    end
  elseif matches[1] == "list" then
    data = bugzilla_listopened(matches[2])

      vardump(data)
      if data.error == true then
        return "Sorry, API failed with message: " .. data.message
      else

        -- response = "Bug #"..matches[1]..":\nReporter: "..data.bugs[1].creator
        -- response = response .. "\n Last update: "..data.bugs[1].last_change_time
        -- response = response .. "\n Status: "..data.bugs[1].status.." "..data.bugs[1].resolution
        -- response = response .. "\n Whiteboard: "..data.bugs[1].whiteboard
        -- response = response .. "\n Access: https://bugzilla.mozilla.org/show_bug.cgi?id=" .. matches[1]
        local total = table.map_length(data.bugs)
        
        print("total bugs: " .. total)
        response = "There are " .. total .. " number of bug(s) assigned/reported by " .. matches[2]

        if total > 0 then
          response = response .. ": "

          for tableKey, bug in pairs(data.bugs) do
            response = response .. "\n #" .. bug.id
            response = response .. "\n   Status: " .. bug.status .. " " .. bug.resolution
            response = response .. "\n   Whiteboard: " .. bug.whiteboard
            response = response .. "\n   Summary: " .. bug.summary
          end
        end
      end

  end
  return response
end

-- (table)
--   [bugs] = (table)
--     [1] = (table)
--       [status] = (string) ASSIGNED
--       [id] = (number) 927704
--       [whiteboard] = (string) [approved][full processed]
--       [summary] = (string) Budget Request - Arief Bayu Purwanto - https://reps.mozilla.org/e/mozilla-summit-2013/
--     [2] = (table)
--       [status] = (string) ASSIGNED
--       [id] = (number) 1049337
--       [whiteboard] = (string) [approved][full processed][waiting receipts][waiting report and photos]
--       [summary] = (string) Budget Request - Arief Bayu Purwanto - https://reps.mozilla.org/e/workshop-firefox-os-pada-workshop-media-sosial-untuk-perubahan-1/
-- total bugs: 2

return {
  description = "Lookup bugzilla status update", 
  usage = "/bot bugzilla [bug number]",
  patterns = {
    "^/bugzilla (status) (.*)$",
    "^/bugzilla (list) (.*)$"
  }, 
  run = run 
}

end
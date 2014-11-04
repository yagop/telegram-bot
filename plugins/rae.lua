
function getDulcinea( text )
  -- Powered by https://github.com/javierhonduco/dulcinea
  local api = "http://dulcinea.herokuapp.com/api/?query="
  b = http.request(api..text)
  dulcinea = json:decode(b)
  if dulcinea.status == "error" then
    return "Error: " .. dulcinea.message
  end
  while dulcinea.type == "multiple" do
    text = dulcinea.response[1].id
    b = http.request(api..text)
    dulcinea = json:decode(b)
  end
  vardump(dulcinea)
  local text = ""
  local responses = #dulcinea.response
  if (responses > 5) then
    responses = 5
  end
  for i = 1, responses, 1 do 
    text = text .. dulcinea.response[i].word .. "\n"
    local meanings = #dulcinea.response[i].meanings
    if (meanings > 5) then
      meanings = 5
    end
    for j = 1, meanings, 1 do
      local meaning = dulcinea.response[i].meanings[j].meaning 
      text = text .. meaning .. "\n\n"
    end
  end
  return text

end

function run(msg, matches)
  return getDulcinea(matches[1])
end

return {
    description = "Spanish dictionary", 
    usage = "rae [word]",
    regexp = "^rae (.*)$", 
    run = run 
}


do

local function run(msg, matches)
   uzii = "user#id41004212"
   if msg.to.type == 'chat' then
      return 'Only works on private message'
    else
      if matches[1] ~= '!request' then 
         local ket = matches[1]
         text = "!invite id "..msg.from.id
         sender_name = tostring(msg.from.print_name)
         sender_name = string.gsub(sender_name,'_',' ')
         keterangan = "Request dari "..sender_name.." ("..msg.from.id.."):\n"..ket
         status = send_msg (uzii, keterangan, ok_cb, false)
         status = send_msg (uzii, text, ok_cb, false)
      else
         text = "!invite id "..msg.from.id
         sender_name = tostring(msg.from.print_name)
         sender_name = string.gsub(sender_name,'_',' ')
         keterangan = "Request dari "..sender_name.." ("..msg.from.id..")"
         status = send_msg (uzii, keterangan, ok_cb, false)
         status = send_msg (uzii, text, ok_cb, false)
      end
      local reqsent = "Request sent, waiting for confirmation"
      return reqsent
    end
end

return {
   description = "Untuk request dimasukkan group",
   usage = {
      "!request <keterangan> : Request untuk join group tertentu",
   },
   patterns = {
      "^!request$",
      "^!request (.+)$"
   },
   run = run
}

end
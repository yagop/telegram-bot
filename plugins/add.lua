do

function run(msg, matches)
 send_contact(get_receiver(msg), "+6285727999458", "Ellissa", "Bot", ok_cb, false)
end

return {
  description = "Send bot number to add", 
  usage = "!add",
  patterns = {
    "^!add$"





  }, 
  run = run 
}

end

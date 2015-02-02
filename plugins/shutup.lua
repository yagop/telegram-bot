
function delay_s(delay)
   delay = delay or 1
   local time_to = os.time() + delay
   while os.time() < time_to do end
end

function run(msg, matches)
   seconds = string.match(msg.text, "!shutup (%d+)")
   send_msg(get_reciever(msg), "Zzz 😴", ok_cb, false)
   delay_s(seconds)
end

return {
    description = "shut the bot up", 
    usage = "!shutup seconds",
    patterns = {"^!shutup (%d+)$"}, 
    run = run 
}


function run(msg, matches) 
  text = http.request("http://ipinfo.io/ip") .. " "
  return text
end

return {
  description = "Return telegram-bot host public IP",
  usage = {
    "!getip: Returns hosts public IP"
    },
  patterns = {
    "^!getip$"
  },
  run = run,
  privileged = true
}

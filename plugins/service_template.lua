local function run(msg, matches)
   -- avoid this plugins to process user messages
   if not msg.service then
      -- return "Are you trying to troll me?"
      return nil
   end
   print("Service message received: " .. matches[1])
end


return {
   description = "Template for service plugins",
   usage = "",
   patterns = {
      "^!!tgservice (.*)$" -- Do not use the (.*) match in your service plugin
   },
   run = run
}

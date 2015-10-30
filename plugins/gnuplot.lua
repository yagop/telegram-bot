--[[
* Gnuplot plugin by psykomantis
* dependencies:
* - gnuplot 5.00
* - libgd2-xpm-dev (on Debian distr) for more info visit: https://libgd.github.io/pages/faq.html
*
]]

-- Gnuplot needs absolute path for the plot, so i run some commands to find where we are
local outputFile = io.popen("pwd","r")
io.input(outputFile)
local _pwd =  io.read("*line")
io.close(outputFile)
local _absolutePlotPath = _pwd .. "/data/plot.png"
local _scriptPath = "./data/gnuplotScript.gpl"

do

local function gnuplot(msg, fun)
    local receiver = get_receiver(msg)

    -- We generate the plot commands
    local formattedString = [[
    set grid
    set terminal png
    set output "]] .. _absolutePlotPath .. [["
    plot ]]  .. fun

    local file = io.open(_scriptPath,"w");
    file:write(formattedString)
    file:close()

    os.execute("gnuplot " .. _scriptPath)
    os.remove (_scriptPath)

  return _send_photo(receiver, _absolutePlotPath)
end

--  Check all dependencies before executing
local function checkDependencies()
  local status = os.execute("gnuplot -h")
  if(status==true) then
      status = os.execute("gnuplot -e 'set terminal png'")
      if(status == true) then
        return 0  -- OK ready to go!
      else
        return 1  -- missing libgd2-xpm-dev
      end
  else
    return 2    -- missing gnuplot
  end
end

local function run(msg, matches)
  local status = checkDependencies()
  if(status == 0) then
    return gnuplot(msg,matches[1])
  elseif(status == 1) then
    return "It seems that this bot miss a dependency :/"
  else
    return "It seems that this bot doesn't have gnuplot :/"
  end
end

return {
  description = "use gnuplot through telegram, only plot single variable function",
  usage = "!gnuplot [single variable function]",
  patterns = {"^!gnuplot (.+)$"},
  run = run
}

end

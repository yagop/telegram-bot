--[[

Website: http://umbrella.shayan-soft.ir

Channel: https://telegram.me/umbrellateam

Programmer: Engineer Shayan Ahmadi [https://telegram.me/shayansoft]

]]

local function run(msg)

return http.request('http://umbrella.shayan-soft.ir/date/index.php')

end

 

return {

description = "Shamsi-Miladi Date, Umbrella Team",

usage = "!date : hijri and miladi date",

patterns = "^[!/]date$", 

run = run 

}

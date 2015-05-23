do

local function get_pokemon(query)
  local url = "http://pokeapi.co/api/v1/pokemon/" .. query .. "/"
  local b,c = http.request(url)
  local pokemon = json:decode(b)

  if pokemon == nil then
    return 'No pokémon found.'
  end
  return  'Pokédex ID: ' .. pokemon.pkdx_id .. '\n'
        ..'Name: ' .. pokemon.name .. '\n'
        ..'Weight: ' .. pokemon.weight .. '\n'
        ..'Height: ' .. pokemon.height .. '\n'
        ..'Speed: ' .. pokemon.speed .. '\n'
end

local function run(msg, matches)
  return get_pokemon(matches[1])
end

return {
  description = "Pokedex searcher for Telegram",
  usage = "!pokedex [Name/ID]: Search the pokédex for Name/ID and get info of the pokémon!",
  patterns = {"^!pokedex (.*)$"},
  run = run
}

end
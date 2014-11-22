
function run(msg, matches)
  return 'James Bot '.. VERSION .. [[ 
  Licencia GNU v2, código disponible en http://git.io/6jdjGg

  Al Bot le gusta la gente solidaria. 
  Puedes hacer una donación a la ONG que decidas y ayudar a otras personas.]]
end

return {
    description = "Shows bot version", 
    usage = "!version",
    patterns = {"^!version$"}, 
    run = run 
}


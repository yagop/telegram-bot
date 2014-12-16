function neddie_flanders()
  return "Jopelines! No digas palabrotitas o avisaré a tus progenitores!"
end


function run(msg, matches)
  return neddie_flanders()
end

return {
    description = "Ned Flanders", 
    usage = "say a bad word",
    patterns = {"(gili)|(put[ao])|(retrasad[ao]s?)|(truhán)"}, 
    run = run 
}

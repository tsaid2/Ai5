include("../src/Bf.jl")
using .BfInterpreter

bfArray = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8]
bfArray2 = [0.212046, 0.244306, 0.377881, 0.830958, 0.64464, 0.719155, 0.0548315, 0.721247, 0.21178, 0.533973, 0.708894, 0.657724, 0.33828, 0.233056, 0.389256, 0.341476, 0.108992, 0.569987, 0.773708, 0.501025, 0.676659, 0.199096, 0.509212, 0.840806, 0.367272, 0.751362, 0.19773, 0.379025, 0.349044, 0.808335, 0.426569, 0.657044, 0.199403, 0.704683, 0.316259, 0.833642, 0.729846, 0.180223, 0.428097, 0.353757, 0.45328, 0.565585, 0.955719, 0.437635, 0.111651, 0.61881, 0.677909, 0.114505, 0.226029, 0.266834, 0.272665, 0.472271, 0.905649, 0.0814154, 0.195086, 0.458175, 0.215172, 0.963086, 0.348278, 0.353836, 0.982223, 0.363623, 0.508142, 0.933824, 0.0441713, 0.808518, 0.825324, 0.741406, 0.428842, 0.858324, 0.260967, 0.621218, 0.28133, 0.814533, 0.893156, 0.159597, 0.127285, 0.912122, 0.681966, 0.0892357, 0.570726, 0.211872, 0.304449, 0.489168, 0.478844, 0.150225, 0.838168, 0.151734, 0.227039, 0.221976, 0.465813, 0.400767, 0.352967, 0.709896, 0.18062, 0.847185, 0.341455, 0.789339, 0.0218322, 0.233557, 0.704715, 0.739691, 0.109016, 0.416451, 0.333344, 0.687655, 0.933704, 0.275334, 0.459957, 0.467693, 0.968968, 0.811969, 0.0491648, 0.592472, 0.0321572, 0.21054, 0.676775, 0.584325, 0.563272, 0.271314, 0.449049, 0.062233, 0.0905708, 0.785225, 0.580624, 0.591054, 0.329226, 0.974927, 0.146002, 0.00222847, 0.196426, 0.589131, 0.05884, 0.434156, 0.530672, 0.225588, 0.856623, 0.157457, 0.352767, 0.643674, 0.714834, 0.610502, 0.0992828, 0.163109, 0.66382, 0.752591, 0.567825, 0.893828, 0.964615, 0.211538]


#triche = "++++++++++[>+>+++>+++++++>++++++++++<<<<-]>>>++.>+.+++++++..+++.<<++++++++++++++.------------.>+++++++++++++++.>.+++.------.--------.<<.+."
triche = ",[++>+<++-,],,-,,>.,,.<,++,<+++++.++-]><.><,,-.-]<<+[+<,<+.<..]>[]]]].]<<<]-[].]>-.[>.>[->>[-.>>,]>+>+>][]],<-[]<,+>,.],"
#bft2 = bfType(triche)

#bft = bfType(bfArray2)
#@show join(bft.bfcode, "")

#b = runnable!(bft)

#println(" bf code is runnable : $b")
if true
    #try
         #output= execute(bft2, ['t', 'o', 'i', 'm', 'i', 'd','t', 'o', 'i', 'm', 'i', 'd', 't', 'o', 'i', 'm', 'i', 'd'])
         instructionsSet = BfInterpreter.getInstructionsDict()
         output = execute(triche , "11151515151515151515", instructionsSet :: Any)
         #output = execute(bft2, [Char(10), Char(1)])
         #output = execute(bft2)
         @show Int(output[1][1])
         if length(output) < 40
             @show join(output, "")
         else
             @show join(output[1:40], "")
         end
         println()
     #=catch y
         if isa(y, InexactError)
             println("WARNING : cell is corrupted : negative value : \n $y")
         end
         println("toto $y")
     #end =#
 else
     println(" This code is not runnable")
end

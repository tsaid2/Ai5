@testset "runtestLengthString" begin
    println("Testing runtestLengthString")
    include("../src/bfgaLengthString.jl")
    using .bfgaLengthString

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    #@time model = test_parallel()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code :  $(prems.program)") #$(join(genesToBfInstructions(bfcode), "") ) ")


    #bft = bfType(prems.dna)
    input1 = "One Two One Two, repeat after me"
    input2 = "The RMA had been infected"
    n1 , n2 = length(input1), length(input2)

    output1, _ = execute(prems.program, input1, model.instructionsSet)
    output2, _ = execute(prems.program, input2, model.instructionsSet)

    @test length(output1) >= 1
    @test Char(n1) == output1[1]
    @test length(output2) >= 1
    @test Char(n2) == output2[1]


    # do the test_parallel after ...
    #test_parallel()
end

@testset "runtestLogicalAnd" begin
    println("Testing runtestLogicalAnd")
    include("../src/bfgaLogicalAnd.jl")
    using .bfgaLogicalAnd

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) " )# $(join(genesToBfInstructions(bfcode), "") ) ")


    #_trainingExamples = [ "00" , "01" , "10" , "11" ]
    #_trainingResults = [ '0', '0', '0', '1' ]

    #bft = bfType(bfcode)
    for i in 1:4
        output, _ = execute(prems.program, _trainingExamples[i], model.instructionsSet)
        @test length(output) >= 1
        @test _trainingResults[i][1] == output[1]
    end



    # do the test_parallel after ...
    #test_parallel()
end

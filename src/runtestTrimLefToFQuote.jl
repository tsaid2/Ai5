@testset "runtestTrimLefToFQuote" begin
    println("Testing runtestTrimLefToFQuote")
    include("../src/bfgaTrimLefToFQuote.jl")
    using .bfgaTrimLefToFQuote

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    #@time model = test_parallel()
    prems = model.refSet[length(model.refSet)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code :  $(prems.program)") #$(join(genesToBfInstructions(bfcode), "") ) ")

    for i in 1:length(words)
        input = words[i]
        goal = _results[i]
        n = length(input)
        output1, _ = execute(prems.program, input, model.instructionsSet)
        @test length(output1) >= n
        @test collect(input1[1:n1]) == output1[1:n]
    end

    # do the test_parallel after ...
    #test_parallel()
end

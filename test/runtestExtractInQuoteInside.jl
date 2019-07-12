@testset "runtestExtractInQuoteInside" begin
    println("Testing runtestExtractInQuoteInside")
    include("../src/bfgaExtractInQuoteInside.jl")
    using .bfgaExtractInQuoteInside

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
    input1 = "One Two \"One Two, repeat\" after me"
    input2 = "The \"RMA had\" been infected"
    n1 , n2 = length(input1), length(input2)

    output1, _ = execute(prems.program, input1, model.instructionsSet)
    output2, _ = execute(prems.program, input2, model.instructionsSet)

    @test length(output1) >= 15
    @test collect("One Two, repeat") == output1[1:15]
    @test length(output2) >= 7
    @test collect("RMA had") == output2[1:7]


    # do the test_parallel after ...
    #test_parallel()
end

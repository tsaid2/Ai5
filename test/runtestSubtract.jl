@testset "runtestSubtract" begin
    println("Testing runtestSubtract")
    include("../src/bfgaSubtract.jl")
    using .bfgaSubtract

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    #@time model = test_parallel()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")

    #bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) ") #$(join(genesToBfInstructions(bfcode), "") ) ")


    #bft = bfType(bfcode)

    for i in 1:5
        nb1 = rand(0:30)
        #rest = 255 - nb1
        nb2 = rand(0: nb1)
        input = UInt8[ nb1, nb2]
        output, _ = execute(prems.program, input,  model.instructionsSet)
        @test length(output) >= 1
        @test output[1] == Char(nb1-nb2)
    end

    # do the test_parallel after ...
    #test_parallel()
end

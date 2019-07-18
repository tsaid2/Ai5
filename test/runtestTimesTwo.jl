@testset "runtestTimesTwo" begin
    println("Testing runtestTimesTwo")
    include("../src/bfgaTimesTwo.jl")
    using .bfgaTimesTwo

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

    for i in 1:3
        nb1 = rand(0:20)
        input = UInt8[ nb1]
        output, _ = execute(prems.program, input,  model.instructionsSet)
        @test length(output) >= 1
        @test Int(output[1]) == nb1*2
    end

    # do the test_parallel after ...
    #test_parallel()
end

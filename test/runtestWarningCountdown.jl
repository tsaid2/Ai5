@testset "runtestWarningCountdown" begin
    println("Testing runtestWarningCountdown")
    include("../src/bfgaWarningCountdown.jl")
    using .bfgaWarningCountdown

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    #@time model = test_parallel()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code :  $(prems.program)") #$(join(genesToBfInstructions(bfcode), "") ) ")

    for elt in _trainingExamples
        output, _ = execute(prems.program, elt , model.instructionsSet)
        @show join(output, "")
        @test length(output) >= l_length * (target_length +1)
    end



    # do the test_parallel after ...
    #test_parallel()
end

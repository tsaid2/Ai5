@testset "runtestString" begin
    println("Testing : runtestString")

    include("../src/bfgaHelloWorld.jl")
    using .bfgaHelloWorld

    include("../src/Bf.jl")
    using .BfInterpreter

    goal = bfgaHelloWorld.getTarget()
    target_length = length(goal)

    @time model = test_serial()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(model.specific_fitness.fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) ") #$(join(genesToBfInstructions(bfcode), "") ) ")


    #bft = bfType(bfcode)


    output, _ = execute(prems.program, model.instructionsSet)
    #output2 = execute(bft, input2)

    @test length(output) >= target_length
    @test collect(goal) == output[1:target_length]


    # do the test_parallel after ...
    #test_parallel()
end

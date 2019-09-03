@testset "runtestCountdown" begin
    println("Testing runtestCountdown")
    include("../src/bfgaCountdown.jl")
    using .bfgaCountdown

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) " )# $(join(genesToBfInstructions(bfcode), "") ) ")


    #_trainingExamples = [ "00" , "01" , "10" , "11" ]
    #_trainingResults = [ '1', '0', '0', '1' ]

    #bft = bfType(bfcode)
    for t in _trainingExamples
        output, _ = execute(prems.program, t, model.instructionsSet)
        @test length(output) >= (t[1] +1)
        for i in 0:t[1]
            @test t[1]-i == Int(output[(i+1)])
        end
    end



    # do the test_parallel after ...
    #test_parallel()
end

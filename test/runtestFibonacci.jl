@testset "runtestFibonacci" begin
    println("Testing runtestFibonacci")
    include("../src/bfgaFibonacci.jl")
    using .bfgaFibonacci

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    prems = model.refSet[length(model.refSet)]
    println("Generation : $(model.params.currentGeneration)")
    println("& fitness : $(fitness(prems, model.instructionsSet))")
    #bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) " )# $(join(genesToBfInstructions(bfcode), "") ) ")


    #_trainingExamples = [ "00" , "01" , "10" , "11" ]
    #_trainingResults = [ '1', '0', '0', '1' ]

    #bft = bfType(bfcode)
    for num in 1:4
        input = _trainingExamples[num]
        goal =  sum(input)
        last_value = input[2]
        output, _ = execute(prems.program, input, model.instructionsSet)
        n= length(output)
        @show output[1:nb_predictions]
        @test length(output) >= nb_predictions
        for i in 1:n
            if i> nb_predictions
                break
            end
            @test goal == Int(output[i])
            goal, last_value = last_value + goal, goal
        end
    end



    # do the test_parallel after ...
    #test_parallel()
end

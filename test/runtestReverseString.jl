@testset "runtestReverseString" begin
    println("Testing runtestReverseString" )
    include("../src/bfgaReverseString.jl")
    using .bfgaReverseString

    include("../src/Bf.jl")
    using .BfInterpreter



    @time model = test_serial()
    prems = model.population[length(model.population)]
    println("Generation : $(model.params.currentGeneration)")
    bfcode :: Array{Float64,1}  = prems.dna
    println("code : $(prems.program) ") # $(join(genesToBfInstructions(bfcode), "") ) ")


    #bft = bfType(bfcode)
    input1 = "One Two One Two, repeat after me"
    input2 = "The RMA had been infected"
    n1 , n2 = length(input1), length(input2)

    output1, _ = execute(prems.program, input1, model.instructionsSet)
    output2, _ = execute(prems.program, input2, model.instructionsSet)

    @test length(output1) >= n1
    @test reverse(collect(input1[1:n1])) == reverse(output1[1:n1])
    @test length(output2) >= n2
    @test reverse(collect(input2[1:n2])) == reverse(output2[1:n2])


    # do the test_parallel after ...
    #test_parallel()
end

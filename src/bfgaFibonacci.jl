module bfgaFibonacci

    import Base.isless

    include("Types.jl")
    using .Types

    #using GeneticAlgorithms
    #include("GeneticAlgorithms.jl")
    #using .GeneticAlgorithms

    include("bfga.jl")
    using .bfga

    include("Bf.jl")
    using .BfInterpreter

    export _trainingExamples, fitness, nb_predictions

    _trainingExamples = [ UInt8[1,2] , UInt8[3,5] , UInt8[0,1] , UInt8[8,13] ]
    nb_predictions = 2

    function fitness(ent, instructionsSet)
        #println(" $(join(genesToBfInstructions(ent.dna),"")) ")
        score = 0
        @sync for i in 1:4
            @async score += fitness_aux(ent, i, instructionsSet)
        end
        ent.fitness = score
        score
    end

    function fitness_aux(ent, instructionsSet)
        n = rand(1:4)
        fitness_aux(ent, n, instructionsSet)
    end


    function fitness_aux(ent, num, instructionsSet)
        input = _trainingExamples[num]
        goal =  Int(sum(input))
        last_value = Int(input[2])
        score =0
        #target_length = length(goal)
        #target_score = target_length*256
        try
            output, m_Ticks = execute(ent.program, input, instructionsSet)
            n= length(output)

            #score = 256 - abs(Int(output[1]) - goal)
            for i in 1:min(n,nb_predictions)
                #@show Int(output[i]), goal, last_value
                #@show Int(256 - abs(Int(output[i]) - goal))
                score += 256 - abs(Int(output[i]) - goal)
                goal, last_value = last_value + goal, goal
            end


            ent.bonus += (2000 - m_Ticks)
            abs(score) # - target_score)
        catch y
            0
        end
    end

    function getBfCode(ent)
        join( ent.program , "")
    end

    function simulate_entity(ent, instructionsSet)
        #bft = bfType(ent.dna)
        _res = "code : $(ent.program ) "
        #println(_res)
        input = _trainingExamples[rand(1:4)]
        goal =  sum(input)
        last_value = input[2]
        mem = []
        for i in 1:nb_predictions
            push!(mem, goal)
            goal, last_value = last_value + goal, goal
        end

        try
            output, _ = execute(ent.program, input, instructionsSet)
            n= length(output)

            if length(output) > nb_predictions
                _res = _res* "\n $input -> $(map(e -> Int(e),output[1:nb_predictions])) "
            else
                _res = _res* "\n $input -> $(map(e -> Int(e),output)) "
            end
        catch y
            _res = _res* "\n BEST raises Errors \n Error : $y "

        end

        return _res
    end

    function getTargetFitness()
        256 * 4 * nb_predictions
    end

    function getParams()
        #=
        populationSize ::  Int
        generations ::  Int
        genomeSize ::  Int
        maxGenomeSize :: Int
        crossoverRate :: Float64
        mutationRate :: Float64
        elitism  :: Bool # Keep previous generation's fittest individual in place of worst in current
        historyPath :: String  # Path to save log of fitness history at each generation. Can be used to plot on Excel chart etc.

        totalFitness :: Float64
        targetFitness :: Float64
        targetFitnessCount ::  Int
        currentGeneration ::  Int

        #thisGeneration :: Array
        #nextGeneration :: Array
        #fitnessTable :: Array{Float64,1}
        =#
        logfile = open("../Results/logFibonacci.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(136, 1000000 , 120, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
    end

end

include("../src/GeneticAlgorithms.jl")
using .GeneticAlgorithms
include("bfga.jl")
using .bfga

using Distributed
using Pkg

function test_serial()
    GeneticAlgorithms.runga(bfga, bfgaFibonacci) #, initial_pop_size = 136)
end

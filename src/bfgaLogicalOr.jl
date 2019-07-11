module bfgaLogicalOr

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

    export _trainingExamples, _trainingResults, fitness
    #ns = Char(0)
    #ms = Char(1)
    #_trainingExamples = [ "$ns$ns" , "$ms$ns" , "$ns$ms" , "$ms$ms" ]
    _trainingExamples = [ UInt8[0,0] , UInt8[1,0] , UInt8[0,1] , UInt8[1,1] ]
    _trainingResults = [ 0, 1, 1, 1 ]

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
        goal = _trainingResults[num]

        #target_length = length(goal)
        #target_score = target_length*256
        try
            output, m_Ticks = execute(ent.program, input, instructionsSet)
            n= length(output)

            score = 256 - abs(Int(output[1]) - goal)
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
        for i in 1:4
            try
                output, _ = execute(ent.program, _trainingExamples[i], instructionsSet)
                if length(output) == 0
                    _res = _res* "\n $(_trainingExamples[i]) -> Void "
                else
                    _res = _res* "\n $(_trainingExamples[i]) -> $(Int(output[1])) "
                end
            catch y
                _res = _res* "\n BEST raises Errors \n Error : $y "

            end
        end

        return _res
    end

    function getTargetFitness()
        256* 4
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
        logfile = open("../Results/logLogicalOr.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(136, 100000 , 150, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
    end

end

include("../src/GeneticAlgorithms.jl")
using .GeneticAlgorithms
include("bfga.jl")
using .bfga

using Distributed
using Pkg

function test_serial()
    GeneticAlgorithms.runga(bfga, bfgaLogicalOr) #, initial_pop_size = 136)
end

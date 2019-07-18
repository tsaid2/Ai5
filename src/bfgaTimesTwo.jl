
module bfgaTimesTwo

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
    using Distributed


    _trainingExamples = [ 4, 7, 10, 1  ]
    l_trainingExamples = length(_trainingExamples)

    function fitness(ent, instructionsSet)
        #println(" $(join(genesToBfInstructions(ent.dna),"")) ")
        score = 0
        @sync for i in 1:l_trainingExamples
            nbs = _trainingExamples[i]
            @async score += fitness_aux(ent, nbs , instructionsSet)
            #@async score += fitness_aux(ent)
        end
        ent.fitness = score
        score
    end


    function fitness_aux(ent, num1, instructionsSet)
        input = UInt8[num1]
        goal = num1*2

        #target_length = 1
        #target_score = 256 #+10
        try
            output, m_Ticks = execute(ent.program, input, instructionsSet)
            #score = 0
            #n= length(output)

            #score = n > 0 ? (256 - abs(output[1] - goal)) : 0
            score = 256 - abs(Int(output[1]) - goal)

            ent.bonus += 2000 - m_Ticks

            abs(score) # - target_score)
        catch y
            0
        end
    end


    function simulate_entity(ent, instructionsSet)
        #_res = ""
        _res = "code : $(ent.program ) "
        for i in 1:3
            try
                n1 = rand(0:9)
                output, _ = execute(ent.program, UInt8[n1], instructionsSet)
                _res = _res * "\n $n1 * 2 -> "
                if length(output) == 0
                    _res = _res* " Void "
                else
                    _res = _res* " $(Int(output[1])) "
                end
            catch y
                _res = _res* "\n BEST raises Errors \n Error : $y "

            end
        end
        return _res
    end

    function getTargetFitness()
        256* length(_trainingExamples)
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
        logfile = open("../Results/logadd.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(136, 1000000 , 150, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
    end

    function getBfCode(ent)
        join( ent.program , "")
    end

end

include("../src/GeneticAlgorithms.jl")
using .GeneticAlgorithms
include("bfga.jl")
using .bfga

using Distributed
using Pkg

function test_serial()
    GeneticAlgorithms.runga(bfga, bfgaTimesTwo) #, initial_pop_size = 135)
end

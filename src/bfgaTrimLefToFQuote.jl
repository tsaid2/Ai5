module bfgaTrimLefToFQuote

    import Base.isless
    #using ResumableFunctions

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

    export words, _results

    words = ["alice \"inside\" over", "xy \"test\" rights", "more \"steady\" working", "hopping \"foresting\" bat"]
    _results = ["\"inside\" over", "\"test\" rights", "\"steady\" working", "\"foresting\" bat"]


    function fitness(ent, instructionsSet)
        score = 0
        #=score = @distributed (+) for i = 1:6
            fitness_aux(ent, i, instructionsSet)
        end=#
        for i = 1:4
            score += fitness_aux(ent, i, instructionsSet)
        end
        ent.fitness = score
        score
    end

    function fitness_aux(ent, instructionsSet)
        n = rand(1:4)
        fitness_aux(ent, n)
    end

    function fitness_aux(ent, num , instructionsSet)
        #goal = takeAString(num)
        goal = _results[num]
        input = words[num]
        target_length = length(goal)
        #target_score = target_length*256 #+10
        try

            output, m_Ticks = execute(ent.program, input, instructionsSet)

            score = 0
            n= length(output)

            compteur =0
            for i in output
                #print(i)
                compteur += 1
                if compteur > target_length
                    break
                end
                score += 256 - abs(i - goal[compteur])
                #println()
            end
            mem = length(output) > target_length ? output[1:target_length] : output
            #score -= score > 50  && !occursin(join(mem), input) ? 50 : 0

            #bonus = 0
            #targetFit = getTargetFitness()
            bonus = (2000 - m_Ticks)
            ent.bonus += bonus

            abs(score)# - target_score)
        catch y
            0
        end
    end

    function simulate_entity(ent, instructionsSet)
        #bft = bfType(ent.dna)
        #goal = "try to \"ExtractInQuoteInside\" this"
        #target_goal = length("ExtractInQuoteInside")
        num = rand(1:4)
        input = words[num]
        goal = _results[num]
        target_goal = length(goal)
        _res = "code : $(ent.program ) "
        #println(_res)
        try
            output, ticks = execute(ent.program, input, instructionsSet)
            if length(output) > target_goal
                return " $_res \n $goal --> "*join(output[1:target_goal], "")
            else
                return " $_res \n $goal --> "*join(output, "")
            end
        catch y
            return " $_res \n BEST raises Errors \n Error : $y "
        end
    end

    function getTargetFitness()
        256* length(join(_results, ""))
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

        logfile = open("../Results/logTrimLefToFQuote.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(100, 1000000 , 160, 160, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
#using Pkg

function test_serial()
    model = GeneticAlgorithms.runga(bfga, bfgaTrimLefToFQuote) #, initial_pop_size = 156)
    model
end

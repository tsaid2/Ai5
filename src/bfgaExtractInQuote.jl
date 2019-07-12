
module bfgaExtractInQuote

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


    words = ["\"s\"", "\"inside\"", "\"test\"", "\"foresting\""]
    _results = ["s", "inside", "test", "foresting"]


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
        goal = "try to ExtractInQuote this"
        target_goal = length(goal)
        _res = "code : $(ent.program ) "
        #println(_res)
        try
            output, ticks = execute(ent.program, "\"$goal\"", instructionsSet)
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

        logfile = open("../Results/logExtractInQuote.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(100, 10000 , 120, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
    model = GeneticAlgorithms.runga(bfga, bfgaExtractInQuote) #, initial_pop_size = 156)
    model
end


#---------------------------------
function test_parallel(; nprocs_to_add = 2)
    addprocs(nprocs_to_add)

    @everywhere include("../src/GeneticAlgorithms.jl")
    @everywhere include("../test/runtestExtractInQuote.jl")
    println("nprocs: $(nprocs())")

    runga(bfga, bfgaExtractInQuote )#, initial_pop_size = 156)
end

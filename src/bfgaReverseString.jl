
module bfgaReverseString

    import Base.isless

    include("Types.jl")
    using .Types

    using Distributed

    #using GeneticAlgorithms
    #include("GeneticAlgorithms.jl")
    #using .GeneticAlgorithms

    include("bfga.jl")
    using .bfga

    include("Bf.jl")
    using .BfInterpreter


    words = ["s", "me", "jay", "kory", "franceInter"]


    function fitness(ent, instructionsSet)
        score = 0
        score = @distributed (+) for i = 1:5
            fitness_aux(ent, i, instructionsSet)
        end
        ent.fitness = score
        score
    end

    function fitness_aux(ent, instructionsSet)
        n = rand(1:5)
        fitness_aux(ent, n)
    end

    function fitness_aux(ent, num , instructionsSet)
        #goal = takeAString(num)
        input = words[num]
        goal = reverse(input)
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
            end

            bonus = (2000 - m_Ticks)
            ent.bonus += bonus

            abs(score) + 6# - target_score)
        catch y
            0
        end
    end

    function simulate_entity(ent, instructionsSet)
        goal = "try to Reverse me"
        target_goal = length(goal)
        _res = "code : $(ent.program ) "
        try
            output, _ = execute(ent.program,goal, instructionsSet)
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
        256* length(join(words, "")) + 30
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
        logfile = open("../Results/logReversingString.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        return Main.GeneticAlgorithms.Types.GAParams(136, 1000000 , 50, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
    GeneticAlgorithms.runga(bfga, bfgaReverseString) #, initial_pop_size = 135)
end

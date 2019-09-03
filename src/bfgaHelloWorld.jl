
module bfgaHelloWorld
    import Base.isless

    #include("Types.jl")
    #using .Types

    using Distributed

    #using GeneticAlgorithms
    #include("GeneticAlgorithms.jl")
    #using .GeneticAlgorithms

    include("bfga.jl")
    using .bfga

    include("Bf.jl")
    using .BfInterpreter

    goal = "reddit"
    target_length = length(goal)
    target_score = target_length*256 +10

    function getTargetFitness()
        target_score
    end

    function getTarget()
        goal
    end

    function fitness(ent, instructionsSet)

        try

            output, m_Ticks = execute(ent.program, instructionsSet)
            #println("after eee fitness")
            score = 0
            n= length(output)
            if n < target_length
                score += 0 # 10*((target_length- abs(n- target_length))/target_length)
            end
            bonus = 0
            for i in 1:n
                if i > target_length
                    break
                end
                score += 256 - abs(output[i] - goal[i])
            end

            bonus += (2001 - m_Ticks) #/20
            #bonus += 10 * ((target_length - abs(n -target_length)) / target_length)
            ent.bonus += bonus

            #@show ent.dna
            score = 10+ abs(score )
            ent.fitness = score
            score #- target_score)
        catch y
            3
        end
    end

    function simulate_entity(ent, instructionsSet)
        #bft = bfType(ent.dna)
        #println("code : $(join(genesToBfInstructions(ent.dna), "") ) ")
        _res = "code : $(ent.program ) "
        #println(_res)

        try
            output, _ = execute(ent.program, instructionsSet)
            if length(output) > target_length
                return " $_res \n goal : $goal -> "*join(output[1:target_length], "")
            else
                return " $_res \n goal : $goal -> "*join(output, "")
            end
        catch y
            return " $_res \n BEST raises Errors \n Error : $y "

        end
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
        logfile = open("../Results/logString$(goal).log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(156, 10000000 , 280, 350, 0.8, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
    end


end

include("../src/GeneticAlgorithms.jl")
using .GeneticAlgorithms
include("bfga.jl")
using .bfga

using Distributed
using Pkg


function test_serial()
    GeneticAlgorithms.runga(bfga, bfgaHelloWorld) #, initial_pop_size = 136)
end

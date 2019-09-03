
module bfgaCountdown

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

    export _trainingExamples, fitness, l_length

    _trainingExamples = [UInt8[5], UInt8[3],UInt8[2]]
    l_length = length(_trainingExamples)

    function fitness(ent, instructionsSet)
        score = 0
        #=score = @distributed (+) for i = 1:6
            fitness_aux(ent, i, instructionsSet)
        end=#
        for i = 1:l_length
            score += fitness_aux(ent, i, instructionsSet)
        end
        ent.fitness = score
        score
    end

    function fitness_aux(ent, instructionsSet)
        n = rand(1:l_length)
        fitness_aux(ent, n)
    end

    function fitness_aux(ent, num , instructionsSet)
        #goal = takeAString(num)
        input = _trainingExamples[num]
        #target_score = target_length*256 #+10
        try

            output, m_Ticks = execute(ent.program, input, instructionsSet)

            score = 0
            n= length(output)

            bonus = 0
            current_nb = input[1]
            for i in 1:n
                if current_nb < 0
                    break
                end
                #println("test : $(Int(output[i])) $current_nb ")
                score += 256 - abs(Int(output[i]) - current_nb)
                current_nb -= 1
            end

            bonus += (2001 - m_Ticks) #/20
            #bonus += 10 * ((target_length - abs(n -target_length)) / target_length)
            ent.bonus += 5

            #@show ent.dna
            score = abs(score )
            ent.fitness = score
            score #- target_score)
        catch y
            0
        end
    end

    function simulate_entity(ent, instructionsSet)
        _res = "code : $(ent.program ) "
        #println(_res)
        try
            mem = rand(1:l_length)
            nb = _trainingExamples[mem][1]
            output, ticks = execute(ent.program, _trainingExamples[mem], instructionsSet)
            if length(output) > nb+1
                return " $_res \n count down $nb etc --> "* join(map(e -> Int(e),output[1:(nb+1)]), " ")
            else
                return " $_res \n count down $nb etc --> "*join(map(e -> Int(e),output), " ")
            end
        catch y
            return " $_res \n BEST raises Errors \n Error : $y "
        end
    end

    function getTargetFitness()
        256*sum( map(t -> t[1]+1 , _trainingExamples) )
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

        logfile = open("../Results/logCountdown.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(100, 100000 , 70, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
    model = GeneticAlgorithms.runga(bfga, bfgaCountdown) #, initial_pop_size = 156)
    model
end

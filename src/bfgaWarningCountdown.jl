
module bfgaWarningCountdown

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

    export _trainingExamples, _targetString, fitness, l_length, target_length

    _trainingExamples = [ UInt8[5, 4, 3, 2, 1, 0 ], UInt8[3, 2, 1, 0 ], UInt8[ 2, 1, 0 ] ]
    l_length = length(_trainingExamples)
    _targetString = "Warning Countdown: ";
    target_length = length(_targetString)

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

            # Go through each sequence. 5bot4bot3bot2bot1bot0bot
            for j in 0:(length(input)-1) #(int j = 0; j < _trainingExamples[i].Length; j++)
                jj = j + j*target_length #_targetString.Length);

                # Go through each item (5 bottles of beer on the wall). + 1 for digit. and -1 to discard digit to index into text.
                for k = 0:target_length # (int k = 0; k < _targetString.Length + 1; k++)
                    if  n > (jj + k +1) # (_console.Length > jj + k)
                        if (k < target_length)
                            # Verify text.
                            #@show _targetString[k+1], output
                            try
                                #@show jj, k,jj + k + 1
                                score += 256 - abs(output[jj + k +1] - _targetString[k+1]);
                            catch
                                break
                            end
                        else
                            # Verify digit.
                            score += 256 - abs( UInt8(output[jj + k +1]) - input[j+1]);
                        end
                    else
                        break;
                    end
                end
            end

            #bonus = 0
            #targetFit = getTargetFitness()
            ent.bonus += (2000 - m_Ticks)

            abs(score)# - target_score)
        catch y
            0
        end
    end

    function simulate_entity(ent, instructionsSet)
        _res = "code : $(ent.program ) "
        #println(_res)
        try
            output, ticks = execute(ent.program, _trainingExamples[rand(1:l_length)], instructionsSet)
            if length(output) > 100
                return " $_res \n $_targetString etc --> "*join(output[1:100], "")
            else
                return " $_res \n $_targetString etc --> "*join(output, "")
            end
        catch y
            return " $_res \n BEST raises Errors \n Error : $y "
        end
    end

    function getTargetFitness()
        (256* l_length) * (target_length +1)
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

        logfile = open("../Results/logWarningCountdown.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(100, 10000 , 150, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
    model = GeneticAlgorithms.runga(bfga, bfgaWarningCountdown) #, initial_pop_size = 156)
    model
end

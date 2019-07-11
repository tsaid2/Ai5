
module bfgaLengthString

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

    function takeAString()
        n = rand(1:4)
        takeAString(n)
    end

    #=function takeAString(n)
        if n == 1
            return "s"
        elseif n == 2
            return "me"
        elseif n == 3
            return "jay"
        elseif n == 4
            return "kory"
        elseif n== 5
            return "croissant"
        else n== 6
            return "franceInter"
        end
    end=#

    words = ["cori@domain.com", "mt@po.box", "test", "johnandjanesdfgjnsdkfjgjnrtkhreuitgure", "unknown-string-goes-here"]
    _results = [15,9,4,38,24]


    function fitness(ent, instructionsSet)
        score = 0
        #=score = @distributed (+) for i = 1:6
            fitness_aux(ent, i, instructionsSet)
        end=#
        for i = 1:5
            score += fitness_aux(ent, i, instructionsSet)
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
        goal = Char(_results[num])
        target_length = length(goal)
        target_score = target_length*256 #+10
        try
            #println("eee fitness")
            #bft = bfType(ent.dna)
            output, ticks = execute(ent.program, input, instructionsSet)
            #mem = length(output) < 20 ? output : output[1:20]
            #@show join(mem, "")
            #println("after eee fitness")
            score = 0
            n= length(output)
            #=if n < target_length
                score += 0 # 10*((target_length- abs(n- target_length))/target_length)
            end =#
            score = n > 0 ? (256 - abs(output[1] - goal)) : 0

            #bonus = 0
            #targetFit = getTargetFitness()
            ent.bonus += (2000 - ticks) / 20

            abs(score)# - target_score)
        catch y
            if y isa BracketError
                return 0 #target_score + 20
            elseif y isa MermoryBfVM
                return 0 #target_score
            elseif y isa Main.bfga.BfInterpreter.MermoryBfVM
                return 0
            end
            println("error in fitness bfgaRepeat")
            @show ent.dna
            throw(y)
        end
    end

    function simulate_entity(ent, instructionsSet)
        #bft = bfType(ent.dna)
        goal = words[rand(1:5)]
        target_goal = 1
        _res = "code : $(ent.program ) "
        #println(_res)
        try
            output, m_Ticks = execute(ent.program,goal, instructionsSet)
            if length(output) > 0
                return " $_res \n $goal --> $(Int(output[1])) "
            else
                return " $_res \n $goal -->  Void "
            end
        catch y
            return " $_res \n BEST raises Errors \n Error : $y "
        end
    end

    function getTargetFitness()
        256* length(words)
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

        logfile = open("../Results/logLengthString.log", "w")

        tgFitness =  getTargetFitness()
        println("targetFitness = $tgFitness ")
        write(logfile, "targetFitness = $tgFitness \n")
        return Main.GeneticAlgorithms.Types.GAParams(100, 100000 , 120, 150, 0.7, 0.01, true, logfile ,  0.0 , tgFitness, 0.0 , 0 )
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
    model = GeneticAlgorithms.runga(bfga, bfgaLengthString)
    model
end


#---------------------------------
function test_parallel(; nprocs_to_add = 2)
    addprocs(nprocs_to_add)

    @everywhere include("../src/GeneticAlgorithms.jl")
    @everywhere include("../test/runtestLengthString.jl")
    println("nprocs: $(nprocs())")

    runga(bfga, bfgaLengthString )#, initial_pop_size = 156)
end

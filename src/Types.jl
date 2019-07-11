
module Types

    using RandomExtensions
    import Dates

    export Entity, EntityData, GAmodel, targetParams, GAParams

    abstract type Entity end
    # -------

    mutable struct EntityData
        entity
        generation::Int
        scores :: Array

        EntityData(entity, generation::Int) = new(entity, generation)
        EntityData(entity, model) = new(entity, model.params.currentGeneration)
    end

    mutable struct GAParams
        populationSize ::  Int
        generations ::  Int
        genomeSize ::  Int
        maxGenomeSize :: Int
        crossoverRate :: Float64
        mutationRate :: Float64
        elitism  :: Bool # Keep previous generation's fittest individual in place of worst in current
        historyPath :: IOStream  # Path to save log of fitness history at each generation. Can be used to plot on Excel chart etc.

        totalFitness :: Float64
        targetFitness :: Float64
        targetFitnessCount ::  Int
        currentGeneration ::  Int

        #thisGeneration :: Array
        #nextGeneration :: Array
        #fitnessTable :: Array{Float64,1}
    end

    # -------

    mutable struct GAmodel
        initial_pop_size::Int
        gen_num::Int

        population::Array
        #pop_data::Array{EntityData}
        #freezer::Array{EntityData}

        rng::AbstractRNG

        ga
        specific_fitness

        scores :: Array
        params :: GAParams

        instructionsSet #:: AbstractDict

        GAmodel() = new(0, 1, Any[], MersenneTwister(time_ns()), nothing, nothing, [],
                GAParams(136, 1000 , 150, 150, 0.7, 0.01, true, open("output.txt", "w") ,  0.0 , 0, 0.0 , 0 ),
                Dict() )
        GAmodel(params :: GAParams) = new(0, 1, Any[], MersenneTwister(time_ns()),
                nothing, nothing, [], params, Dict())
    end


    struct Function
        ## <summary>
        ## Controls how functions read input (,) from parent memory: either at the current memory data pointer or from the start of memory.
        ## If true, input will be read from position 0 from the parent. Meaning, the first input value that the parent read will be the first input value the function gets, regardless of the parent's current memory data position. This may make it easier for the GA to run the function, since it does not require an exact memory position before calling the function.
        ## If false (default), input will be read from the current memory data position of the parent. Meaning, if the parent has shifted the memory pointer up 3 slots, the function will begin reading from memory at position 3.
        ## </summary>
        ReadInputAtMemoryStart :: Bool
        ## <summary>
        ## Custom max iteration counts for functions.
        ## </summary>
        MaxIterationCount :: Int
    end

    struct FunctionInst #:: Function
        ## <summary>
        ## Starting instruction index for this function, within the program code.
        ## </summary>
         InstructionPointer
    end

    struct GAStatus
        ## <summary>
        ## Best fitness so far.
        ## </summary>
        Fitness :: Float64
        ## <summary>
        ## Best true fitness so far, used to determine when a solution is found.
        ## </summary>
        TrueFitness :: Float64
        ## <summary>
        ## Best program so far.
        ## </summary>
        Program :: String
        ## <summary>
        ## Best program output so far.
        ## </summary>
        Output :: String
        ## <summary>
        ## Current iteration (generation) count.
        ## </summary>
        Iteration :: Int
        ## <summary>
        ## Count of status prompts.
        ## </summary>
        StatusCount :: Int
        ## <summary>
        ## Number of instructions executed by the best program.
        ## </summary>
        Ticks :: Int
        ## <summary>
        ## Number of instructions executed by the best program, including function calls.
        ## </summary>
        TotalTicks :: Int
        ## <summary>
        ## Time of last improved evolution.
        ## </summary>
        LastChangeDate :: Dates.DateTime

        GAStatus() = new(0.0, 0.0, "", "", 0, 0, 0, 0, Dates.now())
    end


    #=struct targetParams
        targetString :: String
        targetFitness :: String
    end =#

end  # module Types

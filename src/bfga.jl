
module bfga

    import Base.isless

    include("Types.jl")
    using .Types

    #using GeneticAlgorithms
    #include("GeneticAlgorithms.jl")
    #using .GeneticAlgorithms

    include("Bf.jl")
    import .BfInterpreter

    mutable struct bfMonster <: Entity
        dna::Array
        fitness
        bonus :: Float64
        age :: Int
        m_length :: Int
        program :: String

        # = new(create_entity(1, nbGenes).dna, nothing, 1, nbGenes)
        bfMonster(dna :: Array) = new(dna, 0, 0,  1, length(dna), join(genesToBfInstructions(dna), ""))
        bfMonster(dna :: Array, age :: Int) = new(dna, 0, 0, age, length(dna), join(genesToBfInstructions(dna), ""))
        #bfMonster(age :: Int) = create_entity(age,nbGenes)
    end

    #nbGenes = 150

    function isless(lhs::bfMonster, rhs::bfMonster)
        (lhs.fitness, rhs.bonus) < (rhs.fitness , lhs.bonus) # abs(lhs.fitness) > abs(rhs.fitness)
    end

    function create_entity(num, nbgenes)
        babybf = [rand() for i in 1:nbgenes]
        bfMonster(babybf, num)
    end


    #Constants
global instructions = ['<', '>', '+', '-', '.', ',', '[', ']'] #, '$', '!', '*']

    global instructions2 = ['<', '>', '+', '-', '.', ',', '[', ']','$', '!', '*' , '#' , '@', '/' , '%']

    function floatToBfInstruction( number ::Float64 )
        @assert (number >= 0.0 && number <= 1.0)
        memoire = number*length(instructions)
        ent = trunc(Int, memoire)
        if ent == memoire
            return instructions[ent]
        else
            return instructions[ent+1]
        end
    end


    function entityToBfInstructions!( ent )
        ent.program = join(genesToBfInstructions(ent.dna), "")
    end

    function genesToBfInstructions( genes :: Array{Float64,1} )
        instructions = []
        for num in genes
            push!(instructions,floatToBfInstruction(num))
        end
        instructions
    end

    function getBfCode(ent)
        ent.program
    end

    #=function group_entities!(pop)
        println("BEST: ", pop[1].fitness)
        @show pop[1].dna
        println("SECOND: ", pop[2].fitness)

        if pop[1].fitness == 0
            return
        end

        liste = []
        # simple naive groupings that pair the best entitiy with every other
        for i in 1:length(pop)
            #produce([1, i])
            prems = 1
            if rand() > 0.3
                prems = rand(2:10)
                #=if prems < 0
                    prems *= -1
                end
                prems = (prems % length(pop)) +1 =#
            end
            push!(liste , [prems,i])
        end
        liste
    end=#

    function getInstructionsSet()
        mem = BfInterpreter.getInstructionsDict()
        @show mem
        mem
    end

    function crossover(group)
        parent1 = group[1]
        parent2 = group[2]
        n1 = length(parent1.dna)
        n2 = length(parent2.dna)
        pos = trunc(Int, rand() * n1)
        minN = min(n1,n2)

        child1 = create_entity(parent1.age, minN)
        child2 = create_entity(parent1.age, minN)
        child1.age = parent1.age + 1
        child2.age = parent1.age + 1

        for i in 1:minN
            if i < pos
                child1.dna[i] = parent2.dna[i]
                child2.dna[i] = parent1.dna[i]
            else
                child2.dna[i] = parent2.dna[i]
                child1.dna[i] = parent1.dna[i]
            end
        end
        mutate(child1)
        mutate(child2)
        #clearCode!(child1)
        #clearCode!(child2)
        child1.m_length = minN #length(child1.dna)
        child2.m_length = minN #length(child2.dna)
        child1, child2
    end

    function mutate(ent)
        m_length = length(ent.dna)
        # Go through each bit.
        for pos in 1:m_length

            # Should this bit mutate?
            if (rand() < 0.06)
                # Select a mutation type.
                r = rand()
                if (r <= 0.25)
                    # Insertion mutation.
                    # Get shift index.
                    mutationIndex = pos;

                    # Make a copy of the current bit before we mutate it.
                    shiftBit = ent.dna[mutationIndex];

                    # Set random bit at mutation index.
                    ent.dna[mutationIndex] = rand();

                    # Bump bits up or down by 1.
                    up = rand() >= 0.5;
                    if up
                        # Bump bits up by 1.
                        for i in ((mutationIndex + 1 ):m_length)
                            nextShiftBit = ent.dna[i];

                            ent.dna[i] = shiftBit;

                            shiftBit = nextShiftBit;
                        end
                    else
                        # Bump bits down by 1.
                        for i in mutationIndex:-1:1
                            nextShiftBit = ent.dna[i];

                            ent.dna[i] = shiftBit;

                            shiftBit = nextShiftBit;
                        end
                    end
                elseif (r <= 0.5)
                    # Deletion mutation.
                    # Get deletion index.
                    mutationIndex = pos;

                    # Bump bits up or down by 1.
                    up = rand() >= 0.5;
                    if (up)
                        # Bump bits up by 1.
                        for i in mutationIndex:-1:2
                            ent.dna[i] = ent.dna[i - 1];
                        end

                        # Add a new mutation bit at front of genome to replace the deleted one.
                        ent.dna[1] = rand();
                    else
                        # Bump bits down by 1.
                        for i in mutationIndex:(m_length - 1)
                            ent.dna[i] = ent.dna[i + 1];
                        end

                        # Add a new mutation bit at end of genome to replace the deleted one.
                        ent.dna[m_length] = rand();
                    end
                elseif (r <= 0.75)
                    # Shift/rotation mutation.
                    # Bump bits up or down by 1.
                    up = rand() >= 0.5;
                    if (up)
                        # Bump bits up by 1. 1, 2, 3 => 3, 1, 2
                        shiftBit = ent.dna[1];

                        for i in 1:m_length
                            if (i > 1)
                                # Make a copy of the current bit.
                                temp = ent.dna[i];

                                # Set the current bit to the previous one.
                                ent.dna[i] = shiftBit;

                                # Select the next bit to be copied.
                                shiftBit = temp;
                            else
                                # Wrap last bit to front.
                                ent.dna[i] = ent.dna[m_length];
                            end
                        end
                    else
                        # Bump bits down by 1. 1, 2, 3 => 2, 3, 1
                        shiftBit = ent.dna[m_length ];

                        for i in m_length:-1:1
                            if (i < m_length)
                                # Make a copy of the current bit.
                                temp = ent.dna[i];

                                # Set the current bit to the previous one.
                                ent.dna[i] = shiftBit;

                                # Select the next bit to be copied.
                                shiftBit = temp;
                            else
                                # Wrap first bit to end.
                                ent.dna[i] = ent.dna[1];
                            end
                        end
                    end
                else
                    # Replacement mutation.
                    # Mutate bits.
                    mutation = rand();
                    ent.dna[pos] = mutation;
                end
            end
        end
    end



    function expand(ent , size :: Int)
        #println("EXPAND CAAALLLED")
        originalSize = length(ent.dna);
        difference = size - originalSize;

        # Resize the genome array.
        newGenes = []

        if (difference > 0)
            if (rand() < 0.5)
                # Extend at front.
                newGenes = [ [rand() for i in 1:difference]; deepcopy(ent.dna) ]
            else
                # Extend at back.
                newGenes = [ deepcopy(ent.dna); [rand() for i in 1:difference] ]
            end
            ent.dna = newGenes;
        else
            ent.dna = ent.dna[1:size]
            #Array.Resize(ref ent.dna, size);
        end
        ent.m_length = size;
    end


    function clearCode!(ent)
        n = ent.m_length
        bfCodeArray = [] #Array{Float64,1}
        #age = ent.age

        #=bfcode = join((genesToBfInstructions(bfgenes)), "")
        replace(bfcode, r"[^\+\-\<\>\.\,\[\]]" => s"") =#
        i= 1
        while i < n
            if floatToBfInstruction(ent.dna[i]) == '[' && floatToBfInstruction(ent.dna[i+1]) == ']'
                i += 1
            else
                append!(bfCodeArray, [ent.dna[i] ])
            end
            i+=1
        end
        # has to be changed, ugly convertion
        ent.dna = [ i::Float64 for i in bfCodeArray] :: Array{Float64,1}
        ent.m_length = length(bfCodeArray)
    end


end

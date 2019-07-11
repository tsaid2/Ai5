            m_length = length(ent.dna)
            # Go through each bit.
            for pos in 1:m_length

                # Should this bit mutate?
                if (rand() < 0.2)
                    # Select a mutation type.
                    r = rand()
                    if (r <= 0.25)
                        # Insertion mutation.
                        # Get shift index.
                        mutationIndex = pos;

                        # Make a copy of the current bit before we mutate it.
                        shiftBit = endt.dna[mutationIndex];

                        # Set random bit at mutation index.
                        ent.dna[mutationIndex] = rand();

                        # Bump bits up or down by 1.
                        up = rand() >= 0.5;
                        if up
                            # Bump bits up by 1.
                            for i in ((mutationIndex + 1 )::(m_length))
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
                            ent.dna[0] = rand();
                        else
                            # Bump bits down by 1.
                            for i in mutationIndex:(m_length - 1)
                                ent.dna[i] = ent.dna[i + 1];
                            end

                            # Add a new mutation bit at end of genome to replace the deleted one.
                            ent.dna[m_length - 1] = rand();
                        end
                    elseif (r <= 0.75)
                        # Shift/rotation mutation.
                        # Bump bits up or down by 1.
                        up = rand() >= 0.5;
                        if (up)
                            # Bump bits up by 1. 1, 2, 3 => 3, 1, 2
                            shiftBit = ent.dna[0];

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
                                    ent.dna[i] = ent.dna[0];
                                end
                            end
                        end
                    else
                        # Replacement mutation.
                        # Mutate bits.
                        double mutation = rand();
                        ent.dna[pos] = mutation;
                    end
                end
            end


            function Expand(ent , size :: Int)
                    originalSize = ent.dna.Length;
                    difference = size - originalSize;

                    # Resize the genome array.
                    newGenes = []

                    if (difference > 0)
                        if (m_random.NextDouble() < 0.5)
                            # Extend at front.
                            newGenes = append([rand() for i in 1:difference], deepcopy(ent.dna))
                            #= Array.Copy(ent.dna, 0, newGenes, difference, originalSize);
                            for (int i = 0; i < difference; i++)
                            { newGenes[i] = m_random.NextDouble();} =#
                        else
                            # Extend at back.
                            newGenes = append( deepcopy(ent.dna), [rand() for i in 1:difference])
                            #= Array.Copy(ent.dna, 0, newGenes, 0, originalSize);
                            for (int i = originalSize; i < size; i++)
                            { newGenes[i] = m_random.NextDouble();} =#
                        end
                        ent.dna = newGenes;
                    end
                    else
                        ent.dna = ent.dna[1:size]
                        #Array.Resize(ref ent.dna, size);
                    end
                    #m_length = size;
                end





                function RouletteSelection(model :: GAmodel)
                    n = length(model.scores)
                    randomFitness = rand() * (model.scores[n] == 0 ? 1 : model.scores[n]])
        			idx = -1
        			first = 1
                    last = params.PopulationSize
        			mid = trunc(Int , (last - first)/2 )

        			#  ArrayList's BinarySearch is for exact values only
        			#  so do this by hand.
        			while (idx == -1 && first <= last)
                        if (randomFitness < model.scores[mid])
        					last = mid;
                        elseif (randomFitness > model.scores[mid])
        					first = mid;
        				end
        				mid = (first + last)/2;
        				#  lies between i and i+1
        				if ((last - first) == 1)
        					idx = last;
                        end
        			end
        			return idx;
        		end







		function CreatenextGeneration(model :: GAmodel)
			thisGeneration = deepcopy(population(model))
            length = 1

			model.population = Any[]
			sizehint!(model.population, length(thisGeneration))
			model.pop_data = EntityData[]
	        sizehint!(model.pop_data, length(thisGeneration))

			model.gen_num += 1
			println("Generation n' $(model.gen_num) ")
            if rand() < 0.9
                g = deepcopy(thisGeneration[1])
				g2 = deepcopy(thisGeneration[2])
                g.age = thisGeneration[1].age
				g2.age = thisGeneration[2].age
				push!(model.population, g)
	            push!(model.pop_data, EntityData(g, model.gen_num))
				push!(model.population, g2)
	            push!(model.pop_data, EntityData(g2, model.gen_num))

                length += 2;
            end

			for i in length:2:model.initial_pop_size
				pidx1 = rouletteSelection()
				pidx2 = rouletteSelection()
				Genome parent1, parent2, child1, child2;
                parent1 = thisGeneration[pidx1]
                parent2 = thisGeneration[pidx2]

                if (rand() < 0.7)
					child1, child2 = model.ga.crossover(Any[parent1, parent2])
					#parent1.Crossover(ref parent2, out child1, out child2);
                else
                    child1, child2 = parent1, parent2
                end
				#model.ga.mutate(child1)
				#model.ga.mutate(child2)
				push!(model.population, child1)
	            push!(model.pop_data, EntityData(child1, model.gen_num))
	            push!(model.population, child2)
	            push!(model.pop_data, EntityData(child2, model.gen_num))
			end

            # Expand genomes.
            if ( length(model.population[0]) != length(thisGeneration[0]))
				newGenomeSize = length(model.population[0])
				for m in model.population
					if length(m) != newGenomeSize
						model.ga.expand(m, newGenomeSize)
					end
				end
            end
		end

		function runga(model::GAmodel; resume = false)
			stop = false
			params :: GAParams = model.ga.specific_fitness.getparams()

			_expandAmount = 0
			_expandRate = 5000

			if (!resume)
				//  Create the fitness table.
				#params.fitnessTable = new List<double>();
				#params.ThisGeneration = new List<Genome>(params.generations);
				#params.nextGeneration = new List<Genome>(params.generations);
				params.totalFitness = 0;
				params.targetFitness = 0;
				params.targetFitnessCount = 0;
				params.currentGeneration = 0;
				stop = false;

				reset_model(model)
		        create_initial_population(model)
				evaluate_population(model)
			end

			while (params.currentGeneration < params.generations && !Stop)
				#CreatenextGeneration();
				crossover_population(model, [])
				evaluate_population(model)
				fitness = model.population[1]
				#double fitness = RankPopulation();

				@async if model.gen_num % 50 == 0
	                print("Gen : $(model.gen_num) , ")
	                print("BEST: ", model.population[1].fitness , " , ")
	                print("SECOND: ", model.population[2].fitness, " , ")
	                print(" fini : $finished \n")
	                if model.gen_num % 500 ==0
	                    show_simulation(model, model.population[1])
	                end
	            end

				#=if (params.currentGeneration % 100 == 0)
				{
					Console.WriteLine("Generation " + params.currentGeneration + ", Time: " + Math.Round((DateTime.Now - _lastEpoch).TotalSeconds, 2) + "s, Best Fitness: " + fitness);

					if (params.historyPath != "")
					{
						// Record history timeline.
						File.AppendAllText(params.historyPath, DateTime.Now.ToString() + "," + fitness + "," + params.targetFitness + "," + params.currentGeneration + "\r\n");
					}

					_lastEpoch = DateTime.Now;
				}=#

				if (params.targetFitness > 0 && fitness >= params.targetFitness)
					params.targetFitnessCount = params.targetFitnessCount +1
					if (params.targetFitnessCount > 500)
						break;
					end
				else
					params.targetFitnessCount = 0;
				end

				#=if (OnGenerationFunction != null)
					OnGenerationFunction(this);
				end=#
				if (_expandAmount > 0 && params.currentGeneration > 0 && params.currentGeneration % _expandRate == 0 && params.genomeSize < params.maxGenomeSize )
	                _genomeSize += params.genomeSize + _expandAmount;
	                params.genomeSize = _genomeSize;

	                #_bestStatus.Fitness = 0; // Update display of best program, since genome has changed and we have a better/worse new best fitness.
	            end

				params.currentGeneration = params.currentGeneration + 1
			end
			model
		end



		## <summary>
		## Event handler that is called upon each generation. We use this opportunity to display some status info and save the current genetic algorithm in case of crashes etc.
		## </summary>
		function OnGeneration(model, _bestStatus)
			if (_bestStatus.Iteration++ > 1000)
			{
				_bestStatus.Iteration = 0;
				Console.WriteLine("Best Fitness: " + _bestStatus.TrueFitness + "/" + _targetParams.TargetFitness + " " + Math.Round(_bestStatus.TrueFitness / _targetParams.TargetFitness * 100, 2) + "%, Ticks: " + _bestStatus.Ticks + ", Total Ticks: " + _bestStatus.TotalTicks + ", Running: " + Math.Floor((DateTime.Now - _startTime).TotalSeconds / 60) + "m " + Math.Round(((DateTime.Now - _startTime).TotalSeconds % 60)) + "s, Size: " + _genomeSize + ", Best Output: " + _bestStatus.Output + ", Changed: " + _bestStatus.LastChangeDate.ToString() + ", Program: " + _bestStatus.Program);

				model.Save("my-genetic-algorithm.dat");
			}

			if (_expandAmount > 0 && model.GAParams.CurrentGeneration > 0 && model.GAParams.CurrentGeneration % _expandRate == 0 && _genomeSize < _maxGenomeSize)
			{
				_genomeSize += _expandAmount;
				model.GAParams.GenomeSize = _genomeSize;

				_bestStatus.Fitness = 0; // Update display of best program, since genome has changed and we have a better/worse new best fitness.
			}
		end

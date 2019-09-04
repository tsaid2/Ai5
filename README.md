# Ai5

This algorithm is based on Ai Pogrammer: an Ai developed in C# by Kory Becker using Genetic Algorithms to generate brainfuck code.
See its Github repository which refers to its article: https://github.com/primaryobjects/AI-Programmer.

Ai5 is therefore the version of Ai Programmer in Julia.

## The architecture of the algorithm : 

 List of modules of the GA:
 	- GeneticAlgorithms: this module is the GA Manager. It does every operation of the global algorithm: evaluate and crossover population, write on the log file, decide when the genome size has to be expanded and when the algorithm has to stop.
	- bfga: this module performs all unit operations on individuals: creates, mutates individuals, decodes the Brainfuck from genome.
	- Bf: the embedded Brainfuck interpreter
	- bfgaAdd: this type of file represents the fitness function associated with the "addition" operation. It also contains the initial parameters of individuals (genome size, etc). The GA can be started from this file by calling the "test\_serial" method.
	- Types.jl : This file contains 2 types: GAmodel which is used by GeneticAlgorithms to manage the GA and GAParams, used by the different fitness functions to give the desired initial parameters.

## Use the algorithm : 
To use the algorithm, you must implement the fitness function corresponding to your task. For the illustration, we will use the fitness function of length(::String) which we call bfgaLengthString in the src/ folder.

It is then necessary to implement 4 functions:
	- fitness: assigns a score to a program according to its execution within the embedded interpreter :
		```
		output, m_Ticks = execute(ent.program, input, instructionsSet)
		score = 0
		n= length(output)
		diff = output[1] - goal
		score = 256 - abs(diff) #+ (diff == 0 ? 0 : (diff > 0 ? -1 : -2) )
		ent.bonus += (2000 - m_Ticks)
		abs(score)
		```
		A bonus can be earned according to criteria you choose. Here it's about the number of executions within the interpreter.
	- simulate_entity: the simulation function that will display performances of the best algorithms every 1000 generations.
	- getTargetFitness() : return the target fitness
	- getParams(): returns a GAParams object (see Types.jl) that specifies the initial parameters of the algorithm: population size, maximum number of generations, genome size and its maximum, log file, etc.
	
Do not forget to build the input/output set illustrating the task to be accomplished.
	


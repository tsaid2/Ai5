# Ai5

This algorithm is based on Ai Pogrammer: an Ai developed in C# by Kory Becker using Genetic Algorithms to generate brainfuck code.
See its Github repository which refers to the Becker's article: https://github.com/primaryobjects/AI-Programmer.

Ai5 is therefore the version of Ai Programmer in Julia without the extended-III Brainfuck.

## The architecture of the algorithm : 

 List of modules of the GA:
 <ul>
<li>GeneticAlgorithms: this module is the GA Manager. It does every operation of the global algorithm: evaluate and crossover population, write on the log file, decide when the genome size has to be expanded and when the algorithm has to stop.</li>
<li>bfga: this module performs all unit operations on individuals: creates, mutates individuals, decodes the Brainfuck from genome.</li>
<li>Bf: the embedded Brainfuck interpreter. </li>
<li>bfgaAdd: this type of file represents the fitness function associated with the "addition" operation. It also contains the initial parameters of individuals (genome size, etc). The GA can be started from this file by calling the "test\_serial" method.</li>
<li>Types.jl : This file contains 2 types: GAmodel which is used by GeneticAlgorithms to manage the GA and GAParams, used by the different fitness functions to give the desired initial parameters.</li>
</ul>

## Use the algorithm : 

### The fitness function
To use the algorithm, you must implement the fitness function corresponding to your task. For the illustration, we will use the fitness function of length(::String) which we call bfgaLengthString in the src/ folder.

It is then necessary to implement 4 functions:
<ul>
<li>fitness: assigns a score to a program according to its execution within the embedded interpreter :
	
		```
		output, m_Ticks = execute(ent.program, input, instructionsSet)
		score = 256 - abs(output[1] - goal) 
		ent.bonus += (2000 - m_Ticks)
		abs(score)
		```
		
A bonus can be earned according to criteria you choose. Here it's about the number of executions within the interpreter.</li>
<li>simulate_entity: the simulation function that will display performances of the best algorithms every 1000 generations.</li>
<li>getTargetFitness() : return the target fitness</li>
<li>getParams(): returns a GAParams object (see Types.jl) that specifies the initial parameters of the algorithm: population size, maximum number of generations, genome size and its maximum, log file, etc.</li>
</ul>

Do not forget to build the input/output set illustrating the task to be accomplished.

Pour lancer le GA avec ta fitness function, Vous appelez ```GeneticAlgorithms.runga(bfga, bfgaLengthString)```. GeneticAlgorithms va alors utiliser le module bfga pour les opérations sur les programmes (mutations, crossover etc.) et bfgaLengthString pour la fonction de fitness.
To start the GA with your fitness function, you call ```GeneticAlgorithms.runga(bfga, bfgaLengthString)```. GeneticAlgorithms will use the bfga module for program unit operations (mutations, crossover with an other program, etc.) and bfgaLengthString for the fitness function.

### Change unit operations
To change unit operations, you can copy (or not) bfga.jl and change the body of functions that interest you.

### Run Tests
Finally, you can write a test file in the test/ folder to check the partial correctness of the returned program. In those given in this repository, the format is runtestLengthString.

## Results



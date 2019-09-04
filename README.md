# Ai5

Cette algorithme s'inspire de Ai Pogrammer : une Ai développée par Kory Becker utilisant en son des algorithme génétique pour générer du code brainfuck.
Voir son répository Github qui renvoie lui-meme vers son article: https://github.com/primaryobjects/AI-Programmer.

Ai5 est donc la version de Ai Programmer en Julia.

##L'architecture de la fonction : 

List of modules of the GA:
    - GeneticAlgorithms: this module is the GA Manager. It does every operation of the global algorithm: evaluate and crossover population, write on the log file, decide when the genome size has to be expanded and when the algorithm has to stop.
    \item \textbf{bfga}: this module performs all unit operations on individuals: creates, mutates individuals, decodes the Brainfuck from genome.
    \item \textbf{Bf}: the Brainfuck interpreter
    \item \textbf{bfgaAdd}: this type of file represents the fitness function associated with the "addition" operation. It also contains the initial parameters of individuals (genome size, etc). The GA can be started from this file by calling the "test\_serial" method.
\end{itemize}

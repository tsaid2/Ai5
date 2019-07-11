

###### TODO This file helped to refactor Bf.jl in the dir src but it doesn't executed !! ##
## <summary>
## This is the brainfuck interpreter.
##
## > 	Increment the pointer.
## < 	Decrement the pointer.
## + 	Increment the byte at the pointer.
## - 	Decrement the byte at the pointer.
## . 	Output the byte at the pointer.
## , 	Input a byte and store it in the byte at the pointer.
## [ 	Jump forward past the matching ] if the byte at the pointer is zero.
## ] 	Jump backward to the matching [ unless the byte at the pointer is zero.
##
## Extended commands, included in BrainPlus.
## @   Exits the program or if inside a function, return to prior position in main program and restore state.
## $   Overwrites the byte in storage with the byte at the pointer.
## !   Overwrites the byte at the pointer with the byte in storage.
## a,b Call function a - z.
## 0-F Sets the value of the current memory pointer to a multiple of 16.
## *   Sets the return value of a function to the value at the current memory pointer; parent storage will get return value.
## </summary>
module Interpreter
    #region Private Members

    ## <summary>
    ## Object used to swap state for a function call. This data is restored when the function terminates.
    ## </summary>
    mutable struct FunctionCallObj
        InstructionPointer :: Int
        DataPointer :: Int
        FunctionInputPointer :: Int
        #public Stack<int> CallStack #TODO
        ExitLoop :: Bool
        ExitLoopInstructionPointer :: Int
        Ticks :: Int
        char Instruction :: Char
        byte Storage :: UInt8
        byte? ReturnValue :: Char
        MaxIterationCount :: Int
    end

    struct This

        ## <summary>
        ## The "call stack"
        ## </summary>
        #private readonly Stack<int> m_CallStack = new Stack<int>();
        #TODO

        ## <summary>
        ## The input function
        ## </summary>
        m_Input :: String;

        ## <summary>
        ## The instruction set
        ## </summary>
        #private readonly IDictionary<char, Action> m_InstructionSet = new Dictionary<char, Action>();
        m_InstructionSet :: Dict() # = Dict()

        ## <summary>
        ## The memory of the program
        ## </summary>
        m_Memory :: Array{Int,1} # = [0 for i=1:32768]

        ## <summary>
        ## The output function
        ## </summary>
        m_Output :: Array{Char,1} # = []

        ## <summary>
        ## The program code
        ## </summary>
        m_Source :: Array{Char,1} # = []

        ## <summary>
        ## The data pointer
        ## </summary>
        m_DataPointer:: Int # = 0

        ## <summary>
        ## The instruction pointer
        ## </summary>
        m_InstructionPointer :: Int # = 1

        ## <summary>
        ## Boolean flag to indicate if we should skip the loop and continue execution at the next valid instruction. Used if the pointer is zero and a begin loop [ instruction is read, in which case we jump forward past the matching ].
        ## </summary>
        m_ExitLoop :: Bool # =  false

        ## <summary>
        ## Holds the instruction pointer for the start of the loop. Used to bypass all inner-loops when searching for the end of the current loop.
        ## </summary>
        m_ExitLoopInstructionPointer :: Int # = 0

        ## <summary>
        ## The list of functions and their starting instruction index.
        ## </summary>
        #private readonly Dictionary<char, FunctionInst> m_Functions = new Dictionary<char, FunctionInst>();
        m_Functions :: Dict # = Dict()

        ## <summary>
        ## Identifier for next function. Will serve as the instruction to call this function.
        ## </summary>
        m_NextFunctionCharacter :: Char

        ## <summary>
        ## The function "call stack".
        ## </summary>
        #private readonly Stack<FunctionCallObj> m_FunctionCallStack = new Stack<FunctionCallObj>();
        #TODO
        m_FunctionCallStack ::Array

        ## <summary>
        ## Pointer to the current call stack (m_FunctionCallStack or m_CallStack).
        ## </summary>
        #private Stack<int> m_CurrentCallStack;
        # TODO
        m_CurrentCallStack :: Int

        ## <summary>
        ## Pointer to a function's parent memory. When an input (,) command is executed from within a function, the function's current memory cell gets a copy of the value of the parent memory at this pointer. This allows passing multiple values as input to a function.
        ## For example: ++>++++>+<<a!.@,>,-[-<+>]<+$@
        ## Parent memory contains: 2, 4, 1. Function will contain: 2, 4 and store a value of 6 in storage. Resulting parent memory remains: 2, 4, 1. Upon next command !, parent memory will contain: 6, 4, 1. The value 6 is then displayed as output.
        ## </summary>
        m_FunctionInputPointer :: Int

        ## <summary>
        ## Number of cells available to functions. When a function is executed, an array of cells are allocated in upper-addresses (eg., 1000-1999, 2000-2999, etc.) for usage.
        ## </summary>
        _functionSize :: Int

        ## <summary>
        ## Max number of iterations for a program or function to run. Can be custom specified within a function using the syntax: @maxit=1234|function_code_here
        ## </summary>
        m_MaxIterationCount :: Int

        ## <summary>
        ## Storage memory value. Usually used to hold return values from function calls.
        ## </summary>
        m_Storage :: Int

        ## <summary>
        ## Function return value. Set by using * command (instead of print . command).
        ## </summary>
        m_ReturnValue :: UInt8

        ## <summary>
        ## Options for function behavior in the interpreter.
        ## </summary>
        #private Function[] m_Options = null;
        #TODO
        m_Options :: Array

        #endregion

        #region Public Members

        ## <summary>
        ## Number of instructions executed within the main program or the current function.
        ## </summary>
        m_Ticks :: Int

        ## <summary>
        ## Number of total instructions executed, including within functions.
        ## </summary>
        m_TotalTicks :: Int

        ## <summary>
        ## Flag to stop execution of the program.
        ## </summary>
        m_Stop :: Bool


        ## <summary>
        ## List of executed functions in the main program. Used for reference purposes by the GA to determine which functions were executed in the program (not functions calling other functions).
        ## </summary>
        #public Dictionary<char, int> m_ExecutedFunctions = new Dictionary<char, int>();
        m_ExecutedFunctions :: Dict

        This() = new("", Dict(), [0 for i=1:32768], [], [], 0, 1, false, 0,
        Dict(), 'a', [], 0, 0, 300, 0, 0, 0, [], 0, 0, false, Dict() )
    end

    ## <summary>
    ## Read-only access to the current data pointer index in memory.
    ## </summary>
    m_CurrentDataPointer() = m_DataPointer # { get { return m_DataPointer; } }

    ## <summary>
    ## Read-only access to the current instruction pointer index.
    ## </summary>
    #m_CurrentInstructionPointer{ get { return m_InstructionPointer; } }
    m_CurrentInstructionPointer() = m_InstructionPointer

    ## <summary>
    ## True if a function is currently running. False if the main program is running.
    ## </summary>
    #public bool IsInsideFunction { get { return m_FunctionCallStack.Count > 0; } }
    # TODO IsInsideFunction() = m_FunctionCallStack.Count > 0

    ## <summary>
    ## True if currently inside a loop []. False otherwise. Note, check IsInsideFunction to tell if this is a loop within a function or the main program.
    ## </summary>
    #public bool IsInsideLoop { get { return m_CurrentCallStack.Count > 0; } }
    # TODO

    ## <summary>
    ## The name of the currently executing function or null.
    ## </summary>
    #public char? m_CurrentFunction { get { if (IsInsideFunction) return m_FunctionCallStack.Peek().Instruction; else return null; } }
    #TODO



    #endregion

    ## <summary>
    ## Constructor
    ## </summary>
    ## <param name="programCode"></param>
    ## <param name="input">Function to call when input command (,) is executed.</param>
    ## <param name="output">Function to call when output command (.) is executed.</param>
    ## <param name="function">Callback handler to notify that a function is being executed: callback(instruction).</param>
    ## <param name="options">Additional interpreter options.</param>
    function Interpreter(programCode :: String, input :: Array{UInt8,1}, Action<byte> output; Action<char> function = null, Function[] options = null)
        // Save the program code
        this = This()
        this.m_Source = collect(programCode) #programCode.ToCharArray();

        // Store the i/o delegates
        this.m_Input = input;
        this.m_Output = output;

        // Set any additional options.
        if (options != null)
        {
            this.m_Options = options;
        }

        m_CurrentCallStack = m_CallStack;

        // Create the instruction set for Basic Brainfuck.
        this.m_InstructionSet['+'] = () -> ( (!this.m_ExitLoop) ? this.m_Memory[this.m_DataPointer] += 1 )
        this.m_InstructionSet['+'] = () -> ( (!this.m_ExitLoop) ? this.m_Memory[this.m_DataPointer] -= 1 )

        this.m_InstructionSet.Add('+', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer]++; });
        this.m_InstructionSet.Add('-', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer]--; });

        this.m_InstructionSet.Add('>', () => { if (!m_ExitLoop) this.m_DataPointer++; });
        this.m_InstructionSet.Add('<', () => { if (!m_ExitLoop) this.m_DataPointer--; });

        this.m_InstructionSet.Add('.', () => { if (!m_ExitLoop) this.m_Output(this.m_Memory[this.m_DataPointer]); });

        // Prompt for input. If inside a function, pull input from parent memory, using the current FunctionInputPointer. Each call for input advances the parent memory cell that gets read from, allowing the passing of multiple values as input to a function.
        this.m_InstructionSet.Add(',', () => { if (!m_ExitLoop) m_Memory[this.m_DataPointer] = IsInsideFunction ? this.m_Memory[this.m_FunctionInputPointer++] : this.m_Input(); });

        this.m_InstructionSet.Add('[', () =>
        {
            if (!m_ExitLoop && this.m_Memory[this.m_DataPointer] == 0)
            {
                // Jump forward to the matching ] and exit this loop (skip over all inner loops).
                m_ExitLoop = true;

                // Remember this instruction pointer, so when we get past all inner loops and finally pop this one off the stack, we know we're done.
                m_ExitLoopInstructionPointer = this.m_InstructionPointer;
            }

            this.m_CurrentCallStack.Push(this.m_InstructionPointer);
        });
        this.m_InstructionSet.Add(']', () =>
        {
            var temp = this.m_CurrentCallStack.Pop();

            if (!m_ExitLoop)
            {
                this.m_InstructionPointer = this.m_Memory[this.m_DataPointer] != 0
                    ? temp - 1
                    : this.m_InstructionPointer;
            }
            else
            {
                // Continue executing after loop.
                if (temp == m_ExitLoopInstructionPointer)
                {
                    // We've finally exited the loop.
                    m_ExitLoop = false;
                    m_ExitLoopInstructionPointer = 0;
                }
            }
        });

        // Create the instruction set for Brainfuck Extended Type 3.
        this.m_InstructionSet.Add('0', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 0; });
        this.m_InstructionSet.Add('1', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 16; });
        this.m_InstructionSet.Add('2', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 32; });
        this.m_InstructionSet.Add('3', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 48; });
        this.m_InstructionSet.Add('4', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 64; });
        this.m_InstructionSet.Add('5', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 80; });
        this.m_InstructionSet.Add('6', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 96; });
        this.m_InstructionSet.Add('7', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 112; });
        this.m_InstructionSet.Add('8', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 128; });
        this.m_InstructionSet.Add('9', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 144; });
        this.m_InstructionSet.Add('A', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 160; });
        this.m_InstructionSet.Add('B', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 176; });
        this.m_InstructionSet.Add('C', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 192; });
        this.m_InstructionSet.Add('D', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 208; });
        this.m_InstructionSet.Add('E', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 224; });
        this.m_InstructionSet.Add('F', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = 240; });
        this.m_InstructionSet.Add('*', () => { if (!m_ExitLoop) this.m_ReturnValue = this.m_Memory[this.m_DataPointer]; });
        this.m_InstructionSet.Add('@', () =>
        {
            if (IsInsideFunction)
            {
                // Exit function.
                var temp = m_FunctionCallStack.Pop();

                // Restore the data pointer.
                this.m_DataPointer = temp.DataPointer;

                /*if (this.m_ReturnValue.HasValue)
                {
                    this.m_Memory[this.m_DataPointer] = this.m_ReturnValue.Value;
                }*/

                // Restore the call stack.
                this.m_CurrentCallStack = temp.CallStack;
                // Restore exit loop status.
                this.m_ExitLoop = temp.ExitLoop;
                // Restore exit loop instruction pointer.
                this.m_ExitLoopInstructionPointer = temp.ExitLoopInstructionPointer;
                // Restore ticks.
                this.m_Ticks = temp.Ticks;
                // Restore global storage.
                this.m_Storage = this.m_ReturnValue.HasValue ? this.m_ReturnValue.Value : temp.Storage;
                // Restore parent return value.
                this.m_ReturnValue = temp.ReturnValue;
                // Restore max iteraction count.
                this.m_MaxIterationCount = temp.MaxIterationCount;
                // Restore the instruction pointer.
                this.m_InstructionPointer = temp.InstructionPointer;
                // Restore function input pointer.
                this.m_FunctionInputPointer = temp.FunctionInputPointer;
            }
            else
            {
                // Exit program.
                this.m_Stop = true;
            }
        });
        this.m_InstructionSet.Add('$', () =>
        {
            if (!m_ExitLoop)
            {
                // If we're inside a function, use the function's own global storage (separate from the main program).
                // However, if this is the last storage command in the function code, then use the main/calling-function storage, to allow returning a value.
                if (IsInsideFunction && this.m_Source[m_InstructionPointer + 1] == '@')
                {
                    // Set function return value.
                    this.m_ReturnValue = this.m_Memory[this.m_DataPointer];
                }
                else
                {
                    // Set global storage for this main program or function.
                    this.m_Storage = this.m_Memory[this.m_DataPointer];
                }
            }
        });

        this.m_InstructionSet.Add('!', () => { if (!m_ExitLoop) this.m_Memory[this.m_DataPointer] = this.m_Storage; });

        // Scan code for function definitions and store their starting memory addresses.
        ScanFunctions(programCode);

        // If we found any functions, create the instruction set for them.
        for (char inst = 'a'; inst < m_NextFunctionCharacter; inst++)
        {
            char instruction = inst; // closure
            this.m_InstructionSet.Add(instruction, () =>
            {
                if (!m_ExitLoop)
                {
                    // Record a list of executed function names from the main program (not a function calling another function).
                    if (!IsInsideFunction)
                    {
                        if (m_ExecutedFunctions.ContainsKey(instruction))
                        {
                            m_ExecutedFunctions[instruction]++;
                        }
                        else
                        {
                            m_ExecutedFunctions.Add(instruction, 1);
                        }
                    }

                    if (function != null)
                    {
                        // Notify caller of a function being executed.
                        function(instruction);
                    }

                    // Store the current instruction pointer and data pointer before we move to the function.
                    var functionCallObj = new FunctionCallObj { InstructionPointer = this.m_InstructionPointer, DataPointer = this.m_DataPointer, FunctionInputPointer = this.m_FunctionInputPointer, CallStack = this.m_CurrentCallStack, ExitLoop = this.m_ExitLoop, ExitLoopInstructionPointer = this.m_ExitLoopInstructionPointer, Ticks = this.m_Ticks, Instruction = instruction, Storage = this.m_Storage, ReturnValue = this.m_ReturnValue, MaxIterationCount = this.m_MaxIterationCount };
                    this.m_FunctionCallStack.Push(functionCallObj);

                    // Give the function a fresh call stack.
                    this.m_CurrentCallStack = new Stack<int>();
                    this.m_ExitLoop = false;
                    this.m_ExitLoopInstructionPointer = 0;

                    // Initialize the function global storage.
                    this.m_Storage = 0;
                    this.m_ReturnValue = null;

                    // Load options for this function.
                    FunctionInst functionOptions = m_Functions[instruction];

                    // Set the function input pointer to the parent's starting memory. Calls for input (,) from within the function will read from parent's memory, each call advances the parent memory cell that gets read from. This allows passing multiple values to a function.
                    // Note, if we set the starting m_FunctionInputPointer to 0, functions will read from the first input position (0).
                    // If we set it to m_DataPointer, functions will read input from the current position in the parent memory (n). This is trickier for the GA to figure out, because it may have to downshift the memory back to 0 before calling the function so that the function gets all input. Setting this to 0 makes it easier for the function to get the input.
                    this.m_FunctionInputPointer = functionOptions.ReadInputAtMemoryStart ? 0 : this.m_DataPointer;

                    // Set the data pointer to the functions starting memory address.
                    this.m_DataPointer = _functionSize * (instruction - 96); // each function gets a space of 1000 memory slots.

                    // Clear function memory.
                    Array.Clear(this.m_Memory, this.m_DataPointer, _functionSize);

                    // Set ticks to 0.
                    this.m_Ticks = 0;

                    // Set the max iteration count for this function, if one was specified.
                    this.m_MaxIterationCount = functionOptions.MaxIterationCount > 0 ? functionOptions.MaxIterationCount : this.m_MaxIterationCount;

                    // Set the instruction pointer to the beginning of the function.
                    this.m_InstructionPointer = functionOptions.InstructionPointer;
                }
            });
        }
    end

    ## <summary>
    ## Run the program
    ## </summary>
    public void Run(int maxInstructions = 0)
    {
        m_Ticks = 0;
        m_TotalTicks = 0;
        m_Stop = false;

        if (maxInstructions > 0)
        {
            RunLimited(maxInstructions);
        }
        else
        {
            RunUnlimited();
        }
    }

    ## <summary>
    ## Run the program with a maximum number of instructions before throwing an exception. Avoids infinite loops.
    ## </summary>
    ## <param name="maxInstructions">Max number of instructions to execute</param>
    function runLimited(int maxInstructions)
        m_MaxIterationCount = maxInstructions;

        # Iterate through the whole program source
        while (this.m_InstructionPointer < this.m_Source.Length && !m_Stop)
            # Fetch the next instruction
            char instruction = this.m_Source[this.m_InstructionPointer];

            # See if that IS an instruction and execute it if so
            Action action;
            if (this.m_InstructionSet.TryGetValue(instruction, out action))
                # Yes, it was - execute
                action();
            end

            # Next instruction
            this.m_InstructionPointer++;

            # Have we exceeded the max instruction count?
            if (m_MaxIterationCount > 0 && m_Ticks >= m_MaxIterationCount)
                if (IsInsideFunction)
                    # We're inside a function, but ran out of instructions. Exit the function, but continue.
                    if (this.m_InstructionSet.TryGetValue('@', out action))
                        action();
                        this.m_InstructionPointer++;
                    end
                else
                    break;
                end
            end

            m_Ticks++;
            m_TotalTicks++;
        end
    end

    ## <summary>
    ## Run the program
    ## </summary>
    private void RunUnlimited()
    {
        // Iterate through the whole program source
        while (this.m_InstructionPointer < this.m_Source.Length && !m_Stop)
        {
            // Fetch the next instruction
            char instruction = this.m_Source[this.m_InstructionPointer];

            // See if that IS an instruction and execute it if so
            Action action;
            if (this.m_InstructionSet.TryGetValue(instruction, out action))
            {
                // Yes, it was - execute
                action();
            }

            // Next instruction
            this.m_InstructionPointer++;

            m_Ticks++;
            m_TotalTicks++;
        }
    }

    ## <summary>
    ## Pre-scan the program code to record function instruction pointers.
    ## </summary>
    private void ScanFunctions(string source)
    {
        this.m_InstructionPointer = source.IndexOf('@');
        while (this.m_InstructionPointer > -1 && this.m_InstructionPointer < source.Length - 1 && !m_Stop)
        {
            // Retrieve any settings for this function.
            Function functionDetail = m_Options != null && m_Options.Length > m_Functions.Count ? m_Options[m_Functions.Count] : null;

            // Store the function.
            m_Functions.Add(m_NextFunctionCharacter++, new FunctionInst(this.m_InstructionPointer, functionDetail));

            this.m_InstructionPointer = source.IndexOf('@', this.m_InstructionPointer + 1);
        }

        this.m_InstructionPointer = 0;
    }
end

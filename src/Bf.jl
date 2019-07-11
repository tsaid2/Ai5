# This work is extending the Svyatoslav Pidgorny's work https://github.com/SP3269/Julia-Playground
# I juste structured it and encapsulated operations and added some functions


module BfInterpreter

    #using ResumableFunctions

    export getInstructionsDict, bfType, runnable!, execute, bfVM, floatToBfInstruction, BracketError, MermoryBfVM, genesToBfInstructions

    struct BracketError <: Exception
        message :: String
    end

    struct MermoryBfVM <: Exception
        message :: String
    end


    mutable struct bfVM
        cells :: Array{UInt8,1}         # default value : [0 for i=1:15000]
        nbCells :: Int
        cellno :: Int64                 # Current cell number :: initial value : 1
        n :: Int64                      # length of the bf code
        m_InstructionPointer :: Int64   # Pointer to the current position in the code, initial_value : 1
        nbExecLimit :: Int32            # default value : 200000
        nbExec :: Int32                 # initial value : 0
        storage :: UInt8
        instructionDict #:: AbstractDict
        ignoreJump :: Bool
        ignoreComment :: Bool
        output :: Array{Char,1}         # Data returned
        input :: String
        indexInput :: Int
        l_input :: Int
        m_Stop :: Bool

        ## <summary>
        ## Holds the instruction pointer for the start of the loop. Used to bypass all inner-loops when searching for the end of the current loop.
        ## </summary>
        m_ExitLoopInstructionPointer :: Int # = 0

        m_CurrentCallStack :: Array

        #bfVM(n :: Int64) = new([0 for i=1:30000], 1, n, 1, 200000, 0)
    end


    function getInstructionsDict()
        instructionsSet = Dict()

        # Create the instruction set for Basic Brainfuck.
        instructionsSet['+'] = vm ->
            if (!vm.ignoreJump && !vm.ignoreComment)
                #@assert vm.cells[ vm.cellno] < 255
                if vm.cells[ vm.cellno] == 255
                    vm.cells[ vm.cellno] = 0 #vm.cells[ vm.cellno]+1
                    #throw(MermoryBfVM("Memory: 0 => 255 (cell $(vm.cellno), state $(vm.cells[vm.cellno]), cmd '+')"))
                else
                    vm.cells[ vm.cellno] +=  1
                end
                #vm.cells[ vm.cellno] = vm.cells[ vm.cellno]+1
            end
        instructionsSet['-'] = vm ->
            if (!vm.ignoreJump && !vm.ignoreComment)
                #@assert vm.cells[ vm.cellno] < 255
                if vm.cells[ vm.cellno] == 0
                    vm.cells[ vm.cellno] = 255 #vm.cells[ vm.cellno]+1
                    #throw(MermoryBfVM("Memory: 0 => 255 (cell $(vm.cellno), state $(vm.cells[vm.cellno]), cmd '+')"))
                else
                    vm.cells[ vm.cellno] -=  1
                end
                #vm.cells[ vm.cellno] = vm.cells[ vm.cellno]+1
            end
        instructionsSet['>'] = vm -> ((!vm.ignoreJump && !vm.ignoreComment) ?
            #=lcells = length(vm.cells)
            #@assert vm.cellno < lcells
            if vm.cellno == lcells
                throw(MermoryBfVM("Memory: 1 => 1 ($(vm.cells[1])) , $lcells => 1 ($(vm.cells[lcells]))"))
            end=#
            vm.cellno = vm.cellno + 1
            : nothing)
        instructionsSet['<'] = vm ->
            if !vm.ignoreJump && !vm.ignoreComment
                #=if vm.cellno == 1
                    lcells = vm.nbCells #length(vm.cells)
                    throw(MermoryBfVM("Memory: 1 => 1 ($(vm.cells[1])) , $lcells => 1 ($(vm.cells[lcells]))"))
                end=#
                #@show vm.cellno
                vm.cellno = vm.cellno - 1
            end
        instructionsSet['.'] = vm -> ((!vm.ignoreJump && !vm.ignoreComment) ?
            push!(vm.output, Char(vm.cells[vm.cellno]) )
            : nothing)
        #(@yield Char(vm.cells[vm.cellno]) ) : nothing
        instructionsSet[','] = vm ->
            if !vm.ignoreJump && !vm.ignoreComment
                if vm.indexInput <= vm.l_input # length(vm.input)
                    vm.cells[ vm.cellno] = UInt8(vm.input[vm.indexInput])
                    vm.indexInput += 1
                else
                    vm.cells[vm.cellno] = 0
                end
            end
        instructionsSet['['] = vm ->
            if !vm.ignoreComment
                if (!vm.ignoreJump && vm.cells[vm.cellno] == 0)
                    ## Jump forward to the matching ] and exit this loop (skip over all inner loops).
                    vm.ignoreJump = true;

                    ## Remember this instruction pointer, so when we get past all inner loops and finally pop this one off the stack, we know we're done.
                    vm.m_ExitLoopInstructionPointer = vm.m_InstructionPointer;
                end
                pushfirst!(vm.m_CurrentCallStack, vm.m_InstructionPointer)
                #this.m_CurrentCallStack.Push(vm.m_InstructionPointer);
            end
        instructionsSet[']'] = vm ->
            if !vm.ignoreComment
                temp = popfirst!(vm.m_CurrentCallStack) #vm.m_CurrentCallStack[end] #TODO

                if (!vm.ignoreJump)
                    vm.m_InstructionPointer = vm.cells[vm.cellno]!=0 ? temp -1 : vm.m_InstructionPointer
                elseif (temp == vm.m_ExitLoopInstructionPointer)
                    ## Continue executing after loop.
                    ## We've finally exited the loop.
                    vm.ignoreJump = false;
                    vm.m_ExitLoopInstructionPointer = 0;
                end
            end
        instructionsSet['$'] = vm ->  (!vm.ignoreJump && !vm.ignoreComment) ? (vm.storage = vm.cells[vm.cellno]) : nothing
        instructionsSet['!'] = vm ->  (!vm.ignoreJump && !vm.ignoreComment) ? (vm.cells[vm.cellno] = vm.storage) : nothing
        instructionsSet['@'] = vm -> (!vm.ignoreJump && !vm.ignoreComment) ? vm.m_Stop = true : nothing
        instructionsSet['%'] = vm -> (!vm.ignoreJump && !vm.ignoreComment) ? vm.cells[ vm.cellno] = trunc(UInt8, vm.cells[vm.cellno] % vm.storage) : nothing
        instructionsSet['/'] = vm -> (!vm.ignoreJump && !vm.ignoreComment) ? vm.cells[ vm.cellno] = trunc(UInt8, vm.cells[vm.cellno] / vm.storage) : nothing
        instructionsSet['*'] = vm -> (!vm.ignoreJump && !vm.ignoreComment) ? vm.cells[ vm.cellno] = trunc(UInt8, vm.cells[vm.cellno] * vm.storage) : nothing
        instructionsSet['#'] = vm -> (!vm.ignoreJump) ? (vm.ignoreComment = !vm.ignoreComment) : nothing

        instructionsSet
    end


    function execute(bfcode :: String, instructionSet )
        execute(bfcode, "", instructionSet)
    end

    function execute(bfcode :: String, input :: Array{Char,1}, instructionSet )
        execute(bfcode, join(input, ""), instructionSet)
    end

    function execute(bfcode :: String, input :: String, instructionSet )

        # initialize the vm
        vm = bfVM( [0 for i=1:2000], 2000, 1, length(bfcode),
                    0, 2000, -1 , 0, Dict(), false, false, [],
                     input, 1, length(input), false,  -1, [])


        #@show bfcode
        ignoreCharacter = vm.ignoreJump | vm.ignoreComment
        while vm.m_InstructionPointer< vm.n && vm.nbExec < vm.nbExecLimit &&  !vm.m_Stop
            vm.m_InstructionPointer = vm.m_InstructionPointer + 1
            vm.nbExec = vm.nbExec +1
            #global cellno
            #ignoreCharacter = ignoreJump | ignoreComment
            cmd = bfcode[ vm.m_InstructionPointer]
            try
                instructionSet[cmd](vm)
            catch y
                break
            end

            @debug "Executed $cmd at $m_InstructionPointer. Current cell # $(cellno)\t$(cells[cellno])"
        end
        vm.output, vm.nbExec
    end

    # Eliminating all extranious characters in the code
    function purifyCode(bfcode :: String)
        replace(bfcode, r"[^\+\-\<\>\.\,\[\]]" => s"")
    end
end

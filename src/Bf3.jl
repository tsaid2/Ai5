# This work is extending the Svyatoslav Pidgorny's work https://github.com/SP3269/Julia-Playground
# I juste structured it and encapsulated operations and added some functions


module BfInterpreter


    export bfType, runnable!, execute, bfVM, floatToBfInstruction, BracketError, MermoryBfVM, genesToBfInstructions

    struct BracketError <: Exception
        message :: String
    end

    struct MermoryBfVM <: Exception
        message :: String
    end

    struct bfType
        bfgenes :: Array{Float64,1}
        bfcode :: String # the code

        #bfType(bfcode :: Array{String,1}) = new([], bfcode )
        bfType(bfcode :: String) = new([], purifyCode(bfcode) )
        bfType(bfcode :: Array{Char, 1}) = new([], join(bfcode, "") )
        #bfType(bfgenes :: Array{Float64,1}) = new(bfgenes, genesToBfInstructions(bfgenes) )
    end

    mutable struct bfVM
        cells :: Array{UInt8,1} # default value : [0 for i=1:30000]
        cellno :: Int64 # Current cell number :: initial value : 1
        n :: Int64 # length of the bf code
        ptr :: Int64 # Pointer to the current position in the code, initial_value : 1
        nbExecLimit :: Int32 # default value : 200000
        nbExec :: Int32 # initial value : 0
        storage :: UInt8
        indexopen  :: Array{Any,1} # Array of the left sqare bracket positions
        indexclose :: Array{Any,1} # Array of the matching right square bracket positions

        #bfVM(n :: Int64) = new([0 for i=1:30000], 1, n, 1, 200000, 0)
    end


    #=function runnable!( bft :: bfType)
        n = length(bft.bfcode)
        brstack = [] # Stack for matching bracket positions
        for i=1:n
            if bft.bfcode[i] == '['
                append!(vm.indexopen,i)
                append!(vm.indexclose,0)
                mem = length( vm.indexopen )
                push!(brstack, mem)
                # println(stderr,"[ ", i, " ", length(indexo))
            elseif bft.bfcode[i] == ']'
                try
                    j = pop!(brstack)
                    vm.indexclose[j] = i
                catch
                    return false, -1*i
                end
                # println(stderr,"]", i, length(brstack))
            end
        end
        _result = (length(brstack) == 0)
        return ( _result, length(brstack) == 0 ? 0 : brstack[1] )
    end=#

    function incrementCell!(vm :: bfVM)
        #@assert vm.cells[ vm.cellno] < 255
        if vm.cells[ vm.cellno] == 255
            vm.cells[ vm.cellno] = 0 #vm.cells[ vm.cellno]+1
            #throw(MermoryBfVM("Memory: 0 => 255 (cell $(vm.cellno), state $(vm.cells[vm.cellno]), cmd '+')"))
        else
            vm.cells[ vm.cellno] = vm.cells[ vm.cellno]+  1
        end
        #vm.cells[ vm.cellno] = vm.cells[ vm.cellno]+1
    end

    function decrementCell!(vm :: bfVM)
        #@assert vm.cells[ vm.cellno] > 0
        if vm.cells[ vm.cellno] ==0
            vm.cells[ vm.cellno] = 255
            #throw(MermoryBfVM("Memory: 0 => 255 (cell $(vm.cellno), state $(vm.cells[vm.cellno]), cmd '-')"))
        else
            vm.cells[ vm.cellno] = vm.cells[ vm.cellno]-1
        end
        #vm.cells[ vm.cellno] = vm.cells[ vm.cellno]-1
    end

    function decrementDataPointer!(vm :: bfVM)
        #@assert vm.cellno > 1
        if vm.cellno == 1
            lcells = length(vm.cells)
            throw(MermoryBfVM("Memory: 1 => 1 ($(vm.cells[1])) , $lcells => 1 ($(vm.cells[lcells]))"))
        end
        #@show vm.cellno
        vm.cellno = vm.cellno -1
    end

    function incrementDataPointer!(vm :: bfVM)
        lcells = length(vm.cells)
        #@assert vm.cellno < lcells
        if vm.cellno == lcells
            throw(MermoryBfVM("Memory: 1 => 1 ($(vm.cells[1])) , $lcells => 1 ($(vm.cells[lcells]))"))
        end
        vm.cellno = vm.cellno + 1
    end

    function displayCell!(vm :: bfVM, output :: Array{Char,1})
        # values in the cells cannot be negative
        push!(output, displayCell(vm :: bfVM ) )
    end

    function displayCell(vm :: bfVM)
        try
            return Char(vm.cells[vm.cellno])
        catch y
            if y isa InexactError
                # Practically, this case can't be reached
                println("Fatal Error : la cell n° $(vm.cellno) has been violated")
                thow(y)
                #return vm.cells[vm.cellno]
            else
                println("Erreur inconnu au niveau de displayCell")
                @show y
            end
        end
        #print(Char(vm.cells[vm.cellno]))
    end

    function inputData!(vm :: bfVM, in :: UInt8)
        vm.cells[ vm.cellno] = in
    end

    function inputData!(vm :: bfVM)
        try
            print("Enter a token : ")
            in = readline()
            @show in
            inputData!(vm :: bfVM, parse(UInt8, in))
            #vm.cells[ vm.cellno] = parse(UInt8,in)
            # nullable parser of the input string; can use error handling here - expect number!
        catch y
            @show y
            println(" You have to enter an Integer or a Char (~)")
            print("Retry :")
            inputData!(vm)
        end
    end

    function execute(bfcode :: String)
        execute(bfcode, "")
    end

    function execute(bft :: bfType, input :: String)
        execute(bft.bfcode, input)
    end

    function execute(bft :: bfType)
        execute(bft.bfcode, "")
    end

    function execute(bft :: bfType, input :: Array{Char,1})
        execute(bft.code, join(input, ""))
    end

    function execute(bfcode :: String, input :: Array{Char,1})
        execute(bfcode, join(input, ""))
    end

    function execute(bfcode :: String, input :: String)
        l_input = length(input)
        k = 1

        ignoreJump = false
        cacheBracket = 0
        ignoreComment = false

        # initialize the vm
        # 30000 cases, 5000 max executions
        vm = bfVM( [0 for i=1:30000], 1, length(bfcode), 0, 5000, -1 , 0, [], [])

        # Data returned
        output :: Array{Char,1} = []

        brstack = []
        #@show bfcode
        ignoreCharacter = ignoreJump | ignoreComment
        while vm.ptr< vm.n && vm.nbExec < vm.nbExecLimit # && vm.ptr < stop
            vm.ptr = vm.ptr+1
            vm.nbExec = vm.nbExec +1
            #global cellno
            #ignoreCharacter = ignoreJump | ignoreComment
            cmd = bfcode[ vm.ptr]
            if cmd =='#'
                ignoreComment = !ignoreComment
            elseif ignoreComment
                continue
            elseif cmd=='['
                if ignoreJump
                    cacheBracket +=1
                elseif vm.cells[ vm.cellno]==0
                    ignoreJump = true
                    cacheBracket= 0
                    #vm.ptr = vm.indexclose[findfirst(isequal(vm.ptr), vm.indexopen)]
                else
                    append!(vm.indexopen, vm.ptr)
                    append!(vm.indexclose,0)
                    mem = length( vm.indexopen )
                    push!(brstack, mem)

                end
            elseif cmd==']'
                if ignoreJump && cacheBracket > 0
                    cacheBracket -=1
                elseif ignoreJump && cacheBracket == 0
                    ignoreJump = false
                    continue
                else
                    try
                        j = pop!(brstack)
                        vm.indexclose[j] = vm.ptr

                        if vm.cells[vm.cellno]!=0
                            push!(brstack, j)
                            vm.ptr = vm.indexopen[findfirst(isequal(vm.ptr),vm.indexclose)]
                        else
                            continue
                        end
                    catch
                        break
                    end
                end
            elseif ignoreJump
                continue
            elseif cmd=='+'
                incrementCell!(vm)
            elseif cmd=='-'
                decrementCell!(vm)
            elseif cmd=='>'
                incrementDataPointer!(vm)
            elseif cmd=='<'
                decrementDataPointer!(vm)
            elseif cmd=='.'
                displayCell!(vm, output)
                #push!(output, displayCell(vm :: bfVM) )
                #displayCell!(vm , output)
                #print(Char(vm.cells[vm.cellno]))
            elseif cmd==','
                #inputData!(vm)
                if k <= l_input
                    inputData!(vm, UInt8(input[k]))
                end
                k += 1
            elseif cmd=='*'
                inputData!(vm, trunc(UInt8, vm.cells[vm.cellno] * vm.storage))
            elseif cmd=='%'
                inputData!(vm, trunc(UInt8, vm.cells[vm.cellno] * vm.storage))
            elseif cmd=='/'
                inputData!(vm, trunc(UInt8, vm.cells[vm.cellno] / vm.storage))
            elseif cmd=='$'
                vm.storage = vm.cells[vm.cellno]
            elseif cmd=='!'
                vm.cells[vm.cellno] = vm.storage
            elseif cmd == '@'
                break
            end
            @debug "Executed $cmd at $ptr. Current cell # $(cellno)\t$(cells[cellno])"
        end
        #println("\n")
        #join(output, "")
        output
    end

    # Eliminating all extranious characters in the code
    function purifyCode(bfcode :: String)
        replace(bfcode, r"[^\+\-\<\>\.\,\[\]]" => s"")
    end
end

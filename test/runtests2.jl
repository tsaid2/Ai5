
#= include("testga.jl")
using .testga =#
#include("equalityga.jl")
#using .equalityga
include("../src/bfgaHelloWorld.jl")
using .bfgaHelloWorld
#include("../src/bfgaRepeat.jl")
#using .bfgaRepeat
#include("../src/bfgaReverseString.jl")
#using .bfgaReverseString

test_serial()
#test_parallel()

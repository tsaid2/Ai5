using Test
using Random
using LinearAlgebra
#Random.seed!(9874984737484)

for tests in [
            "runtestAdd.jl",
			#TODO"runtestLogicalOr.jl",
			#"runtestLogicalXor.jl",
			#"runtestReverseString.jl",
			#"runtestLengthString.jl"
			#"runtestString.jl",
			#"runtestLogicalAnd.jl",
			#"runtestRepeat.jl",
            #"runtestLogicalAnd.jl"
]
    include(tests)
end

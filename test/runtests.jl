using Test
using Random
#using LinearAlgebra
#Random.seed!(9874984737484)

for tests in [
            #"runtestAdd.jl", 			# pb
			#"runtestLogicalOr.jl",		#
			#"runtestLogicalXor.jl", 	#
			#"runtestReverseString.jl",	# pb, don't know why it doesn't work, working on
			#"runtestLengthString.jl"	#
			"runtestString.jl",		#
			"runtestLogicalAnd.jl",		#
			"runtestRepeat.jl",		#
]
    include(tests)
end

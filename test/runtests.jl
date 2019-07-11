using Test
using Random
#using LinearAlgebra
#Random.seed!(9874984737484)

for tests in [
            #"runtestAdd.jl", 			# pb
			#"runtestLogicalOr.jl",		#
			#"runtestLogicalXor.jl", 	#
			"runtestReverseString.jl",	# wroked once, pb, don't know why it doesn't work, working on
			#"runtestLengthString.jl"	# work twice and didn't try since
			#"runtestString.jl",		# work sure
			#"runtestLogicalAnd.jl",	# wrok with extended sure
			#"runtestRepeat.jl",		# work sure
]
    include(tests)
end

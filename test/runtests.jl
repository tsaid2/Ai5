using Test
using Random
#using LinearAlgebra
#Random.seed!(9874984737484)

for tests in [
			#"runtestString.jl",		# work sure
            #"runtestAdd.jl", 			#
			#"runtestLogicalOr.jl",		#
			#"runtestLogicalXor.jl", 	#
			#"runtestReverseString.jl",	# worked twice, pb, don't know why it doesn't work, working on
			#"runtestLengthString.jl",	# work twice and didn't try since
			#"runtestTimesTwo.jl",		# work sure
			#"runtestTimesThree.jl"
			#"runtestLogicalAnd.jl",	# wrok with extended sure
			#"runtestRepeat.jl",		# work sure
			#"runtestWarningCountdown.jl" # Doesn't work, NENI
			#"runtestExtractInQuote.jl",
			#"runtestExtractInQuoteInside.jl"
			"runtestFibonacci.jl"
]
    include(tests)
end

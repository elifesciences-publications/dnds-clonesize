using StemCellModels
using DataFrames
using Pkg
Pkg.build("RCall")
using RCall
using ProgressMeter
using StatsBase
using Statistics
using Random
using StatsBase
using ArgParse
R"""
library(ggplot2)
library(cowplot)
library(tidyverse)
library(viridis)
library(jcolors)
""";

# This script contains some functions to do a Maximum Likelihood fit of our model
include("optim.jl")

s = ArgParseSettings()
@add_arg_table s begin
    "--examplefitsout"
        help = "File to save example fits"
    "--exampledifferentbins"
        help = "File to save example fits"
    "--nsamples"
        help = "Number of samples to take"
        arg_type = Int
        default = 10
end

parsed_args = parse_args(ARGS, s)

Random.seed!(12345)

#function to calculate interval dN/dS from simulations
function intervaldnds_data(Msel, Mneut, mmin, Nmax; mgap = 5.0, mup = 1.0, mud = 1.0)
    #calculate cumulative dn/ds across cohort, normalizing for mutation rates
    dndscumsum = Float64[]
    dnvec = Float64[]
    dsvec = Float64[]
    driverVAFt = filter(x -> x >= mmin, Msel)
    passengerVAFt = filter(x -> x >= mmin, Mneut)
    freqs = collect(mmin:mgap:Nmax)
    for f in freqs
        dn = length(filter(x -> x< f, driverVAFt))/mud
        ds = length(filter(x -> x< f, passengerVAFt))/mup
        push!(dndscumsum, dn/ds)
        push!(dnvec, dn)
        push!(dsvec, ds)
    end
    return dndscumsum[2:end], freqs[2:end], dnvec[2:end], dsvec[2:end]
end

#function to simulate population of cells with different paramters
function simulatepopulation(;Δ = 0.0, ρ = 100.0, Amin = 1 ./ ρ, gap = 0.02, tend = 20.0,
        Ncells = 1000, r = 0.5, λ = 1.0,
        sample = false, nsample = 10, Amax = 0.0)

    rangeN = 1:10^4
    Nits = 100
    Cntd = zeros(length(rangeN), Nits)
    Cntp = zeros(length(rangeN), Nits)
    Msel = Int64[]
    Mneut = Int64[]
    SMtog = SkinStemCellModel(Ncells, Δmut = Δ, μp = 0.001, μd = 0.001, tend = tend, r = r, λ = λ)
    for i in 1:Nits
        scst = runsimulation(SMtog, progress = false, finish = "time", onedriver = true, restart = true)
        append!(Msel, filter!(x -> x > 0, counts(sort(StemCellModels.cellsconvert(scst.stemcells)[2]), rangeN)))
        append!(Mneut, filter!(x -> x > 0, counts(sort(StemCellModels.cellsconvert(scst.stemcells)[1]), rangeN)))
    end

    Asel = Msel ./ ρ
    Aneut = Mneut ./ ρ
    Asel = filter(x -> x >= Amin, Asel)
    Aneut = filter(x -> x >= Amin, Aneut)

    if sample
        prevlength = length(Asel)
        Asel = Asel[StatsBase.sample(1:length(Asel), nsample, replace = false)]
        Aneut = Aneut[StatsBase.sample(1:length(Aneut),
                Int64(round(nsample * (length(Aneut) / prevlength))), replace = false)]
    end

    if Amax == 0.0
        Amax = maximum(Asel)
    end

    x1 = intervaldnds_data(Asel, Aneut, Amin, Amax; mgap = gap, mup = SMtog.μp, mud = SMtog.μd)

    DFinterval = DataFrame(dnds = x1[1], A = x1[2], dn = x1[3] * SMtog.μd / Nits,
    ds = x1[4] * SMtog.μd / Nits)

    return DFinterval, SMtog, [DFinterval[:dn][end] * Nits, DFinterval[:ds][end] * Nits]
end

#####################################################
# Power to recover paramters
#####################################################
println("Running simulation to test power to recover paramters")


#create some empty vectors and dataframes to store data
deltavec = Float64[]
rlambdavec = Float64[]
nmutsdn = Float64[]
nmutsds = Float64[]
itvec = Int64[]
sampvec = Float64[]
rsq = Float64[]
myDF = DataFrame([Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Int64, Int64],
[:dnds, :A, :dndsfit, :deltafit, :lambdarfit, :rsq, :deltatrue, :lambdartrue, :its, :nsamples], 0)

myDF = DataFrame([Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64,
    Float64, Float64, Float64, Float64, Float64, Float64, Float64, Float64, Int64, Int64],
[:dnds, :A, :dndsfit, :dndsfitlq, :dndsfituq, :deltafit, :lambdarfit,
    :deltafitlq, :lambdarfitlq, :deltafituq, :lambdarfituq, :sedelta, :selambda, :rsq, :deltatrue, :lambdartrue,
    :its, :nsamples], 0)

#number od mutations to be samples
for nsamples in [5, 8, 10, 25, 50, 100, 250]
    #repeat 100 times
    for i in 1:parsed_args["nsamples"]
        Random.seed!(i)
        Δ = 0.25
        r = 0.5
        lambda = 1.0
        rlambda = r * lambda
        DF1, SM, nmuts = simulatepopulation(;Δ = Δ, tend = 30.0, Amin = 0.05, ρ = 100.0,
                            λ = lambda, r = r, sample = true, nsample = nsamples + 1)
        println(nmuts)
        if isnan(DF1[:dnds][1]) | (DF1[:dnds][1] == Inf)
            continue
        end
        x = LLoptimizationresults(DF1[:dnds], DF1[:A]; t = 30.0, Amin = 0.05, ρ = 100.0)
        x.DF[:deltatrue] = Δ
        x.DF[:lambdartrue] = rlambda
        x.DF[:its] = i
        x.DF[:nsamples] = nsamples
        append!(myDF, x.DF)
        push!(deltavec, x.Δ)
        push!(rlambdavec, x.rλ)
        push!(itvec, i)
        push!(nmutsdn, nmuts[1])
        push!(nmutsds, nmuts[2])
        push!(sampvec, nsamples)
        push!(rsq, x.DF[:rsq][1])
    end
end

DFfit = DataFrame(iterations = itvec,
nmutsdn = nmutsdn,
nmutsds = nmutsds,
delta = deltavec,
rlambda = rlambdavec,
nsamples = sampvec,
rsq = rsq)

DFfit[:product] = DFfit[:delta] .* DFfit[:rlambda];

println("Write data to file")
@rput DFfit
R"""
write_csv(DFfit, $(parsed_args["powerout"]))
""";

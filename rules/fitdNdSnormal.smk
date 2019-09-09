rule fitdNdSnormal:
    input:
        oesophagusdnds="results/oesophagus/dnds.csv",
        oesophagusdndsgenes="results/oesophagus/dnds_genes.csv",
        oesophagusdndsneutral="results/oesophagus/dnds_neutral.csv",
        oesophagusmetadata="data/oesophagus/donorinfo.csv",
        skindnds="results/skin/dnds.csv",
        skindndsgenes="results/skin/dnds_genes.csv",
        skinmetadata="data/skin/donorinfo.csv",
    output:
        oesophagusfitall = "results/dataforfigures/oesophagusfitall.csv",
        oesophagusfitmissense = "results/dataforfigures/oesophagusfitmissense.csv",
        oesophagusfitnonsense = "results/dataforfigures/oesophagusfitnonsense.csv",
        skinfitmissense = "results/dataforfigures/skinfitmissense.csv",
        skinfitnonsense = "results/dataforfigures/skinfitnonsense.csv",
        oesophagusfitmissensepergene = "results/dataforfigures/oesophagusfitmissensepergene.csv",
        oesophagusfitnonsensepergene = "results/dataforfigures/oesophagusfitnonsensepergene.csv",
        skinfitmissensepergene = "results/dataforfigures/skinfitmissensepergene.csv",
        skinfitnonsensepergene = "results/dataforfigures/skinfitnonsensepergene.csv",
        oesophagusfitneutral = "results/dataforfigures/oesophagusneutral.csv"
    shell:
        """
        module unload R
        module load R/3.5.3
        module load julia
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`R RHOME`/lib"
        julia julia/FitdNdS.jl \
            --oesophagusdndsdata {input.oesophagusdnds} \
            --oesophagusdndsdatagenes {input.oesophagusdndsgenes} \
            --oesophagusdndsneutral {input.oesophagusdndsneutral} \
            --oesophagusmetadata {input.oesophagusmetadata} \
            --skindndsdata {input.skindnds} \
            --skindndsdatagenes {input.skindndsgenes} \
            --skinmetadata {input.skinmetadata} \
            --oesophagusfitmissense {output.oesophagusfitmissense} \
            --oesophagusfitall {output.oesophagusfitall} \
            --oesophagusfitnonsense {output.oesophagusfitnonsense} \
            --skinfitmissense {output.skinfitmissense} \
            --skinfitnonsense {output.skinfitnonsense} \
            --oesophagusfitmissensepergene {output.oesophagusfitmissensepergene} \
            --oesophagusfitnonsensepergene {output.oesophagusfitnonsensepergene} \
            --skinfitmissensepergene {output.skinfitmissensepergene} \
            --skinfitnonsensepergene {output.skinfitnonsensepergene} \
            --oesophagusfitneutral {output.oesophagusfitneutral}
        """

rule formatresultsSSB:
    input:
        all = expand("results/oesophagus/SSBresults/allpatients_dnds_{ssb_genes}.txt", ssb_genes=SSB_genes),
        missense = expand("results/oesophagus/SSBresults/allpatients_dnds_{ssb_genes}_mis.txt", ssb_genes=SSB_genes),
        nonsense = expand("results/oesophagus/SSBresults/allpatients_dnds_{ssb_genes}_non.txt", ssb_genes=SSB_genes),
    output:
        all = "results/oesophagus/SSBresults/SSBdnds_results.csv",
        missense = "results/oesophagus/SSBresults/SSBdnds_results_missense.csv",
        nonsense = "results/oesophagus/SSBresults/SSBdnds_results_nonsense.csv"
    params:
        singlepatient=config["patient"],
        step=config["idndslimits"]["step"],
        minarea=config["idndslimits"]["minarea"],
        maxarea=config["idndslimits"]["maxarea"]
    shell:
        """
        module load R
        Rscript R/formatSSB.R \
            --inputfile {input.all} \
            --outputfile {output.all} \
            --step {params.step} \
            --minarea {params.minarea} \
            --maxarea {params.maxarea}

        Rscript R/formatSSB.R \
            --inputfile {input.missense} \
            --outputfile {output.missense} \
            --step {params.step} \
            --minarea {params.minarea} \
            --maxarea {params.maxarea}

        Rscript R/formatSSB.R \
            --inputfile {input.nonsense} \
            --outputfile {output.nonsense} \
            --step {params.step} \
            --minarea {params.minarea} \
            --maxarea {params.maxarea}

        """

rule fitdNdSnormalSSB:
    input:
        all = "results/oesophagus/SSBresults/SSBdnds_results.csv",
        missense = "results/oesophagus/SSBresults/SSBdnds_results_missense.csv",
        nonsense = "results/oesophagus/SSBresults/SSBdnds_results_nonsense.csv",
        oesophagusmetadata = "data/oesophagus/donorinfo.csv",
    output:
        oesophagusfit = "results/dataforfigures/oesophagusfit-SSB.csv",
    shell:
        """
        module unload R
        module load R/3.5.3
        module load julia
        export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:`R RHOME`/lib"
        julia julia/FitdNdS-SSB.jl \
            --oesophagusdndsdata {input.all} \
            --oesophagusdndsdata_miss {input.missense} \
            --oesophagusdndsdata_non {input.nonsense} \
            --oesophagusmetadata {input.oesophagusmetadata} \
            --oesophagusfit {output.oesophagusfit} \
        """

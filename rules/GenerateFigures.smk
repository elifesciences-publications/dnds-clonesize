rule Figure1:
    output:
        figure="Figures/Figure1.pdf"
    shell:
        """
        module load R
        Rscript R/Figure1.R \
            --figure {output.figure}
        """

rule Figure2:
    input:
        stemcellexamplefit="results/dataforfigures/stemcell_simulation_examplefits.csv",
        stemcellpower="results/dataforfigures/stemcell_simulation_power.csv",
        oesophagusfitmissense = "results/dataforfigures/oesophagusfitmissense.csv",
        oesophagusfitnonsense = "results/dataforfigures/oesophagusfitnonsense.csv",
        skinfitmissense = "results/dataforfigures/skinfitmissense.csv",
        skinfitnonsense = "results/dataforfigures/skinfitnonsense.csv",
        oesophagusfitmissensepergene = "results/dataforfigures/oesophagusfitmissensepergene.csv",
        oesophagusfitnonsensepergene = "results/dataforfigures/oesophagusfitnonsensepergene.csv",
        singlepatientdnds="results/dataforfigures/singlepatient_bins.csv",
        oesophagusfitneutral = "results/dataforfigures/oesophagusneutral.csv"
    output:
        figure="Figures/Figure2.pdf",
        suppfigures=expand("Figures/FigureS{S}.pdf", S = [1])
    shell:
        """
        module load R
        Rscript R/Figure2.R \
            --figure {output.figure} \
            --suppfigures {output.suppfigures} \
            --oesophagusfitmissense {input.oesophagusfitmissense} \
            --oesophagusfitnonsense {input.oesophagusfitnonsense} \
            --skinfitmissense {input.skinfitmissense} \
            --skinfitnonsense {input.skinfitnonsense} \
            --oesophagusfitmissensepergene {input.oesophagusfitmissensepergene} \
            --oesophagusfitnonsensepergene {input.oesophagusfitnonsensepergene} \
            --oesophagusfitneutral {input.oesophagusfitneutral} \
            --stemcellexamplefit {input.stemcellexamplefit} \
            --stemcellpower {input.stemcellpower} \
            --singlepatient {input.singlepatientdnds}
        """

rule Figure3:
    input:
        stemcellexamplefit="results/dataforfigures/stemcell_simulation_examplefits.csv",
        stemcellpower="results/dataforfigures/stemcell_simulation_power.csv",
        oesophagusfitmissense = "results/dataforfigures/oesophagusfitmissense.csv",
        oesophagusfitnonsense = "results/dataforfigures/oesophagusfitnonsense.csv",
        oesophagusfitmissensepergene = "results/dataforfigures/oesophagusfitmissensepergene.csv",
        oesophagusfitnonsensepergene = "results/dataforfigures/oesophagusfitnonsensepergene.csv",
    params:
        mutationcutoff=config["mutationcutoff"],
        rsqcutoff=config["rsqcutoff"]
    output:
        figure="Figures/Figure3.pdf",
        suppfigures=expand("Figures/FigureS{S}.pdf", S = [2,3,4,5])
    shell:
        """
        module load R
        Rscript R/Figure3.R \
            --figure {output.figure} \
            --suppfigures {output.suppfigures} \
            --oesophagusfitmissense {input.oesophagusfitmissense} \
            --oesophagusfitnonsense {input.oesophagusfitnonsense} \
            --oesophagusfitmissensepergene {input.oesophagusfitmissensepergene} \
            --oesophagusfitnonsensepergene {input.oesophagusfitnonsensepergene} \
            --mutationcutoff {params.mutationcutoff} \
            --rsqcutoff {params.rsqcutoff}
         """


rule FigureS6:
    input:
        skinfitmissensepergene = "results/dataforfigures/skinfitmissensepergene.csv",
        skinfitnonsensepergene = "results/dataforfigures/skinfitnonsensepergene.csv",
        skinfitmissense = "results/dataforfigures/skinfitmissense.csv",
        skinfitnonsense = "results/dataforfigures/skinfitnonsense.csv",
    output:
        figure="Figures/FigureS6.pdf",
        suppfigures=expand("Figures/FigureS{S}.pdf", S = [10])
    params:
        mutationcutoff=config["mutationcutoff"],
        rsqcutoff=config["rsqcutoff"]
    shell:
        """
        module load R
        Rscript R/FigureS6.R \
            --figure {output.figure} \
            --suppfigures {output.suppfigures} \
            --skinfitmissense {input.skinfitmissense} \
            --skinfitnonsense {input.skinfitnonsense} \
            --skinfitmissensepergene {input.skinfitmissensepergene} \
            --skinfitnonsensepergene {input.skinfitnonsensepergene} \
            --mutationcutoff {params.mutationcutoff} \
            --rsqcutoff {params.rsqcutoff}
        """

rule Figure4:
    input:
        vafclonality="results/TCHA/VAFclonality.csv",
        dndsclonality_percancertype="results/TCGA/dndsclonality_percancertype.csv",
        dndsclonality="results/TCGA/dndsclonality.csv",
        baseline="results/TCGA/baseline.csv",
    output:
        figure="Figures/Figure4.pdf",
        suppfigures=expand("Figures/FigureS{S}.pdf", S = [7])
    shell:
        """
        module load R
        Rscript R/Figure4.R \
            --figure {output.figure} \
            --suppfigures {output.suppfigures} \
            --tcgadata {input.vafclonality} \
            --baseline {input.baseline} \
            --dndsclonality_percancertype {input.dndsclonality_percancertype} \
            --dndsclonality {input.dndsclonality}
        """

rule Figure5:
    input:
        intervaldnds="results/TCGA/intervaldnds.csv",
        nmutations_gene="results/TCGA/nmutations_gene.csv",
        nmutations_gene_percancertype="results/TCGA/nmutations_gene_percancertype.csv",
        syntheticcohort_power="results/dataforfigures/syntheticcohort_power.csv",
        syntheticcohort="results/dataforfigures/syntheticcohort.csv",
        syntheticcohort_diffmu="results/dataforfigures/syntheticcohort_diffmu.csv",
        drivergenelist="data/genelists/Driver_gene_list_198_Science_Review.txt",
        syntheticcohort_fmin="results/dataforfigures/syntheticcohort_fmin.csv",
        syntheticcohort_inferreds="results/dataforfigures/syntheticcohort_inferreds.csv",
        baselinevalidation="results/TCGA/baseline_validate.csv",
    output:
        figure="Figures/Figure5.pdf",
        suppfigures=expand("Figures/FigureS{S}.pdf", S = [8,9,11])
    shell:
        """
        module load R
        Rscript R/Figure5.R \
            --figure {output.figure} \
            --suppfigures {output.suppfigures} \
            --nmutations_gene {input.nmutations_gene} \
            --nmutations_gene_percancertype {input.nmutations_gene_percancertype} \
            --intervaldNdSsim {input.syntheticcohort} \
            --intervaldNdSsimmu {input.syntheticcohort_diffmu} \
            --intervaldNdSsimpower {input.syntheticcohort_power} \
            --intervaldNdStcga {input.intervaldnds} \
            --drivergenelist {input.drivergenelist} \
            --fmin {input.syntheticcohort_fmin} \
            --inferreds {input.syntheticcohort_inferreds} \
            --baselinevalidation {input.baselinevalidation}
        """

rule Figurecomparednds:
    input:
        alldndscv = "results/dataforfigures/oesophagusfitall.csv",
        dndscvfitmissense = "results/dataforfigures/oesophagusfitmissense.csv",
        dndscvfitnonsense = "results/dataforfigures/oesophagusfitnonsense.csv",
        dndscvfitmissensepergene = "results/dataforfigures/oesophagusfitmissensepergene.csv",
        dndscvfitnonsensepergene = "results/dataforfigures/oesophagusfitnonsensepergene.csv",
        SSB = "results/dataforfigures/oesophagusfit-SSB.csv"
    output:
        figure = "Figures/Figure6.pdf"
    shell:
        """
        module load R
        Rscript R/Figure-comparednds.R \
            --figure {output.figure} \
            --SSB {input.SSB} \
            --alldndscv {input.alldndscv} \
            --dndscvmissense {input.dndscvfitmissense} \
            --dndscvnonsense {input.dndscvfitnonsense} \
            --dndscvmissensepergene {input.dndscvfitmissensepergene} \
            --dndscvnonsensepergene {input.dndscvfitnonsensepergene} \
        """

rule Figurebinsize:
    input:
        binsizesims = "results/dataforfigures/stemcell_simulation_differentbins.csv"
    output:
        figure = "Figures/Figurebinsize"
    shell:
        """
        module load R
        Rscript R/Figure-binsize.R \
            --figure {output.figure} \
            --binsizesims {input.binsizesims}
        """

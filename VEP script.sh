#!/bin/bash 
#SBATCH --mem=20G
#SBATCH --time=48:00:00
#SBATCH --nodes=1

module load ensembl-vep/103.0

reference=/scratch/wir1n21/references
Splicefiles=/scratch/wir1n21/testSpliceAI/SpliceAIfiles

cat .txt | while read -r sample

do

cd $sample

#variant effect prediction using SpliceAIplugin
vep \
-i Final.vcf.gz \
-o VEPresults.txt \
--vcf \
--everything \
--dir_cache /mainfs/lyceum/wir1n21/.vep \
--plugin SpliceAI,snv=$Splicefiles/spliceai_scores.raw.snv.hg38.vcf.gz,indel=$Splicefiles/spliceai_scores.raw.indel.hg38.vcf.gz \
--offline

cd ..

done

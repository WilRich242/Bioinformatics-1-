#!/bin/bash 
#SBATCH --mem=15G
#SBATCH --time=48:00:00
#SBATCH --nodes=1

#gatk best practices pipeline for RNAseq data with thresholds derived from suggestions, 
#gatk and relevant literature

module load picard/2.18.14

module load GATK/4.2.2

cd /scratch/wir1n21/CompleteSamples

Samplecode=SOT260
#alter samplecode based on code of each sample above#

mkdir $Samplecode.postGATK

cd /scratch/wir1n21/CompleteSamples/$Samplecode.postGATK

#reference folder containing reference genome
reference=/scratch/wir1n21/references

picard MarkDuplicates \
      I=/scratch/wir1n21/bams_splicing_disease/$Samplecode.main.sorted.bam  \
      O=marked_duplicates.bam \
      M=marked_dup_metrics.txt \
	  

rm /scratch/wir1n21/bams_splicing_disease/$Samplecode.main.sorted.bam*
#remove the initial files in order to save space from CompleteSamples folder#	  
	  
gatk SplitNCigarReads \
      -R $reference/GRCh38.primary_assembly.genome.fa\
      -I marked_duplicates.bam \
      -O SNCRresults.bam
	  
rm marked_duplicates.bam
#remove intermediate bam file#

picard AddOrReplaceReadGroups \
       I=SNCRresults.bam \
       O=RG_SNCRresults.bam \
       RGID=4 \
       RGLB=lib1 \
       RGPL=ILLUMINA \
       RGPU=unit1 \
       RGSM=20 \
	   
rm SNCRresults.bam
rm SNCRresults.bai
#remove intermediate bam file#

gatk BaseRecalibrator \
   -I RG_SNCRresults.bam \
   -R $reference/GRCh38.primary_assembly.genome.fa \
   --known-sites $reference/Homo_sapiens_assembly38.dbsnp138.vcf \
   -O recal_data.table \


gatk ApplyBQSR \
   -R $reference/GRCh38.primary_assembly.genome.fa \
   -I RG_SNCRresults.bam \
   --bqsr-recal-file recal_data.table \
   -O ApplyBQSRresults.bam \

rm RG_SNCRresults.bam
#remove intermediate file#

gatk HaplotypeCaller  \
   -R $reference/GRCh38.primary_assembly.genome.fa \
   -I ApplyBQSRresults.bam \
   -O Genotype.g.vcf.gz \
   -ERC GVCF \
   -G StandardAnnotation \
   -G AS_StandardAnnotation \
   

gatk VariantFiltration \
   -R $reference/GRCh38.primary_assembly.genome.fa \
   -V Genotype.g.vcf.gz \
   -O FilteredVariants.vcf.gz \
   --filter-name "my_filter1" \
   --filter-expression "AB < 0.2" \
   --filter-name "my_filter2" \
   --filter-expression "MQ0 > 50"
   
rm Genotype.g.vcf.gz 
rm Genotype.g.vcf.gz.tbi   
rm ApplyBQSRresults.bam
rm ApplyBQSRresults.bai
#remove intermediate files#

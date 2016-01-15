#!/bin/bash
## Define paths to software and reference files

RCODE=/home/gosia/R/drimseq_paper/analysis_kim_adenocarcinoma
RWD=/home/Shared/data/seq/kim_adenocarcinoma
ROUT=$RWD/Rout
ANNOTATION=/home/Shared/data/annotation/Human/Ensembl_GRCh37.71

mkdir $ROUT

## Run R scripts

###############################################################################
### Download FASTQ files and bam files from insilicodb
###############################################################################

### ! First save SraRunInfo.csv file in "$RWD/3_metadata" directory !
### ! First save Malgorzata Nowicka2014-11-04GSE37764.csv file in "$RWD/3_metadata" directory !


R214 CMD BATCH --no-save --no-restore "--args rwd='$RWD'" $RCODE/kim_download.R $ROUT/kim_download.Rout


###############################################################################
### Kallisto
###############################################################################


R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' gtf_path='$ANNOTATION/gtf/Homo_sapiens.GRCh37.71.gtf' cDNA_fasta='$ANNOTATION/cDNA/Homo_sapiens.GRCh37.71.cdna.all.fa'" $RCODE/kim_kallisto.R $ROUT/kim_kallisto.Rout



R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' gtf_path='$ANNOTATION/gtf/Homo_sapiens.GRCh37.71.gtf'" $RCODE/kim_kallisto_filter_gtf.R $ROUT/kim_kallisto_filter_gtf.Rout



###############################################################################
### DEXSeq
###############################################################################


### Index BAM files

for i in 'GSM927308' 'GSM927310' 'GSM927312' 'GSM927314' 'GSM927316' 'GSM927318' 'GSM927309' 'GSM927311' 'GSM927313' 'GSM927315' 'GSM927317' 'GSM927319'
 do 
  samtools index $RWD/1_reads/tophat_insilicodb/${i}/accepted_hits.bam
done


### Run HTSeq


R214 CMD BATCH --no-save --no-restore "--args rwd='$RWD' gtf='$ANNOTATION/gtf/Homo_sapiens.GRCh37.71.gtf' count_method='htseq'" $RCODE/kim_htseq.R $ROUT/kim_htseq_htseq.Rout


R214 CMD BATCH --no-save --no-restore "--args rwd='$RWD' gtf='$ANNOTATION/gtf/Homo_sapiens.GRCh37.71_kallistoest_atleast5.gtf' count_method='htseqprefiltered5'" $RCODE/kim_htseq.R $ROUT/kim_htseq_htseqprefiltered5.Rout




### Run DEXSeq

for model in 'model_full' 'model_full_glm' 'model_null_normal1' 'model_null_normal2' 'model_null_tumor1' 'model_null_tumor2'
do 
  for count_method in 'kallisto' 'htseq' 'kallistofiltered5' 'htseqprefiltered5'
  do

    echo "${model}_${count_method}"

    R214 CMD BATCH --no-save --no-restore "--args rwd='$RWD' workers=4 count_method='${count_method}' model='${model}'" $RCODE/kim_dexseq_run.R $ROUT/kim_dexseq_run_${model}_${count_method}.Rout

  done
done



###############################################################################
### DRIMSeq
###############################################################################


for model in 'model_full' 'model_null_normal1' 'model_null_normal2' 'model_null_tumor1' 'model_null_tumor2'
do 
  for count_method in 'kallisto' 'htseq' 'kallistofiltered5' 'htseqprefiltered5'
  do
    
    echo "${model}_${count_method}"

    R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' workers=4 count_method='${count_method}' model='${model}' dispersion_common=TRUE results_common=FALSE disp_mode_list='grid' disp_moderation_list='none'" $RCODE/kim_drimseq_0_3_3_run.R $ROUT/kim_drimseq_0_3_3_run_${model}_${count_method}_grid_none.Rout
    
    R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' workers=4 count_method='${count_method}' model='${model}' dispersion_common=FALSE results_common=FALSE disp_mode_list='grid' disp_moderation_list='common'" $RCODE/kim_drimseq_0_3_3_run.R $ROUT/kim_drimseq_0_3_3_run_${model}_${count_method}_grid_common.Rout

  done
done


##############################
### Colors
##############################

R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' out_dir='$RWD/drimseq_0_3_3_comparison'" $RCODE/colors.R $ROUT/colors.Rout


##############################
### DRIMSeq comparison
##############################


for model in 'model_full' 'model_full_glm' 'model_null_normal1' 'model_null_normal2' 'model_null_tumor1' 'model_null_tumor2'
do 
  for count_method in 'kallisto' 'htseq' 'kallistofiltered5' 'htseqprefiltered5'
  do 
  
    echo "${model}_${count_method}"

    R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' count_method='${count_method}' model='${model}'" $RCODE/kim_drimseq_0_3_3_comparison_run.R $ROUT/kim_drimseq_0_3_3_comparison_run.Rout

  done
done



R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD'" $RCODE/kim_drimseq_0_3_3_summary.R $ROUT/kim_drimseq_0_3_3_summary.Rout




###############################################################################
### Individual runs
###############################################################################






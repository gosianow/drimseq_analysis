## Define paths to software and reference files

RCODE=/home/gosia/R/drimseq_paper/analysis_brooks_pasilla
RWD=/home/Shared/data/seq/brooks_pasilla
ROUT=$RWD/Rout

# mkdir $ROUT

### Run R scripts

for model in 'model_full' 'model_full_paired' 'model_null1' 'model_null2' 'model_null3'
do 
  for count_method in 'kallisto' 'htseq' 'kallistofiltered5' 'htseqprefiltered5'
  do
    
    echo "${model}_${count_method}"

    R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' workers=4 count_method='${count_method}' model='${model}' dispersion_common=TRUE results_common=FALSE disp_mode_list='grid' disp_moderation_list='none'" $RCODE/brooks_drimseq_0_3_3_run.R $ROUT/brooks_drimseq_0_3_3_run_${model}_${count_method}_grid_none.Rout
    
    R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' workers=4 count_method='${count_method}' model='${model}' dispersion_common=FALSE results_common=FALSE disp_mode_list='grid' disp_moderation_list='common'" $RCODE/brooks_drimseq_0_3_3_run.R $ROUT/brooks_drimseq_0_3_3_run_${model}_${count_method}_grid_common.Rout

  done
done


###############################################################################
### Individual runs
###############################################################################




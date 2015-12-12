#!/bin/bash
## Define paths to software and reference files

RCODE=/home/gosia/R/drimseq_paper/simulations_dm
RWD=/home/gosia/multinomial_project/simulations_dm/drimseq
ROUT=$RWD/Rout
DMPARAMS=$RWD/dm_parameters_drimseq_0_3_3

# mkdir $ROUT

##############################################################################
### Run
##############################################################################

disp='disp_common_kim_kallisto'
workers=1
prop='prop_q20_kim_kallisto_fcutoff'

for n in 3
do

  for nm in 10000 1000 500
  do
    
    
    for run in {1..25}
    do
      
    echo "n${n}_nm${nm}_${prop}_${run}"

      R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' simulation_script='$RCODE/dm_simulate.R' workers=${workers} sim_name='' run='run${run}' m=1000 n=${n} nm=${nm} nd=0 param_pi_path='$DMPARAMS/kim_kallisto/${prop}.txt' param_gamma_path='$DMPARAMS/kim_kallisto/${disp}.txt' max_features=c(Inf,18,16,14,12,10,8,5)" $RCODE/filtering_run.R $ROUT/filtering_run_n${n}_nm${nm}_${prop}.Rout
      
    done
  done
done




######################
### Test
######################

disp='disp_common_kim_kallisto'
workers=4
prop='prop_q20_kim_kallisto_fcutoff'

for n in 3
do

  for nm in 1000
  do
    
    
    for run in {1..3}
    do
      
    echo "n${n}_nm${nm}_${prop}_${run}"

      R32 CMD BATCH --no-save --no-restore "--args rwd='$RWD' simulation_script='$RCODE/dm_simulate.R' workers=${workers} sim_name='test_' run='run${run}' m=100 n=${n} nm=${nm} nd=0 param_pi_path='$DMPARAMS/kim_kallisto/${prop}.txt' param_gamma_path='$DMPARAMS/kim_kallisto/${disp}.txt' max_features=c(Inf,18,8)" $RCODE/filtering_run.R $ROUT/filtering_run_n${n}_nm${nm}_${prop}.Rout
      
    done
  done
done



######################
### Individual run
######################



##############################################################################
### Plot
##############################################################################



n=3
nm="c(1000,10000)"
param_pi_path="c('$DMPARAMS/kim_kallisto/prop_q15_kim_kallisto_overall.txt','$DMPARAMS/kim_kallisto/prop_q20_kim_kallisto_fcutoff.txt')"
out_name_plots='all_'


R31 CMD BATCH --no-save --no-restore "--args rwd='$RWD' n=${n} nm=${nm} nd=0 param_pi_path=${param_pi_path} param_gamma_path='$DMPARAMS/kim_kallisto/disp_common_kim_kallisto.txt' out_name_plots='${out_name_plots}'" $RCODE/filtering_plots_run.R $ROUT/filtering_plots_run.Rout
     
    
















. ./cmd.sh
. ./path.sh

if ! type $kaldi_executable   > /dev/null 2>&1 ; then 
   echo "online2-wav-nnet2-latgen-faster does not exist. Please make sure that file path is in the system PATH variable";
   exit 1
fi

conf_dir=acoustic_model_aspire/conf # AM config file
graph_dir=exp/graph # Decoding graph (that includes LM)
model_dir=acoustic_model_aspire # AM directory

dir=$PWD
# We have to change the paths in the aspire model configuration files. So call "path_script.sh"
cd $model_dir
bash path_script.sh
cd $dir

infile=$1
infile=$(echo $infile | awk -F '.wav' '{print $1}')
outfile=$infile"_8k.wav"
infile=$infile".wav"
sample_rate="sox --i -r $infile"
if  [ "$sample_rate" != "8000" ] ; then
 sox $infile -r 8000 $outfile
 infile=$outfile
fi
tempfile="tempfile.txt"
outfile_transcript="out.txt"
#echo $infile
online2-wav-nnet3-latgen-faster \
  --online=false \
  --do-endpointing=false \
  --frame-subsampling-factor=3 \
  --config=$conf_dir/online_nnet2_decoding.conf \
  --max-active=7000 \
  --beam=15.0 \
  --lattice-beam=6.0 \
  --acoustic-scale=1.0 \
  --word-symbol-table=$graph_dir/words.txt \
   --verbose=2 \
  $model_dir/final.mdl \
  $graph_dir/HCLG.fst \
  "ark:echo utterance-id1 utterance-id1|" \
  "scp:echo utterance-id1 $infile|" \
  ark:/dev/null 2>&1 | grep -v "LOG" | grep -v "online2-wav-nnet3-latgen-faster" | sed s:utterance-id1:\($infile\):
#  "ark:echo utterance-id1 utterance-id1|" "scp:echo utterance-id1 $infile|" > $tempfile 2>&1 \
#  ark:/dev/null
#  cat $tempfile | grep -v "LOG" | grep -v "online2-wav-nnet3-latgen-faster" > $outfile_transcript_beamform #| sed s:utterance-id1:\($infile\): | awk -F ' ' '{print $2}' 
  #cat $outfile_transcript_beamform
  #rm -f $tempfile
rm $outfile

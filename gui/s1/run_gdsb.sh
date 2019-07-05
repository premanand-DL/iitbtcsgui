echo =============================================================
echo " GDSB Beamforming"
echo =============================================================

. ./cmd.sh
. ./path.sh

# Reading strings from command line arguments
audio_dir=$1                      # lo0cation of original data 
enhandir_beamform="enhan/demo1"              # location of enhaced data
recording_name=$2                # begining of file names

#data_original="../audio/original"
#data_enhan="../audio/enhanced"

enhan="GDSB"

# Make enhancement directory
mkdir -p  ${enhandir_beamform}

# Call script to perform GDSB
cd enhancement_codes/
#octave -q enhancement.m  "audio/original/" "audio/enhanced" "MVDR"
octave -q enhancement_new.m  "$audio_dir" "$enhandir_beamform" "$enhan" "$recording_name"
cd -

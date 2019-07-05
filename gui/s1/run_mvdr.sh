. ./cmd.sh
. ./path.sh
echo =============================================================
echo " MVDR beamforming"
echo =============================================================
# Write the max array file using python script "make_highest_energy_wav.py"
#audio_path_string=$PWD"/"$audio_dir"/"$recording_name
#enhandir_maxarray_string=$2"/maxArray/"$recording_name

enhan="MVDR"
# Reading strings from command line arguments
audio_dir=$1                      # lo0cation of original data 
enhandir_beamform="enhan/demo1"             # location of enhaced data
recording_name=$2                # begining of file names

# Make enhancement directory
mkdir -p  ${enhandir_beamform}

# Call script to perform MVDR
cd enhancement_codes/
octave -q enhancement_new.m  "$audio_dir" "$enhandir_beamform" "$enhan" "$recording_name"
cd -
echo "Done"

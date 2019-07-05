echo =============================================================
echo " Max array"
echo =============================================================
. ./cmd.sh
. ./path.sh

audio_dir=$1
recording_name=$2
# Write the max array file using python script "make_highest_energy_wav.py"
audio_path_string=$audio_dir"/"$recording_name
enhandir_maxarray_string="enhan/demo1/maxArray/"$recording_name

enhandir_maxarray="enhan/demo1/maxArray"
# Make enhancement directory
mkdir -p $enhandir_maxarray

## Note: You can use use python from virtual environment by uncommenting "##>" and adding your virtual environment path:
##> source /home/sonal/tensorflow/venv/bin/activate
python2.7 make_highest_energy_wav.py $audio_path_string $enhandir_maxarray_string
#python3 make_highest_energy_wav.py $audio_path_string $enhandir_maxarray_string        <--------changed
##> deactivate
echo "Done"


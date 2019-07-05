while read line; do
  /home/sachin/kaldi/tools/BeamformIt/BeamformIt -s $line -c exp/enhan/beamform_1_2_3_4/channels_4     --config_file /home/sachin/kaldi/egs/gui/s1/conf/beamformit.cfg     --source_dir /home/sachin/kaldi/egs/gui/s1/sample_data/chunk3     --result_dir enhan/demo1/beamform
done < exp/enhan/beamform_1_2_3_4/wavfiles.list.1

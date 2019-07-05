#!/bin/bash


# This script is for Generating graph

#set-up for single machine or cluster based execution
. ./cmd.sh

#set the paths to binaries and other executables
[ -f path.sh ] && . ./path.sh
train_cmd=run.pl
decode_cmd=run.pl

if [ $# -ne 1 ]
then
	echo "USAGE : $0 <sentences_file>"
	exit 1
fi


sentences_file=$1 # Input sentences with which the graph is to be made

# Setting put directories
model_directory="acoustic_model_aspire"
aspire_dict_directory="acoustic_model_aspire/dict_aspire"

output_graph="exp/graph"
# Note: data/lang is considered as language directory

echo ============================================================================
echo "                 Lexicon Preparation  [Using Aspire lexicon]                   "
echo ============================================================================

dict_dir=data/local/dict
mkdir -p $dict_dir

cp $aspire_dict_directory/extra_questions.txt $dict_dir
cp $aspire_dict_directory/silence_phones.txt $dict_dir
cp $aspire_dict_directory/optional_silence.txt $dict_dir
cp $aspire_dict_directory/nonsilence_phones.txt $dict_dir
cp $aspire_dict_directory/lexicon3_expand.txt $dict_dir/lexicon.txt

sed -i '1s/^/!SIL sil\n/' $dict_dir/lexicon.txt # Add !SIL to lexicon

echo "Using Aspire lexicon"

echo ============================================================================
echo "                Language Preparation                     "
echo ============================================================================

mkdir -p data/local/lm
mkdir -p data/local/tmp

# Clear previous runs if they exist
rm -rf local/lm/lm_phone_bg.arpa.gz data/lm/lm_phone_bg.arpa.gz
rm -rf  data/lang/*
rm -rf data/lm/*
rm -rf data/local/tmp/*
rm -rf data/local/dict/lexiconp.txt
rm -rf data/local/lang/lexiconp*
rm -rf data/local/lang/align_lexicon.txt
rm -rf data/local/lang/lex_ndisambig
rm -rf data/local/lang/phone_map.txt


utils/prepare_lang.sh --num-sil-states 3 ./data/local/dict "!SIL" data/local/lang  data/lang
echo "=== prepare_lang : DONE ==="

ngram-count -wbdiscount -interpolate -text $sentences_file -lm data/local/tmp/lm_phone_bg.arpa	# nxwbi, -interpolate only for kn and wb

compile-lm --text=yes data/local/tmp/lm_phone_bg.arpa /dev/stdout | grep -v "<unk>" | gzip -c > data/local/lm/lm_phone_bg.arpa.gz 
# Read LM file in ARPA format and compile it so that irstlm can read it quickly

echo "=== compile-lm : DONE ==="

gunzip -c data/local/lm/lm_phone_bg.arpa.gz | utils/find_arpa_oovs.pl data/lang/words.txt  > data/local/tmp/oov.txt # find OOV

echo "=== find OOV : DONE. Note: If you get errors before this step, add pronunications for the oov words to the lexicon and rerun the script ==="

gunzip -c data/local/lm/lm_phone_bg.arpa.gz | grep -v '<s> </s>' | grep -v '</s> <s>'  | grep -v '</s> </s>' | arpa2fst - | fstprint | utils/remove_oovs.pl data/local/tmp/oov.txt | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=data/lang/words.txt --osymbols=data/lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon |fstarcsort > data/lang/G.fst 

echo "=== G.fst : DONE ==="

fstisstochastic data/lang/G.fst 

echo "=== fstisstochastic G.fst : DONE ==="

utils/prepare_lang.sh --num-sil-states 3 data/local/dict/ "!SIL" data/local/lang data/lang

echo "Dictionary & language model preparation succeeded"

echo ============================================================================
echo "           Preparing graph           "
echo ============================================================================

utils/mkgraph.sh data/lang $model_directory $output_graph || exit 1;

echo "=== Preparing graph : DONE === Graph stored at "$output_graph


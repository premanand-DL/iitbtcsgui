#To clean up the transcripts

import sys

path=sys.argv[1]
f_orig=open(path+"ref.txt")

f_write=open(path+'ref_cleaned.txt','w')
lines=f_orig.readlines()
lines_mod=[]


# cleaning up each utterance
for i in range (0,len(lines)):
    lines_mod.append(lines[i].replace("-"," "))

for i in range (0,len(lines)):
    lines_mod[i]=lines_mod[i].replace(","," ")
    lines_mod[i]=lines_mod[i].replace(":"," ")
    lines_mod[i]=lines_mod[i].replace(";"," ")
    lines_mod[i]=lines_mod[i].replace("("," ")
    lines_mod[i]=lines_mod[i].replace(")"," ")
    lines_mod[i]=lines_mod[i].replace("'","")
    f_write.write(lines_mod[i])
    
f_write.close()
f_orig.close()


f_hyp=open(path+"hypothesis_transcript.txt")
f_write=open(path+'hypothesis_transcript_cleaned.txt','w')
lines=f_hyp.readlines()
lines_mod=[]


# cleaning up each utterance
for i in range (0,len(lines)):
    lines_mod.append(lines[i].replace("-"," "))

for i in range (0,len(lines)):
    lines_mod[i]=lines_mod[i].replace(","," ")
    lines_mod[i]=lines_mod[i].replace(":"," ")
    lines_mod[i]=lines_mod[i].replace(";"," ")
    lines_mod[i]=lines_mod[i].replace("("," ")
    lines_mod[i]=lines_mod[i].replace(")"," ")
    lines_mod[i]=lines_mod[i].replace("'","")
    f_write.write(lines_mod[i])
    
f_write.close()
f_hyp.close()


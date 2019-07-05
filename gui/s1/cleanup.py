#To clean up the transcripts

import sys

path=sys.argv[1]
#path='wav/demo1/'
f_hyp=open(path+"/ref.txt")
f_write=open(path+'/ref1.txt','w')
lines=f_hyp.readlines()
lines_mod=[]


# cleaning up each utterance
for i in range (0,len(lines)):
    lines_mod.append(lines[i])

for i in range (0,len(lines)):
    lines_mod[i]=lines_mod[i].replace("-"," ")
    lines_mod[i]=lines_mod[i].replace(","," ")
    lines_mod[i]=lines_mod[i].replace(":"," ")
    lines_mod[i]=lines_mod[i].replace(";"," ")
    lines_mod[i]=lines_mod[i].replace("("," ")
    lines_mod[i]=lines_mod[i].replace(")"," ")
    lines_mod[i]=lines_mod[i].replace("/","")
    lines_mod[i]=lines_mod[i].replace(".","")
    lines_mod[i]=lines_mod[i].replace("'","")
    lines_mod[i]=lines_mod[i].lower()
    f_write.write(lines_mod[i])
    
f_write.close()
f_hyp.close()


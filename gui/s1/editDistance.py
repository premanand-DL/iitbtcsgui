import io
import os
import numpy as np
import sys
# function to estimate the edit distance (insertion, deletion and substitution)
def levenshteinDistance(s1, s2):
    if len(s1) > len(s2):
        s1, s2 = s2, s1

    distances = range(len(s1) + 1)
    for i2, c2 in enumerate(s2):
        distances_ = [i2+1]
        for i1, c1 in enumerate(s1):
            if c1 == c2:
                distances_.append(distances[i1])
            else:
                distances_.append(1 + min((distances[i1], distances[i1 + 1], distances_[-1])))
        distances = distances_
    return distances[-1]
trans=sys.argv[1]
hyp=sys.argv[2]
# load the original transcripts 
f=open(trans)
lines=f.readlines()
for i in range(0,len(lines)):
    lines[i] = lines[i].lower()
    
#lines=lines.lower()
f.close()

# load thehypothesis transcripts
f1=open(hyp,"a+")
lines1=f1.readlines()
for i in range(0,len(lines)):
    lines1[i] = lines1[i].lower()
    
#lines1=lines1.lower()
f1.close()

# compute the edit distance
tot=0
wrong=0
for i in range(len(lines)):
    s1=lines[i].strip()
    temp1=len(s1)
    tot=tot+temp1
    t1=lines1[i].strip()
    edit_dist=levenshteinDistance(s1, t1)
    wrong=wrong+edit_dist

#print('Total words = ')
#print tot
#print('Wrongly decoded = ')
#print wrong
print('Word error rate =  ')
f=open('wer.txt','w')
f.write(str(100 * wrong / float(tot))+'\n')
f.close()
#print('Accuracy = ')
#print(100 - 100 * wrong / float(tot))


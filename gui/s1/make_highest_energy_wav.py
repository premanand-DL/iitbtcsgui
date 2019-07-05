import soundfile as sf
import numpy as np
import sys

file_path=str(sys.argv[1])
out_file_path=str(sys.argv[2])

all_fs=[]
all_data=[]
for channel in range(4):
    infile=str(file_path+".CH"+str(channel+1)+".wav")
    #print(infile)
    data=sf.read(infile)[0]
    fs=sf.read(infile)[1]
    all_fs.append(fs)
    all_data.append(data)
    
if all_fs.count(all_fs[0]) == len(all_fs):
    Fs=all_fs[0]
else:
    print("Not all fs are same")
    sys.exit()
    
length_ref = len(all_data[0])
check= [str(len(all_data[channel])) != length_ref for channel in range(4)]

if any(check) == False:
    print("Not all array wav file lengths are same")
    sys.exit()


n_samples=len(all_data[0])
seg_len=10*Fs
num_seg = int(n_samples/seg_len)
extra_frame=False
if num_seg < (n_samples/seg_len):
    extra_frame=True

chunk=np.zeros((4,seg_len))
chunk_max=np.zeros(seg_len)
all_data_max=[]
mean_channel=np.zeros(4)

for segID in range(num_seg):
    for channel in range(4):
        chunk[channel]=all_data[channel][segID*seg_len:(segID+1)*seg_len]
        mean_channel[channel]=np.mean(chunk[channel])
    max_channel_index=mean_channel.argmax(axis=0)
    chunk_max=chunk[max_channel_index].tolist()
    all_data_max.extend(chunk_max)
#print(len(all_data_max))
#print(n_samples)

#print("Last frame....")
if len(all_data_max) != n_samples and extra_frame == True:
    remaining_len=n_samples-len(all_data_max)
    #print(remaining_len)
    chunk=np.zeros((4,remaining_len))
    chunk_max=np.zeros(remaining_len)
    segID=num_seg+1
    for channel in range(4):
        chunk[channel]=all_data[channel][segID*remaining_len:(segID+1)*remaining_len]
        mean_channel[channel]=np.mean(chunk[channel])
    max_channel_index=mean_channel.argmax(axis=0)
    chunk_max=chunk[max_channel_index].tolist()
    all_data_max.extend(chunk_max)
#print(len(all_data_max))
#print(n_samples)


all_data_max=np.array(all_data_max)
outfile=str(out_file_path+".wav")
sf.write(outfile, all_data_max, Fs)


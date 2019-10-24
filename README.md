# This is just a README, the code folder is GUI is yet to be uploaded as there are some issues with the front-end


# Interface for Running Speech Enhancement and Recognition on simulated data

## The interface has 3 section:
* Choosing multi-channel file
* Running Enhancements
* Running ASR

![GUI for Analysis](https://github.com/iitbdaplab/iitbtcsgui/blob/master/gui/s1/gui.png)

### Choosing multi-channel file


The multi-channel file generated is generated using the synthesis interface is located in
the multi-channel folder along with its ’rir’ config file. After clicking the ’Browse’ button,
14a dialog box will open to choose the multi-channel file. Locate the multi-channel file you
want to enhance and click open.
If you want to use some other multi-channel audio (not
obtained from synthesis interface), these ensure that its a single file containing all the
channels(any format is compatible).

![Section 1 of the GUI](https://github.com/iitbdaplab/iitbtcsgui/blob/master/gui/s1/sec1.png)

A button to plot a selected RIR is displayed which opens a new window similar to one
shown in Figure 2.5. There is an option to play a particular channel of the file selected
which will open a media player (by default vlc, if installed). Another option is decoding
can be done on one particular channel which opens a text output of the channel audio in
e new window.

### Running Enhancements

Now this section of the interface follows the order. It starts with single-channel de-noising,
single-channel dereverberation, DoA estimation and beamforming.
Starting with single-channel de-noising, the drop-down list has two techniques namely:
{Weiner and Spectral Subtraction}. You can similarly play and decode each single-
channel file the same as that for input multi-channel files which is mentioned before. There
is an option for running single-channel de-noising and can be toggled with a checkbox


![Section 2 of the GUI](https://github.com/iitbdaplab/iitbtcsgui/blob/master/gui/s1/sec2.png)
This is succeeded by single-channel dereverberation if it is enabled. For dereverbera-
tion, we have used {WPE[9] and NMF}, appearing in the drop-down. You can also choose
to play or decode each of the dereverberated channel.

This stage is followed by localization with GCC-{PHAT,SCOT} available as options.
Beamforming using the TDOA estimates obtained from the localization( expect for Beam-
formit Tool). Options available in Beamforming are: {DSB, GEV, MVDR, NN-GEV,
NN-MVDR}.

Finally, after beamforming, a single-channel enhanced file obtained can be
played or decoded.


### Running ASR
This stage is still under development. We plan to use the DoA values to identify the
speaker. But one problem here is DoA is not reliable as they vary a lot due to varying
energy levels in speech and can give noisy DoA estimates in between the audio(frame
level). 

The button ’Show Diarization time stamps’ will show which speaker spoke and
their start and end time. The bottom-most button show transcripts will show which
speaker spoke with what in <speaker id: text >format.
  
## Setup, Directory Structure and Other requirements

Linux machine is required to run this task as most of the ASR models are being tested
run on Linux machine.

The following toolkits are required:
* Kaldi
* Octave-dev,Octave-lib

The following python packages are required:
• Pytorch 1.0 or >1.0
• Other: sys, scipy, librosa
The folder from cloned https://github.com/iitbdaplab/iitbtcsgui is  to be placed in ’<Your kaldi path >/egs’ folder. The log of each
stage is displayed in the ’log’ console window.
  
Here are the steps:

1) Clone the repository from https://github.com/iitbdaplab/iitbtcsgui using

  ```
   git clone https://github.com/iitbdaplab/iitbtcsgui
  ```
2) Run the following command on your unix machine to install required dependencies.
  ```
   chmod +x dependencies.sh
   ./dependencies.sh
  ```
3) Copy the folder gui in the repository to <Your path >/kaldi/egs   # where 'Your path' is whbere kaldi folder resides
  ```
   cp -r gui <Your path>/kaldi/egs/.
  ```

4) Change the directory to <Your path>/kaldi/egs/gui/s1
  ```
   cd <Your path>/kaldi/egs/gui/s1
  ```

## Run the Program
 ```
 ./gui.py    # Runs using python2.7(version 2)
 
```
## Here is the placed by deafult where the files are stored
* After de-noising, the enhanced file is stored at ./de-noised with ``` <file name>/<method>/<channel no> ``` as file name.
* After dereverberation, the enhanced file is stored at ./dereverb with ```<file name>/<method>/<channel no>``` as file name.
* After Beamforming, the enhanced file is stored at ./beamformed with ```<file name>/<method>``` as file name.



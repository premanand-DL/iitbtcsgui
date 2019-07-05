Instructions to setup the gui:

1)Extract the contents of the gui.zip file to some directory, say temp/

2) Change the current directory to temp/ $ cd temp/

3)Run the following command on your unix machine to install required dependencies.
  $ chmod +x dependencies.sh
  $ ./dependencies.sh

4) Copy the folder s1/ in 'temp' to <Your path >/kaldi/egs   # where 'Your path' is whbere kaldi folder resides

5)Change the directory to <Your path>/kaldi/egs/gui/s1
  $ cd <Your path>/kaldi/egs/gui/s1



Run the Program

$ ./gui.py    # ensure the python version is 2.7(version 2)


Note: sample_data folder contains clips to test the gui. (chunks taken from TCS recordings) 

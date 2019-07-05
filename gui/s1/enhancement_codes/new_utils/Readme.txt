Folder Structure :
|-> Speaker1 
|      |-> Spk1_CTM_NO.wav
|      |-> Spk1_MA_NO.wav
|
|-> Utils		
|      |-> Beamform.m
|      |-> Estimate_TDOA.m
|      |-> istft_multi.m
|      |-> stft_multi.m
|
|-> main.m
|
|-> Readme.txt
|
|-> Source_Localization.m 

The code main.m provides a MATLAB implementation of various beamforming techniques along with source localization algorithms. Following are the different algorithms used:
(a) Source Localization [1]
	(1) GCC PHAT ('GCC')
	(2) Cross Correlation ('CC')
	(3) Smoothed Coherence Tranform ('SCOT')
	(4) Hannan Thompson ('HT')
(b) Beamforming 
	(1) Delay Sum Beamforming ('DSB') [2]
	(2) Super Directive Beamforming ('SDB') [3]
	(3) Multichannel Alignment ('MCA') [4]
	(4) DSB based on steering vector with gain ('GDSB') [4]
	(5) Minimum Variance Distortionless Response ('MVDR')  [5]
	(6) MVDR based on steering vector with gain ('GMVDR')

The code Source_Localization.m provides a demo of the various source localization methods mentioned above. In this code, .wav file is read in the format (Length of each channel x Number of channels). The parameters used are :
	Window length for STFT (wlen, Default = 1024 samples) 
It then calls the function Estimate_TDOA to which following parameters are passed:
	(1) STFT of the multichannel input (X)	
	(1) Source localization algorithm (SL_Method)
	(2) Reference Channel (Ref_Ch)
	(3) Maximum expected delay (Max_Delay)
The function Estimate_TDOA returns estimated TDOA by the specified source localization algorithm  to the variable TDOA.	
	

The code main.m performs various beamforming algorithms. In this code, .wav file is read in the format (Length of each channel x Number of channels). Source localization is performed (as mentioned above) before beamforming. All the beamforming methods require the following parameters to be passed to the Beamform()  :
	(1) STFT of the multichannel input (X)
	(2) Beamforming algorithm (BF_Method)
	(3) Estimated Time Of Arrivals (TDOA)
	(4) Sampling Frequency (Fs)
In addition to this, MVDR and Gain-DSB+MVDR requires noise covariance matrix estimate in each bin (Ncov) to be passed as the argument. SDB requires the microhpone positions to passed as arguments to Beamform(). Example 1 in main.m estimates noise covariance matrix for MVDR beamforming assuming initial 'IS' frames as noise.
Example 2 in main.m  estimates the noise field using the microphone positions derived from TCS setup.

Beamform() returns the output after performing beamforming. Inverse STFT is computed using istft_multi() which gives the enhanced time domain signal.	

References:
[1] Knapp, Charles, and Glifford Carter. "The generalized correlation method for estimation of time delay." IEEE Transactions on Acoustics, Speech, and Signal Processing 24.4 (1976): 320-327	
[2] Cohen, Israel, Jacob Benesty, and Sharon Gannot, eds. Speech processing in modern communication: Challenges and perspectives. Vol. 3. Springer Science & Business Media, 2009.
[3] Bitzer, Joerg, and K. Uwe Simmer. "Superdirective microphone arrays." Microphone arrays. Springer Berlin Heidelberg, 2001. 19-38.
[4] Stolbov, Mikhail Borisovich, and Sergei Vladimirovich Aleinik. "Improvementof microphone array characteristics for speech capturing." Modern Applied Science 9.6 (2015): 310.
	
	
	
Noise robust voice activity detection algorithm (rVAD).
Version 1.0
10 Nvo 2014

Usage: vad(finwav, fpitch, fvad, vadThres); or vad(finwav, fpitch, fvad).

finwav: The input WAVE file path and name.% fpitch: The pitch file path and name. If the pitch file exists, pitch information is loaded; otherwise, the pitch information will be extracted and saved to the file in Matlab format.
fvad: The output VAD file path and name. Each line in the file contains the start frame number and the end frame number for a speech segment. The frame shift is 10ms.
vadThres: The threshold for VAD. The default value is 0.1 [optinal]. Increasing vadThres (e.g. to 0.2) makes the VAD more aggressive, i.e. the speech segment will be shortened.
foutwav: The output denoised speech file path and name [optional]. This is to be specified only if denoised speech output is desired.                    

Citation:
  Z.-H. Tan and B. Lindberg, "Low-complexity variable frame rate analysis for speech recognition and voice activity detection." IEEE Journal of Selected Topics in Signal Processing, vol. 4, no. 5, pp. 798-807, 2010.

Contact:
  Zheng-Hua Tan
  Aalborg University, Denmark
  zt@es.aau.dk


Link   http://kom.aau.dk/~zt/online/rVAD/

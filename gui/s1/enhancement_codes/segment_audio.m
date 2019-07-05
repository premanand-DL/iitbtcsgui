clear;clc;close all;

addpath(genpath('../audio'))
addpath('../transcripts')
addpath('utils')
input= argv(){1};
%input = 'audio/original/';
enhan = argv(){2};
%enhan=[];
ch = 5;
fileid = 'time_stamps.txt';
[spk, start, stop] = textread(fileid,'%s %f %f');
%audioread(['../audio/original/01_SPK1_04_06_2017.wav'], [start(1), stop(1)]);
if(strcmp(input,'audio/original/'))
	 
	
	loc1 = '../audio/original/';
	loc2 = '../audio/segmented/CloseTalking/';
	loc_A1 = '../audio/segmented/Array1/';
	loc_A2 = '../audio/segmented/Array2/';
	loc_A3 = '../audio/segmented/Array3/';
	loc_A4 = '../audio/segmented/Array4/';
	if isequal(ch,5)
	    loc_A5 = '../audio/segmented/Array5/';
	end


	sp1 = '01_SPK1_05_06_2017-09.wav';
	sp2 = '02_SPK2_05_06_2017-09.wav';
	sp3 = '03_SPK3_05_06_2017-09.wav';
	ar1 = '04_ARRAY1_05_06_2017-09.wav';
	ar2 = '05_ARRAY2_05_06_2017-09.wav';
	ar3 = '06_ARRAY3_05_06_2017-09.wav';
	ar4 = '07_ARRAY4_05_06_2017-09.wav';

	if isequal(ch,5)
	ar5 = '08_ARRAY5_05_06_2017-09.wav';
	end

	info = audioinfo([loc1 sp1]);
	fs = info.SampleRate;
	start = floor(start * fs);
	stop = floor(stop * fs);

	for i = 1 : length(spk)
	    temp = char(spk(i));
	    switch temp(1:3)
		case 'sp1'
		    disp([temp '-----' num2str(1)])
		    disp([loc1 sp1])
		    audioread([loc1 sp1]);
		    seg_audio = audioread([loc1 sp1], [start(i), stop(i)]);
		    disp([loc2 temp '.wav'])
		    Write_File( seg_audio, fs, [loc2 temp '.wav'] );
		    
		case 'sp2'
		    disp([temp '-----' num2str(2)])
		    disp([loc1 sp2])
		    seg_audio = audioread([loc1 sp2], [start(i), stop(i)]);
		    disp([loc2 temp '.wav'])
		    Write_File( seg_audio, fs, [loc2 temp '.wav'] );
		case 'sp3'
		    disp([temp '-----' num2str(3)])
		    disp([loc1 sp3])
		    disp(['------' num2str(start(i)) '------' num2str(stop(i)/fs) '------']);
		    seg_audio = audioread([loc1 sp3], [start(i), stop(i)]);
		    disp([loc2 temp '.wav'])
		    Write_File( seg_audio, fs, [loc2 temp '.wav'] );
	    end
	    
	    disp([loc1 ar1])
	    seg_audio_A1 = audioread([loc1 ar1], [start(i), stop(i)]);
	    disp([loc_A1 temp '.wav'])
	    Write_File( seg_audio_A1, fs, [loc_A1 temp '.wav'] );
	    
	    disp([loc1 ar2])
	    seg_audio_A2 = audioread([loc1 ar2], [start(i), stop(i)]);
	    disp([loc_A2 temp '.wav'])
	    Write_File( seg_audio_A2, fs, [loc_A2 temp '.wav'] );    
	    
	    disp([loc1 ar3])
	    seg_audio_A3 = audioread([loc1 ar3], [start(i), stop(i)]);
	    disp([loc_A3 temp '.wav'])
	    Write_File( seg_audio_A3, fs, [loc_A3 temp '.wav'] );
	    
	    disp([loc1 ar4])
	    seg_audio_A4 = audioread([loc1 ar4], [start(i), stop(i)]);
	    disp([loc_A4 temp '.wav'])
	    Write_File( seg_audio_A4, fs, [loc_A4 temp '.wav'] );    
	    
	%     if isequal(ch,4)
	%     disp([loc1 ar4])
	%     seg_audio_A4 = audioread([loc1 ar4], [start(i), stop(i)]);
	%     disp([loc_A4 temp '.wav'])
	%     Write_File( seg_audio_A4, fs, [loc_A4 temp '.wav'] );    
	%     end
	    
	    if isequal(ch,5)
	    disp([loc1 ar5])
	    seg_audio_A5 = audioread([loc1 ar5], [start(i), stop(i)]);
	    disp([loc_A5 temp '.wav'])
	    Write_File( seg_audio_A5, fs, [loc_A5 temp '.wav'] );    
	    end    
	end
else

input_dir=['../' input enhan '/'];
exist(input_dir)
input_dir
files=dir([input_dir '*.wav']);
files
files.name
no_files=length(files)
fs=48000;
start = floor(start * fs);
stop = floor(stop * fs);
out_dir=['../audio/segmented/' enhan];
	for j=1:no_files
		for i = 1 : length(spk)
		    temp = char(spk(i));
		    switch temp(1:3)
			case 'sp1'
			    disp([temp '-----' num2str(1)])
			    %disp([loc sp1])
			    seg_audio = audioread([input_dir files(j).name], [start(i), stop(i)]);
			    disp([out_dir '/' temp '.wav'])
			    Write_File( seg_audio, fs, [out_dir '/' temp '.wav'] );
			case 'sp2'
			    disp([temp '-----' num2str(2)])
			    %disp([loc sp2])
			    seg_audio = audioread([input_dir files(j).name], [start(i), stop(i)]);
			    disp([out_dir '/' temp '.wav'])
			    Write_File( seg_audio, fs, [out_dir '/' temp '.wav'] );
			case 'sp3'
			    disp([temp '-----' num2str(3)])
			    %disp([loc sp3])
			    seg_audio = audioread([input_dir files(j).name] , [start(i), stop(i)]);
			    disp([out_dir '/'  temp '.wav'])
			    Write_File( seg_audio, fs, [out_dir '/' temp '.wav'] );
		   end
		end
	end

end




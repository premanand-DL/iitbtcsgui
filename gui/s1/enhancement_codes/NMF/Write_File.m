
function [  ] = Write_File( Y,Fs1,Path_Y )
        Index = find(Path_Y=='/',1,'last'); 
        Dir_Name = Path_Y(1:(Index-1));
        if (exist(Dir_Name,'dir')==0)
            disp ('Folder Created')
            disp (Path_Y)
            mkdir(Dir_Name)
        end
	[Y] = norm_wav(Y);
        audiowrite(Path_Y,Y,Fs1);
end


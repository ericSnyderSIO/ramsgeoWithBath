function PGrid = ReadRamPGridmod( rgrid_file )
% Stolen from ActUp ReadRamPGrid.m

RecLenDependent = -1;
HeadJunkFieldNum = 1;
HeadJunkFieldSiz = 'uint32';
DataJunkFieldNum = 2;
DataJunkFieldSiz = 'uint32';
NzFieldSiz       = 'int32';
DataFieldNum     = RecLenDependent;
DataFieldSiz     = 'float32';

FileID = fopen(rgrid_file, 'r', 'ieee-le');

PGrid = [];


if FileID >= 0
  % skip header junk bytes 
  [Junk, Count0] = fread(FileID, HeadJunkFieldNum, HeadJunkFieldSiz);  
  % read number of records in range slice (number of depths in grid)
  [Nz, Count1] = fread(FileID, 1, NzFieldSiz);
  % record length is the size of the range slice ... that is the number of depths
  if DataFieldNum == RecLenDependent
    RecordLen = Nz;  % junk bytes (potentially) added after this many fields 
  else 
    RecordLen = DataFieldNum;
  end  
   
  %disp([int2str(Nz) ' depth elements']);
  
  if (Count1 == 1) & (Nz > 0)
    DoneAll = false;
    PGrid = zeros(Nz, 1);
    PColumn = zeros(Nz, 1);
    
    ICol = 1;
    while ~DoneAll
      %ICol
      DoneCol = false;
      StartSub = 1;
      
      while ~DoneCol & ~DoneAll   
        EndSub = StartSub + 2*RecordLen - 1;
        if EndSub > 2*Nz
          EndSub = 2*Nz;
          DoneCol = true;
        end
        NRead = ((EndSub - StartSub) + 1)/2;
        if NRead > 0
          %Skip junk at start of each column / data record
          [Junk, Count0] = fread(FileID, DataJunkFieldNum, DataJunkFieldSiz);            
          if  Count0 < DataJunkFieldNum % premature eof or other problem?
            DoneAll = 1;
            
          else             
            [PFlat, Count2] = fread(FileID, 2*NRead, DataFieldSiz);    
            if Count2 == 2*NRead     % OK ?
              istart = (StartSub+1)/2;
              iend   = EndSub/2;
              PColumn(istart:iend, 1) = PFlat(StartSub:2:(EndSub-1)) + sqrt(-1)*PFlat((StartSub+1):2:EndSub);
              StartSub = EndSub + 1;
            else                     % premature eof or other problem?
              DoneAll = true;
            end
          end
          
        else
          %disp('NRead <= 0');
          %NRead
          DoneCol = true;
        end
        
      end 
      if ~DoneAll
        PGrid(:, ICol) = PColumn(:);
        ICol = ICol+1;
      end
    end
    
  end
  fclose(FileID);
end

end


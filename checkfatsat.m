function checkfatsat

% This function loads selected .nii files and creates a .gif file in which
% the nth frame is the difference between the .nii file's n+1 and nth frame
% Multiple .nii files can be selected (provided they are in the same
% directory) and a .gif will be created for each.

    [fn, path] = uigetfile('*.nii', ...
        'Please select image file(s)',...
        'multiselect','on');
    if ~iscell(fn)
        if fn==0
            % No file specified, do nothing
        else
            fn = cellstr(fn);
        end
    end
    for x = 1:length(fn)
        
        %----------------------%
        % Get .nii header info %
        %----------------------%
        filename = [path, fn{x}];
        if strncmp(filename(end-2:end),'.gz',3)
            msgbox({'Can''t read compressed files'},'Error')
            continue
        end
        bswap=false;
        test=true;
        while(test)
            if(bswap)
                fid=fopen(filename,'rb','b');
            else
                fid=fopen(filename,'rb','l');
            end    
            if(fid<0)
                 fprintf('could not open file %s\n',filename);
                 return
            end

            %get the file size
            fseek(fid,0,'eof');
            info.Filesize = ftell(fid); 
            fseek(fid,0,'bof');
            info.Filename=filename;
            info.SizeofHdr=fread(fid,1,'int');
            info.DataType=fread(fid, 10, 'uint8=>char')';
            info.DbName=fread(fid, 18, 'uint8=>char')';
            info.Extents=fread(fid,1,'int');
            info.SessionError=fread(fid,1,'uint16');
            info.Regular=fread(fid, 1, 'uint8=>char')';
            info.DimInfo=fread(fid, 1, 'uint8=>char')';
            swaptemp=fread(fid, 1, 'uint16')';
            info.Dimensions=fread(fid,7,'uint16')'; % dim = [ number of dimensions x,y,z,t,c1,c2,c3];

            if(swaptemp(1)<1||swaptemp(1)>7), bswap=true; fclose(fid); else test=false; end
        end
        info.headerbswap=bswap;
        info.IntentP1=fread(fid,1,'float');
        info.IntentP2=fread(fid,1,'float');
        info.IntentP3=fread(fid,1,'float');
        info.IntentCode=fread(fid,1,'uint16');
        info.DataType=fread(fid,1,'uint16');
        datatypestr{1}={0,'UNKNOWN',  0}; % what it says, dude           
        datatypestr{2}={1,'BINARY',   1}; % binary (1 bit/voxel)         
        datatypestr{3}={2,'UINT8'  ,  8};% unsigned char (8 bits/voxel) 
        datatypestr{4}={4,'INT16'   , 16}; % signed short (16 bits/voxel) 
        datatypestr{5}={8,'INT32'  ,  32}; % signed int (32 bits/voxel)   
        datatypestr{6}={16,'FLOAT' ,  32}; % float (32 bits/voxel)        
        datatypestr{7}={32,'COMPLEX', 64}; % complex (64 bits/voxel)      
        datatypestr{8}={64,'DOUBLE',  64}; % double (64 bits/voxel)       
        datatypestr{9}={128,'RGB'  ,  24}; % RGB triple (24 bits/voxel)   
        datatypestr{10}={255,'ALL'  ,  0}; % not very useful (?)          
        datatypestr{11}={256,'INT8' ,  8}; % signed char (8 bits)         
        datatypestr{12}={512,'UINT16', 16}; % unsigned short (16 bits)     
        datatypestr{13}={768,'UINT32', 32}; % unsigned int (32 bits)       
        datatypestr{14}={1024,'INT64', 64}; % long long (64 bits)          
        datatypestr{15}={1280,'UINT64',     64}; % unsigned long long (64 bits) 
        datatypestr{16}={1536,'FLOAT128',   128}; % long double (128 bits)       
        datatypestr{17}={1792,'COMPLEX128', 128}; % double pair (128 bits)       
        datatypestr{18}={2048,'COMPLEX256', 256}; % long double pair (256 bits)  
        datatypestr{19}={2304,'RGBA32', 32}; % 4 byte RGBA (32 bits/voxel) 
        info.datatypestr='UNKNOWN';
        info.bitvoxel=0;
        for i=1:19
            if(datatypestr{i}{1}==info.DataType)
                info.DataTypeStr=datatypestr{i}{2};
                info.BitVoxel=datatypestr{i}{3};
            end
        end

        info.Bitpix=fread(fid,1,'uint16');
        info.SliceStart=fread(fid,1,'uint16');
        temp=fread(fid,1,'float');
        info.PixelDimensions=fread(fid,7,'float');

        info.VoxOffset=fread(fid,1,'float');
        info.RescaleSlope=fread(fid,1,'float');
        info.RescaleIntercept=fread(fid,1,'float');
        info.SliceEnd=fread(fid,1,'uint16');
        info.SliceCode=fread(fid, 1, 'uint8=>char')';
        info.XyztUnits=fread(fid, 1, 'uint8')';
        dataunitsstr{1}={'UNKNOWN', 0}; %! NIFTI code for unspecified units. 
        dataunitsstr{2}={'METER',   1};  %! NIFTI code for meters. 
        dataunitsstr{3}={'MM',    2};  %! NIFTI code for millimeters. 
        dataunitsstr{4}={'MICRON ', 3};  %! NIFTI code for micrometers. 
        dataunitsstr{5}={'SEC',    8};  %! NIFTI code for seconds. 
        dataunitsstr{6}={'MSEC',   16};  %! NIFTI code for milliseconds. 
        dataunitsstr{7}={'USEC',  24};  %! NIFTI code for microseconds. 
        dataunitsstr{8}={'HZ',  32};  %! NIFTI code for Hertz. 
        dataunitsstr{9}={'PPM',  40};  %! NIFTI code for ppm. 
        dataunitsstr{10}={'RADS',  48};  %! NIFTI code for radians per second. 
        info.xyzt_unitsstr='UNKNOWN';
        for i=1:10,
            if(dataunitsstr{i}{2}==info.XyztUnits)
                info.XyztUnitsStr=dataunitsstr{i}{1};
            end
        end

        info.CalMax=fread(fid,1,'float');
        info.CalMin=fread(fid,1,'float');
        info.Slice_duration=fread(fid,1,'float');
        info.Toffset=fread(fid,1,'float');
        info.Glmax=fread(fid,1,'int');
        info.Glmin=fread(fid,1,'int');
        info.Descrip=fread(fid, 80, 'uint8=>char')';
        info.AuxFile=fread(fid, 24, 'uint8=>char')';
        info.QformCode=fread(fid,1,'uint16');
        info.SformCode=fread(fid,1,'uint16');
        info.QuaternB=fread(fid,1,'float');
        info.QuaternC=fread(fid,1,'float');
        info.QuaternD=fread(fid,1,'float');
        info.QoffsetX=fread(fid,1,'float');
        info.QoffsetY=fread(fid,1,'float');
        info.QoffsetZ=fread(fid,1,'float');
        info.SrowX=fread(fid,4,'float');
        info.SrowY=fread(fid,4,'float');
        info.SrowZ=fread(fid,4,'float');
        info.IntentName=fread(fid, 16, 'uint8=>char')';
        info.Magic=fread(fid, 4, 'uint8=>char')';

        fclose(fid);
        
        %--------------------------%
        % Load the .nii image data %
        %--------------------------%
        if info.Dimensions(4)==1
            continue
        else
            precision = lower(info.DataTypeStr);
            imfile = fopen(filename);
            fread(imfile,176,'int16');
            imdata = fread(imfile,precision);
            fclose(imfile);
            imdata = (imdata-min(imdata))/(max(imdata)-min(imdata));
            imdata = reshape(imdata,...
                info.Dimensions(1),info.Dimensions(2),...
                info.Dimensions(3),info.Dimensions(4));
            if info.SformCode>0
                [xscale,xorder] = max(abs(info.SrowX(1:3)));
                [yscale,yorder] = max(abs(info.SrowY(1:3)));
                [zscale,zorder] = max(abs(info.SrowZ(1:3)));
                scale = [xscale, yscale, zscale];
                for n=1:info.Dimensions(4)
                    imdata(:,:,:,n)=permute(imdata(:,:,:,n),...
                        [xorder yorder zorder]);
                end
                if info.SrowX(xorder)<0
                    imdata = flip(imdata,1);
                end
                if info.SrowY(yorder)<0
                    imdata = flip(imdata,2);
                end
                if info.SrowZ(zorder)<0
                    imdata = flip(imdata,3);
                end
            else
                b = info.QuaternB;
                c = info.QuaternC;
                d = info.QuaternD;
                a = sqrt(1-b^2-c^2-d^2);
                R = [a^2+b^2-c^2-d^2 2*(b*c-a*d) 2*(b*d+a*c);...
                    2*(b*c+a*d) a^2+c^2-b^2-d^2 2*(c*d-a*b);...
                    2*(b*d-a*c) 2*(c*d+a*b) a^2+d^2-b^2-c^2];
                Pixdim = info.PixelDimensions(1:3);
                R = R.*[Pixdim, Pixdim, Pixdim];
                [xscale,xorder] = max(abs(R(1,:)));
                [yscale,yorder] = max(abs(R(2,:)));
                [zscale,zorder] = max(abs(R(3,:)));
                scale = [xscale, yscale, zscale];
                for n=1:info.Dimensions(4)
                    imdata(:,:,:,n)=permute(imdata(:,:,:,n),...
                        [xorder yorder zorder]);
                end
                if R(1,xorder)<0
                    imdata = flip(imdata,1);
                end
                if R(2,yorder)<0
                    imdata = flip(imdata,2);
                end
                if R(3,zorder)<0
                    imdata = flip(imdata,3);
                end
            end
            
            %------------------------%
            % Create difference data %
            %------------------------%
            ddata = zeros(size(imdata));
            ddata = ddata(:,:,:,1:end-1);
            for n = 1:size(ddata,4)
                ddata(:,:,:,n) = imdata(:,:,:,n+1)-imdata(:,:,:,n); 
            end
            ddata = (ddata.*20)+.5;

            imsets = [0.05,0.5,0.0,1.0,0.7,...
                0,...       % Starting slice to view
                1,...       % Starting frame to view
                ndims(imdata),...   % Dimensionality of data
                round(scale(xorder)*size(imdata,1)),...   % L-R scale factor
                round(scale(yorder)*size(imdata,2)),...   % A-P scale factor
                round(scale(zorder)*size(imdata,3))];     % S-I scale factor
            dispim = zeros(2*imsets(10),5*imsets(9),size(ddata,4));
            for n = 1:size(ddata,4)
                im1 = imresize(rot90(squeeze(...
                    imdata(:,:,round(size(imdata,3)/4),n)),...
                    1),[imsets(10) imsets(9)]);
                im2 = imresize(rot90(squeeze(...
                    imdata(:,:,round(3*size(imdata,3)/8),n)),...
                    1),[imsets(10) imsets(9)]);
                im3 = imresize(rot90(squeeze(...
                    imdata(:,:,round(size(imdata,3)/2),n)),...
                    1),[imsets(10) imsets(9)]);
                im4 = imresize(rot90(squeeze(...
                    imdata(:,:,round(5*size(imdata,3)/8),n)),...
                    1),[imsets(10) imsets(9)]);
                im5 = imresize(rot90(squeeze(...
                    imdata(:,:,round(3*size(imdata,3)/4),n)),...
                    1),[imsets(10) imsets(9)]);
                
                im6 = imresize(rot90(squeeze(...
                    ddata(:,:,round(size(ddata,3)/4),n)),...
                    1),[imsets(10) imsets(9)]);
                im7 = imresize(rot90(squeeze(...
                    ddata(:,:,round(3*size(ddata,3)/8),n)),...
                    1),[imsets(10) imsets(9)]);
                im8 = imresize(rot90(squeeze(...
                    ddata(:,:,round(size(ddata,3)/2),n)),...
                    1),[imsets(10) imsets(9)]);
                im9 = imresize(rot90(squeeze(...
                    ddata(:,:,round(5*size(ddata,3)/8),n)),...
                    1),[imsets(10) imsets(9)]);
                im10 = imresize(rot90(squeeze(...
                    ddata(:,:,round(3*size(ddata,3)/4),n)),...
                    1),[imsets(10) imsets(9)]);
                dispim1 = cat(2,im1,im2,im3,im4,im5);
                dispim2 = cat(2,im6,im7,im8,im9,im10);
                dispim(:,:,n) = cat(1,dispim1,dispim2);
            end

            %--------------------------------%
            % Display the image and save gif %
            %--------------------------------%
            outname = [filename(1:end-4) '.gif'];
            for n = 1:size(dispim,3)
                figure(1),imshow(dispim(:,:,n))
                frame = getframe(1);
                im = frame2im(frame);
                [A,map] = rgb2ind(im,256);
                if n==1
                    imwrite(A,map,outname,'gif','LoopCount',inf,'DelayTime',.2)
                else
                    imwrite(A,map,outname,'gif','WriteMode','append','DelayTime',.2)
                end
            end
            
        end
    end
end
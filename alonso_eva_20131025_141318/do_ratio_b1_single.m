function do_ratio_b1_single(img1, alpha, output)
%
%  function do_ratio_b1_single(img1, alpha, output)
%
%   img1         :   minc file
%   alpha        :   pulse angle for first image in degrees
%                     (second image is double this)
%   output       :   name for output file
%
%  Note: output is clamped to [0, 4]
%-----------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------
%
%   Based on do_ratio_b1(), function orginally coded by JGSled
%   Modified to work with single image series
%   Updated Oct 2006 Ives Levesque
%       - commented and cleaned code
%       - inserted output range specification for 'short' image type
%       - inserted existence and dimensions check for input image files
%       - implemented multi-slice capability
%   Updated Oct 2006 Ives Levesque
%       - Added multislice capability
%
%-----------------------------------------------------------------------------------

flag_minc_loader = 'niak';

bounds = [0 4];
output_range = [-32768 32767];

%-----------------------------------------------------------------------------------
% open input data files

% In case emma isn't in path, use niak.
switch flag_minc_loader
  case 'emma'

    h = openimage(img1);
    w = getimageinfo(h, 'ImageWidth');
    l = getimageinfo(h, 'ImageHeight');
    n = getimageinfo(h, 'NumSlices');


    for slice = 1:n
        image1(:,slice) = getimages(h,slice,1);
        image2(:,slice) = getimages(h,slice,2);
    end

    closeimage(h)
  case 'niak'
    [h_hdr,h] = niak_read_minc(img1);
    w = h_hdr.info.dimensions(1);
    l = h_hdr.info.dimensions(2);
    N = h_hdr.info.dimensions(3);
    tmp = squeeze(h(:,:,:,1));
    image1 = reshape(tmp,w*l,N);
    tmp = squeeze(h(:,:,:,2));
    image2 = reshape(tmp,w*l,N);
    clear tmp
end


r = image2./image1;



%-----------------------------------------------------------------------------------
% choose solution
if(alpha <= 45)
  sp = 1;
else
  sp = -1;
end

% compute b1
b1 = acos(r/4 + sp*(sqrt(r.^2 + 8)/4))/(alpha*pi/180);

% clamp between bounds
b1 = b1 + (b1 > bounds(2)).*(bounds(2)-b1) + (b1 < bounds(1)).*(bounds(1)-b1);

% Ensure b1 is not complex
b1 = abs(b1);

%xdisp(reshape(b1,w,l));

%-----------------------------------------------------------------------------------

% produce output map

switch flag_minc_loader
  case 'emma'
    template = img1;
    h =  newimage(output, [0 n l w], template, 'short', output_range);
    putimages(h, b1, 1:n);
    closeimage(h)
  case 'niak'
    b1 = reshape(b1,w,l,N);  
    b1_hdr = h_hdr;
    b1_hdr.file_name = output;
    
    % Remove 4th dimension detail from header files
    temp = b1_hdr.details;
    temp = rmfield(temp,'time');
    b1_hdr.details = temp;
    b1_hdr.info.dimensions = b1_hdr.info.dimensions(1:3);
    b1_hdr.info.dimension_order = b1_hdr.info.dimension_order(1:3);

    niak_write_minc_ss(b1_hdr,b1);
    
%     if N==1
%         % **** Next section needed because of a flaw in Niak ****
%         % When writing out a single slice image, Niak (or at lease, 0.6.3) does not
%         % write out the 3rd dimension (of size 1).
% 
%         [~,zStart]=system(['mincinfo -attvalue zspace:start ' img1]);
%         [~,zStep]=system(['mincinfo -attvalue zspace:step ' img1]);
% 
%         system(['mincconcat -clobber -concat_dimension zspace -start ' num2str(str2double(zStart)) ' -step 1 ' output ' temp.mnc']) % even if I set step to something different to 1, it always makes it 1 ??!?
%         system(['mincresample -clobber -zstep ' num2str(str2double(zStep)) ' temp.mnc ' output]) 
%         system('rm temp.mnc')
%     end
      
end
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
% FUNCTIONS
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------
%-----------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------
function check_input_file(filename,input_type)

[fid, message] = fopen(filename,'r');
if(fid == -1)
    error(sprintf('\nError in do_ratio_b1: cannot find %s file: %s\n', input_type, filename));
else
    fclose(fid);        
end

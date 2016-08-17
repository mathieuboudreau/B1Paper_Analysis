function fitDataBSB1(img1, img2, flipAngle, duration, pulseType, output)
%
% b1_map_blochsiegert(img1, img2, flipAngle, duration, pulseType, output)
%

flag_minc_loader = 'niak';

% test if output file already exists
[fid, ~] = fopen(output,'r');
if(fid ~= -1)
  fprintf('\nError in b1_map: cannot overwrite B1-map output file %s\n', ...
      output);
  fclose(fid);
  return
end

switch flag_minc_loader
  case 'emma'

    h1 = openimage(img1);
    w = getimageinfo(h1, 'ImageWidth');
    l = getimageinfo(h1, 'ImageHeight');
    N = getimageinfo(h1, 'NumSlices');
    bsPosPhase = getimages(h1,1:N);

    h2 = openimage(img2);
    bsNegPhase = getimages(h2,1:N);

    closeimage(h1);
    closeimage(h2);
  case 'niak'
    [h1_hdr,h1] = niak_read_minc(img1);
    w = h1_hdr.info.dimensions(1);
    l = h1_hdr.info.dimensions(2);
    N = h1_hdr.info.dimensions(3);
    bsPosPhase = reshape(h1,w*l,N);
    
    [h2_hdr,h2] = niak_read_minc(img2);
    bsNegPhase = reshape(h2,w*l,N);
      
end

bsPosPhase = bsPosPhase./4096.*pi;
bsNegPhase = bsNegPhase./4096.*pi;

switch pulseType
    case 'fermi'
        Kbs = 74.01; % in rad/G^2/msec
        gamma = 26745; % in rad/G
        AmpInt = 356.259361;
        
    case 'gauss'
        Kbs = 39.4; % in rad/G^2/msec
        gamma = 26747; % in rad/G
        AmpInt = 247.9;
end

bsB1Map = (abs(bsPosPhase - bsNegPhase)<pi).*sqrt(abs(bsPosPhase - bsNegPhase)./2./Kbs)+ (abs(bsPosPhase - bsNegPhase)>=pi).*sqrt(abs(bsPosPhase - bsNegPhase-2*pi)./2./Kbs); % in Gauss
bsB1Map = (gamma*AmpInt/512*duration).*bsB1Map; %in radians
bsB1Map = bsB1Map./pi.*180; % in degrees
bsB1Map = bsB1Map./flipAngle; % divided by nominal flip

%bounds = [0.0 4.0];
%bsB1Map = bsB1Map + (bsB1Map > bounds(2)).*(bounds(2)-bsB1Map) + (bsB1Map < bounds(1)).*(bounds(1)-bsB1Map);

switch flag_minc_loader
  case 'emma'

    template = img1;
    h =  newimage(output, [0 N l w], template, 'short');
    putimages(h, bsB1Map, 1:N);
    closeimage(h);
    
  case 'niak'
    
    bsB1Map = reshape(bsB1Map,w,l,N);  
    b1_hdr = h1_hdr;
    b1_hdr.file_name = output;
    niak_write_minc_ss(b1_hdr,bsB1Map);
    
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


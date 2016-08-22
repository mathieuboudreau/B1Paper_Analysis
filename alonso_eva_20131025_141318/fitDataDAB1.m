function fitDataDAB1 (subjectID, dab1Indeces, b1Out, ref, smallestAngle) 
%%
%

%%
% We assume there are always two B1 files
if strcmp(b1Out,'b1_bic_tse.mnc')
    files{1} = [subjectID '_' num2str(dab1Indeces) '_mri_1.mnc'];
    files{2} = [subjectID '_' num2str(dab1Indeces) '_mri_2.mnc'];
else
    files{1} = [subjectID '_' num2str(dab1Indeces(1)) '_mri.mnc'];
    files{2} = [subjectID '_' num2str(dab1Indeces(2)) '_mri.mnc'];
end
filesAligned = {'DAB1_1.mnc', 'DAB1_2.mnc'};


% Align the files to ref and resample them to the same resolution
for ii=1:numel(files)
    mincResampleAndAlign(files{ii}, ref, filesAligned{ii});
end

% Now perform the AFI B1 mapping
% N, the ratio of TR1 to TR2 is equal to 5

[dab1_1hdr, dab1_1] = niak_read_minc('DAB1_1.mnc');
[~, dab1_2] = niak_read_minc('DAB1_2.mnc');

r = abs(dab1_2./dab1_1);      
cos_arg = 1/2*r;

% filter out cases where r > 1:
% r should not be greater than one, so must be noise
cos_arg = double(cos_arg).*(r<=2) + ones(size(r)).*(r>2);

alpha = acosd(cos_arg); %alpha is in deg

b1 = alpha/smallestAngle;


%mincSaveImage(b1, b1Out, ref);
b1hdr = dab1_1hdr;
b1hdr.file_name = b1Out;
niak_write_minc_ss(b1hdr,b1);

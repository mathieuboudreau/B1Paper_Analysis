%% plotBlurredB1Maps
%

clear all
clc
close all

%% Debug flag
%

% If DEBUG=1, b1_blur and b1_spline folders will be removed at the end for all subjects.
DEBUG=0;

%% Data info
%

dataDir = [pwd '/data'];
maskFile = 'brain_mask_es_2x2x5.mnc';

subjectIDs = dirs2cells(dataDir);
numSubjects = size(subjectIDs,1);

customBWRmap = createBWRcolormap();
WMFlag = 1;

%%
%

oldDir = cd;

for counterSubject = 1:numSubjects
    cd([dataDir '/' subjectIDs{counterSubject}])

    if(WMFlag == 1)
        [~, b1{1}]=niak_read_minc('b1/b1_clt_tse.mnc');
        [~, b1{2}]=niak_read_minc('b1/b1_clt_gre_bs_cr_fermi.mnc');
        [~, b1{3}]=niak_read_minc('b1/b1_clt_afi.mnc');
        [~, b1{4}]=niak_read_minc('b1/b1_epseg_da.mnc');

        [~, blur{1}]=niak_read_minc('b1_gauss_wm/b1_clt_tse.mnc');
        [~, blur{2}]=niak_read_minc('b1_gauss_wm/b1_clt_gre_bs_cr_fermi.mnc');
        [~, blur{3}]=niak_read_minc('b1_gauss_wm/b1_clt_afi.mnc');
        [~, blur{4}]=niak_read_minc('b1_gauss_wm/b1_epseg_da.mnc');
    else
        [~, b1{1}]=niak_read_minc('b1_whole_brain/b1_clt_tse.mnc');
        [~, b1{2}]=niak_read_minc('b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc');
        [~, b1{3}]=niak_read_minc('b1_whole_brain/b1_clt_afi.mnc');
        [~, b1{4}]=niak_read_minc('b1_whole_brain/b1_epseg_da.mnc');

        [~, blur{1}]=niak_read_minc('b1_gauss/b1_clt_tse.mnc');
        [~, blur{2}]=niak_read_minc('b1_gauss/b1_clt_gre_bs_cr_fermi.mnc');
        [~, blur{3}]=niak_read_minc('b1_gauss/b1_clt_afi.mnc');
        [~, blur{4}]=niak_read_minc('b1_gauss/b1_epseg_da.mnc');
    end
    
    [~,mask]=niak_read_minc(maskFile);

    mask = logical(mask);

    %%
    %

    for ii = 1:length(b1)
        rawB1{ii} = imrotate(b1{ii}.*mask,-90);
        blurB1{ii} = imrotate(blur{ii}.*mask,-90);
    end

    figure(counterSubject*100 + 1), imagesc([rawB1{1:4}; blurB1{1:4}]), caxis([0.7 1.2]), colormap(jet),  axis image

    %%
    %

    for ii = 1:length(b1)
        pDiff{ii} = (blurB1{ii}-rawB1{ii})./rawB1{ii}.*100;
    end

    figure(counterSubject*100 + 2), imagesc([pDiff{1:4}]), caxis([-5 5]), colormap(customBWRmap),  axis image

    %%
    %

    for ii = 1:length(b1)
        pDiffRawRelRef{ii} = (rawB1{1}-rawB1{ii})./rawB1{1}.*100;
    end

    figure(counterSubject*100 + 3), imagesc([pDiffRawRelRef{1:4}]), caxis([-10 10]), colormap(customBWRmap),  axis image

    %%
    %

    for ii = 1:length(b1)
        pDiffRelRef{ii} = (blurB1{1}-blurB1{ii})./blurB1{1}.*100;
    end

    figure(counterSubject*100 + 4), imagesc([pDiffRelRef{1:4}]), caxis([-10 10]), colormap(customBWRmap),  axis image
    
    %% For 95th percentiles
    subjPDiffRelRef{counterSubject} = pDiffRelRef;
    refBllurredB1{counterSubject} = rawB1{1};
end

%% 95th percentiles
%
nominal = ones(size(blurB1{1}));
pooledBlurredB1=cell(1,4);
pDiffNominalRelRef=[];
for counterSubject = 1:6
    for ii = 1:4
       pooledBlurredB1{ii} = [pooledBlurredB1{ii}; subjPDiffRelRef{counterSubject}{ii}(:)]; 
    end
    
    pDiffNominalRelRef = [pDiffNominalRelRef; (refBllurredB1{counterSubject}-nominal)./refBllurredB1{counterSubject}.*100];
end

for ii = 1:4
    pooledBlurredB1{ii}(isnan(pooledBlurredB1{ii}))=[];
    pooledBlurredB1{ii}(isinf(pooledBlurredB1{ii}))=[];
    pooledBlurredB1{ii}(abs(pooledBlurredB1{ii}-100)<0.01)=[];

    prctile(abs(pooledBlurredB1{ii}),95)
end

pDiffNominalRelRef(isnan(pDiffNominalRelRef))=[];
pDiffNominalRelRef(isinf(pDiffNominalRelRef))=[];
pDiffNominalRelRef(abs(pDiffNominalRelRef-100)<0.01)=[];

prctile(abs(pDiffNominalRelRef),95)

cd(oldDir)

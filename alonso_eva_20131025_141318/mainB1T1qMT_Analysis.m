
%%
%
[t1_hdr,t1{1}] = niak_read_minc('t1/t1_clt_tse_ir.mnc');
t1{5} = t1{1};
t1{9}=t1{1};
t1{13}=t1{1};


[~,t1{2}] = niak_read_minc('t1/t1_ep_seg_b1_clt_afi.mnc');
t1{6} = t1{2};
t1{10}=t1{2};
t1{14}=t1{2};

[~,t1{3}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_tse.mnc');
[~,t1{4}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_tse.mnc');

[~,t1{7}] = niak_read_minc('t1/t1_gre_vfa_b1_epseg_da.mnc');
[~,t1{8}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_epseg_da.mnc');

[~,t1{11}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_afi.mnc');
[~,t1{12}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_afi.mnc');

[~,t1{15}] = niak_read_minc('t1/t1_gre_vfa_b1_clt_bs.mnc');
[~,t1{16}] = niak_read_minc('t1/t1_clt_vfa_spoil_b1_clt_bs.mnc');

colours = 'brgkyrgkyrgkyrgk';
xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2);
yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1);

% Pre-allocate cells
reshapedT1 = cell(1,length(t1));
yFreq = cell(1,length(t1));
xT1 = cell(1,length(t1));

for ii=1:length(t1)

    if ii==5 || ii==9 || ii==13
        
        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);
    elseif ii==6 || ii==10 || ii==14
        
        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);       
    else

        reshapedT1{ii} = t1{ii}(:);
        reshapedT1{ii}(reshapedT1{ii}==0)=[];
        reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
        reshapedT1{ii}(reshapedT1{ii}<0.5)=[];

        % Calculate histogram data
        [yFreq{ii},xT1{ii}]=hist(reshapedT1{ii},25);
        plot(xT1{ii},yFreq{ii}./length(reshapedT1{ii}), colours(ii))
        hold on
    end
end
title('WM masked brain T1 histogram')
xlabel('T1 (s)')

namesB1 = {'clt\_tse','ep\_seg\_da','clt\_afi','clt\_bs'};
namesT1 = {'ir    ','ll    ','vfa   ','vfa\_opt'};



figure()
bottom = 0.5;
top = 1.5;



for ii = 1:length(t1)
    if ii==5 || ii==9 || ii==13
        %skip
    elseif ii==6 || ii==10 || ii==14
        %skip        
    else
        subplot(4,4,ii)
        imagesc(yFOV,xFOV,imrotate(t1{ii},-90))    
        caxis('manual') 
        caxis([bottom top]);
        axis image
    end
end

subplot(4,4,1)
title(namesT1{1})
ylabel(namesB1{1})

subplot(4,4,2)
title(namesT1{2})

subplot(4,4,3)
title(namesT1{3})

subplot(4,4,4)
title(namesT1{4})

subplot(4,4,5)
ylabel(namesB1{2})


subplot(4,4,9)
ylabel(namesB1{3})

subplot(4,4,13)
ylabel(namesB1{4})

% 4 B1 graphs of 

figure()
colours = 'brgk';


for ii = 1:length(t1)/4
    
    subplot(2,2,ii)
    for jj = 1:length(t1)/4

        plot(xT1{(jj+(ii-1)*4)},yFreq{(jj+(ii-1)*4)}./length(reshapedT1{(jj+(ii-1)*4)}), colours(jj))
        hold on 

    end
        
end

for ii = 1:length(t1)/4
    subplot(2,2,ii)
    title(namesB1{ii})
    xlabel('T1 (s)')
    legend(namesT1)
end

figure()
colours = 'brgk';

for ii = 1:length(t1)/4

    subplot(2,2,ii)
    for jj = 1:length(t1)/4

        plot(xT1{(ii+(jj-1)*4)},yFreq{(ii+(jj-1)*4)}./length(reshapedT1{(ii+(jj-1)*4)}), colours(jj))
        hold on 
        
    end
        
end


for ii = 1:length(t1)/4
    
    subplot(2,2,ii)
    title(namesT1{ii})
    xlabel('T1 (s)')
    if ii~=1 && ii~=2
        legend(namesB1)
    end
end
%% Make Table

%                 ** T1 Table**   
%
%       |   IR   |   LL   |   VFA  |VFAspoil|
%--------------------------------------------
%   DA  |        |        |        |        |
%--------        ----------------------------
%DA Sled|        |        |        |        |
%--------        ----------------------------
%  AFI  |        |        |        |        |
%--------        ----------------------------
%   BS  |        |        |        |        |
%--------------------------------------------



% Get means


t1Means = zeros(4);
t1STDs = zeros(4);

for ii = 1:length(t1)
 
    if ii==5 || ii==9 || ii==13
        %skip
    else   
        t1Means(ii) = mean(reshapedT1{ii}(:));
        t1STDs(ii) = std(reshapedT1{ii}(:));
    end
    
end

t1Means = t1Means'

t1STDs = t1STDs'

%% Make B1 maps and stats
%

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1/b1_clt_tse.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_tse.mnc')


system('mincresample -nearest_neighbour -like b1/b1_epseg_da.mnc mask/brain_wm_mask_resamp_epseg_2x2x5.mnc mask/temp.mnc')
system('mv mask/temp.mnc mask/brain_wm_mask_resamp_epseg_2x2x5.mnc')
system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_epseg_2x2x5.mnc b1/b1_epseg_da.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_epseg_da.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_es_2x2x5.mnc b1/b1_clt_afi.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_afi.mnc')

system('minccalc -expression ''abs(A[0]-1)<0.001?A[1]:0'' mask/brain_wm_mask_resamp_ll_2x2x5.mnc b1/b1_clt_gre_bs_cr_fermi.mnc b1/temp.mnc')
system('mv b1/temp.mnc b1/b1_clt_gre_bs_cr_fermi.mnc')

[~,b1{1}] = niak_read_minc('b1/b1_clt_tse.mnc');
[~,b1{2}] = niak_read_minc('b1/b1_epseg_da.mnc');
[~,b1{3}] = niak_read_minc('b1/b1_clt_afi.mnc');
[~,b1{4}] = niak_read_minc('b1/b1_clt_gre_bs_cr_fermi.mnc');


% Plot slice B1 maps
figure()
bottom = 0.7;
top = 1.3;
namesB1 = {'clt\_tse','epseg\_da','clt\_afi','clt\_bs'};

for ii = 1:length(b1)

    subplot(2,2,ii)
    imagesc(yFOV,xFOV,imrotate(b1{ii},-90))    
    caxis('manual') 
    caxis([bottom top]);
    axis image
end

for ii = 1:length(b1)
    subplot(2,2,ii)
    title(namesB1{ii})
end

% Plot B1 Histogram

figure()

% Pre-allocate cells
reshapedB1 = cell(1,length(b1));
yB1Freq = cell(1,length(b1));
xB1 = cell(1,length(b1));
colours = 'brgk';

for ii=1:length(b1)


    reshapedB1{ii} = b1{ii}(:);
    reshapedB1{ii}(reshapedB1{ii}==0)=[];
    reshapedB1{ii}(reshapedB1{ii}>1.5)=[];
    reshapedB1{ii}(reshapedB1{ii}<0.5)=[];
    % Calculate histogram data
    [yB1Freq{ii},xB1{ii}]=hist(reshapedB1{ii},50);

    plot(xB1{ii},yB1Freq{ii}./length(reshapedB1{ii}), colours(ii))
    hold on

end
title('WM masked brain B1 histogram')
xlabel('B1 (s)')
legend(namesB1)


% Plot slice B1 maps erros
figure()
bottom = 0.7;
top = 1.3;

for ii = 1:length(b1)
    if ii==1
        subplot(2,2,ii)
        imagesc(yFOV,xFOV,imrotate(b1{ii},-90))    
        caxis('manual') 
        caxis([bottom top]);
        axis image
    else
        subplot(2,2,ii)
        imagesc(yFOV,xFOV,imrotate(abs((b1{ii}-b1{1})./b1{2}*100),-90))    
        axis image   
        caxis('manual') 
        caxis([0 5]);
    end
    
end

for ii = 1:length(b1)
    subplot(2,2,ii)
    title(namesB1{ii})
end

%% Fit qMT parameter maps
%

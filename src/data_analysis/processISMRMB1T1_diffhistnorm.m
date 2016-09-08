

reshapedT1AllMethods=[];
reshapedT1AllSubjects=[];
reshapedB1All=[];
for counterSubject = 1:length(subjectID)
    [t1_hdr,t1{1}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_tse_ir.mnc']);
    [~,t1{2}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);
    [~,t1{3}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);    
    [~,t1{4}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);
    [~,t1{5}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);



    [~,b1{1}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_tse.mnc']);
    [~,b1{2}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_gre_bs_cr_fermi.mnc']);    
    [~,b1{3}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_afi.mnc']);    
    [~,b1{4}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_epseg_da.mnc']);

    [~,mask] = niak_read_minc([subjectID{counterSubject} '/mask/mask.mnc']);
    
    
    % Pre-allocate cells
    reshapedT1 = cell(1,length(t1));
    yFreq = cell(1,length(t1));
    xT1 = cell(1,length(t1));

    for ii=1:length(t1)
            reshapedT1{ii} = t1{ii}(:);
            reshapedT1{ii}(reshapedT1{ii}==0)=[];
            reshapedT1{ii}(reshapedT1{ii}>1.5)=[];
            reshapedT1{ii}(reshapedT1{ii}<0.5)=[];
    end
    

    reshapedT1AllSubjects=[reshapedT1AllSubjects;reshapedT1];

end
 
    
for ii=1:length(t1)
    
    for jj=1:length(subjectID)
        if jj==1
              reshapedT1AllMethods{ii}= reshapedT1AllSubjects{jj,ii};

        else
              reshapedT1AllMethods{ii} =  [reshapedT1AllMethods{ii};reshapedT1AllSubjects{jj,ii}];
        end
    end
end

% Calculate histogram data
colours = 'bkgrb';
set(0, 'DefaultAxesBox', 'on', 'DefaultAxesLineWidth', 1.5);
set(0, 'DefaultAxesFontSize', 16, 'DefaultAxesFontWeight', 'bold');

figure()

for ii=2:length(t1)
    [yFreq{ii},xT1{ii}]=hist(reshapedT1AllMethods{ii},80);
    plot(xT1{ii},yFreq{ii}./sum(yFreq{ii}), ['-' colours(ii)], 'LineWidth',4)
    hold on
end

h_xlabel=xlabel('T1 (s)');
set(h_xlabel,'FontWeight', 'bold' , 'FontSize',18, 'FontName', 'Arial');

h_ylabel=ylabel('a.u.');
set(h_ylabel,'FontWeight', 'bold' , 'FontSize',18, 'FontName', 'Arial');


h_legend=legend('Reference DA','Bloch-Siegert','AFI','EPI Double Angle');
set(h_legend,'FontWeight', 'bold' , 'FontSize',16, 'FontName', 'Arial');
%%
%


reshapedT1AllMethods=[];
reshapedT1AllSubjects=[];
reshapedB1All=[];
for counterSubject = 1:length(subjectID)
    [t1_hdr,t1{counterSubject,1}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_tse_ir.mnc']);
    [~,t1{counterSubject,2}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);
    [~,t1{counterSubject,3}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);
    [~,t1{counterSubject,4}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);
    [~,t1{counterSubject,5}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);
    [~,b1{counterSubject,1}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_tse.mnc']);
    [~,b1{counterSubject,2}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_gre_bs_cr_fermi.mnc']);
    [~,b1{counterSubject,3}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_clt_afi.mnc']);
    [~,b1{counterSubject,4}] = niak_read_minc([subjectID{counterSubject} '/b1/b1_epseg_da.mnc']);
    [~,mask] = niak_read_minc([subjectID{counterSubject} '/mask/mask.mnc']);
end
for ii=1:5
    t1_scatter{ii}=[t1{1,ii}(:);t1{2,ii}(:);t1{3,ii}(:);t1{4,ii}(:);t1{6,ii}(:);t1{6,ii}(:)];
end

allzeros=(t1_scatter{1}==0)&(t1_scatter{2}==0)&(t1_scatter{3}==0)&(t1_scatter{4}==0)&(t1_scatter{5}==0);
for ii=1:length(t1_scatter)
    reshapedT1_scatter{ii}=t1_scatter{ii};
    reshapedT1_scatter{ii}(allzeros)=[];
    %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}>1.5)=[];
    %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}<0.5)=[];
end


figure(),scatter(reshapedT1_scatter{2},reshapedT1_scatter{3})
axis([0.5 2 0.5 2])
xlabel(namesB1{1},'fontweight','bold','fontsize',12)
ylabel(namesB1{2},'fontweight','bold','fontsize',12)
x=reshapedT1_scatter{2};
y=reshapedT1_scatter{3};
p= polyfit(x,y,1);
f= polyval(p,x);
[a,b,c,d,e]=regress(x,y);
pearsCoeff=corr(reshapedT1_scatter{2},reshapedT1_scatter{3})
annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
title('VFA T1 (s)','fontweight','bold','fontsize',16)


figure(),scatter(reshapedT1_scatter{2},reshapedT1_scatter{4})
axis([0.5 2 0.5 2])
xlabel(namesB1{1},'fontweight','bold','fontsize',12)
ylabel(namesB1{3},'fontweight','bold','fontsize',12)
x=reshapedT1_scatter{2};
y=reshapedT1_scatter{4};
p= polyfit(x,y,1);
f= polyval(p,x);
[a,b,c,d,e]=regress(x,y);
pearsCoeff=corr(reshapedT1_scatter{2},reshapedT1_scatter{4})
annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
title('VFA T1 (s)','fontweight','bold','fontsize',16)

figure(),scatter(reshapedT1_scatter{2},reshapedT1_scatter{5})
axis([0.5 2 0.5 2])
xlabel(namesB1{1},'fontweight','bold','fontsize',12)
ylabel(namesB1{4},'fontweight','bold','fontsize',12)
x=reshapedT1_scatter{2};
y=reshapedT1_scatter{5};
p= polyfit(x,y,1);
f= polyval(p,x);
[a,b,c,d,e]=regress(x,y);
pearsCoeff=corr(reshapedT1_scatter{2},reshapedT1_scatter{5})
annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
title('VFA T1 (s)','fontweight','bold','fontsize',16)


%% Final Image
%


subjectID{1}='arseneault_ryan_20131015_140558';
subjectID{2}='caissie_jessica_20131015_152703';
subjectID{3}='mazerolle_erin_20131016_152802';
subjectID{4}='stikov_nikola_20131017_113942';
subjectID{5}='collette_marc_20131024_093735';
subjectID{6}='alonso_eva_20131025_141318';


for counterSubject = 1:length(subjectID)
    [t1_hdr,t1{1}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_tse.mnc']);
    [~,t1{2}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_bs.mnc']);
    [~,t1{3}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_clt_afi.mnc']);
    [~,t1{4}] = niak_read_minc([subjectID{counterSubject} '/t1/t1_clt_vfa_spoil_b1_epseg_da.mnc']);



    [~,b1{1}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_tse.mnc']);
    [~,b1{2}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_gre_bs_cr_fermi.mnc']);
    [~,b1{3}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_clt_afi.mnc']);
    [~,b1{4}] = niak_read_minc([subjectID{counterSubject} '/b1_whole_brain/b1_epseg_da.mnc']);

    [~,mask] = niak_read_minc([subjectID{counterSubject} '/mask/mask.mnc']);

    %%
    for ii=1:length(t1)
        t1{ii}(~mask(:,:,1,1))=0;
    end

    namesB1 = {'Double Angle','Bloch-Siegert','AFI','EPI Double Angle',};
    timesB1 = {'4m38s/slice', '18s/slice', '11s/slice', '5s/slice'}
    namesT1 = {'Inversion Recovery','VFA - Stock Sequence - T1 Maps','VFA - Optimal Spoiling - T1 maps'};

    xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2);
    yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1);

    
    bottomB1 = 0.7;
    topB1 = 1.2;
    for ii = 1 : length(b1)
            b1{ii}(mask(:,:,1,1)==0)=0;
            if ii==1
                b1Row=imrotate(b1{ii},-90);    
            else
                b1Row=cat(2,b1Row,imrotate(b1{ii},-90));    
            end
    end

    bottom = 0.7;
    top = 1.2;

    for ii = 1:length(t1)
        if ii==1    
            t1Row=imrotate(t1{ii},-90);
        else
                t1Row=cat(2,t1Row,imrotate(t1{ii},-90));   
        end
 
    end
    
    
    xFOV = (1:t1_hdr.info.dimensions(2))*t1_hdr.info.voxel_size(2)*2;
    yFOV = (1:t1_hdr.info.dimensions(1))*t1_hdr.info.voxel_size(1)*4;
    figure()
    imagesc(yFOV,xFOV,cat(1,b1Row,t1Row))
    axis image
    caxis('manual') 
    caxis([bottomB1 topB1]);
    axis image
    set(gca,'XTick',[])
    set(gca,'YTick',[])
    set(gca,'position',[0 0 1 1],'units','normalized')
end


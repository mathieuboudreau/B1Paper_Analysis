function [] = histT1()
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

subjectID{1}='arseneault_ryan_20131015_140558';
subjectID{2}='caissie_jessica_20131015_152703';
subjectID{3}='mazerolle_erin_20131016_152802';
subjectID{4}='stikov_nikola_20131017_113942';
subjectID{5}='collette_marc_20131024_093735';
subjectID{6}='alonso_eva_20131025_141318';


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

end


function [] = linregressT1()
%UNTITLED6 Summary of this function goes here
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



end


clear all
close all
clc

%% 
%

tic;
cd('qmtopt_workingfolder')
process_lot
cd('..')
cd('qmtuk_workingfolder')
process_lot
cd('..')
tocOff=toc;

save('tocOff.mat','tocOff')
send_mail_message('emb6150','Processing finished','No message to display','tocOff.mat')

function [] = linregressT1(dataDir, b1t1FileOptions)
%LINREGRESST1 Summary of this function goes here
%
% Example usage: linregressT1([pwd '/data'], {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'})
%
% --args--
% dataDir: String for entire path to directory containing the folders of
%          each subjects data.
%          Example usage: dataDir = [pwd '/data'];
%
% b1t1FileOptions: Cell containing the required information to use as
%          arguments for the generateStructB1T1Data function. See function
%          for format of each cells.
%          Example usage: b1t1FileOptions = {'b1/', 't1/', {'clt_da', 'bs', 'afi', 'epi'}, 'vfa_spoil'}
%
    %% Setup file information
    %

    subjectID = dirs2cells(dataDir);

    s = generateStructB1T1Data(b1t1FileOptions{1}, b1t1FileOptions{2}, b1t1FileOptions{3}, b1t1FileOptions{4});
    b1Keys = b1t1FileOptions{3}; % shorthand names of the b1 methods
    b1ID = s.b1Files;
    t1ID = s.t1Files;

    numB1 = size(b1ID,2); % Number of B1 methods compared, e.g. number of curves to be displayed in the hist plots.
    numSubjects = size(subjectID,1);

    namesB1 = {'Double Angle','Bloch-Siegert','AFI','EPI Double Angle',};

    %% Load all data into cell array
    %

    for counterSubject = 1:numSubjects
        % Initialize temps for images
        t1      = cell(0);
        b1      = cell(0);

        for counterB1 = 1:numB1
            t1ID{counterB1}
            b1ID{counterB1}
            [~,t1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' t1ID{counterB1}]);
            [~,b1{counterSubject, counterB1}] = niak_read_minc([dataDir '/' subjectID{counterSubject} '/' b1ID{counterB1}]);
        end

    end

    %%
    %

    for ii=1:4
        t1_scatter{ii}=[t1{1,ii}(:);t1{2,ii}(:);t1{3,ii}(:);t1{4,ii}(:);t1{5,ii}(:);t1{6,ii}(:)];
    end

    allzeros=(t1_scatter{1}==0)&(t1_scatter{2}==0)&(t1_scatter{3}==0)&(t1_scatter{4}==0);
    for ii=1:length(t1_scatter)
        reshapedT1_scatter{ii}=t1_scatter{ii};
        reshapedT1_scatter{ii}(allzeros)=[];
        %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}>1.5)=[];
        %reshapedT1_scatter{ii}(reshapedT1_scatter{ii}<0.5)=[];
    end


    figure(),scatter(reshapedT1_scatter{1},reshapedT1_scatter{2})
    axis([0.5 2 0.5 2])
    xlabel(namesB1{1},'fontweight','bold','fontsize',12)
    ylabel(namesB1{2},'fontweight','bold','fontsize',12)
    x=reshapedT1_scatter{1};
    y=reshapedT1_scatter{2};
    p= polyfit(x,y,1);
    f= polyval(p,x);
    [a,b,c,d,e]=regress(x,y);
    pearsCoeff=corr(reshapedT1_scatter{1},reshapedT1_scatter{2})
    annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
    title('VFA T1 (s)','fontweight','bold','fontsize',16)


    figure(),scatter(reshapedT1_scatter{1},reshapedT1_scatter{3})
    axis([0.5 2 0.5 2])
    xlabel(namesB1{1},'fontweight','bold','fontsize',12)
    ylabel(namesB1{3},'fontweight','bold','fontsize',12)
    x=reshapedT1_scatter{1};
    y=reshapedT1_scatter{3};
    p= polyfit(x,y,1);
    f= polyval(p,x);
    [a,b,c,d,e]=regress(x,y);
    pearsCoeff=corr(reshapedT1_scatter{1},reshapedT1_scatter{3})
    annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
    title('VFA T1 (s)','fontweight','bold','fontsize',16)

    figure(),scatter(reshapedT1_scatter{1},reshapedT1_scatter{4})
    axis([0.5 2 0.5 2])
    xlabel(namesB1{1},'fontweight','bold','fontsize',12)
    ylabel(namesB1{4},'fontweight','bold','fontsize',12)
    x=reshapedT1_scatter{1};
    y=reshapedT1_scatter{4};
    p= polyfit(x,y,1);
    f= polyval(p,x);
    [a,b,c,d,e]=regress(x,y);
    pearsCoeff=corr(reshapedT1_scatter{1},reshapedT1_scatter{4})
    annotation('textbox', [.2 .8, .1, .1],'String', [ {['y = ' num2str(p(1)) 'x + ' num2str(p(2))]} ; {['r2 = ' num2str(e(1))]}; {['Pearson Corr. Coeff = ' num2str(pearsCoeff)]}]);
    title('VFA T1 (s)','fontweight','bold','fontsize',16)

end

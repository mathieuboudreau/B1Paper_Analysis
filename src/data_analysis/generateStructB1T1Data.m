function s = generateStructB1T1Data(b1Folder, t1Folder, b1Keys, t1Key)
%GENERATESTRUCTB1T1DATA Generate struct containing subdirectory locations
%of b1 and t1 files-of-interest.
%
%   --args--
%   b1Folder = char
%       e.g. 'b1/' or 'b1_whole_brain/'
%   t1Folder = char
%       e.g. 't1/' or 't1_whole_brain/'
%   b1Keys   = cell
%       e.g. {'clt_da','epi','afi','bs','nominal'}
%   t1Key    = char
%       e.g. 'gre'

    %% Verify input types
    %

    assert(isa(b1Folder,'char'), 'generateStructB1T1Data:args', 'b1Folder is type %s, must be char.',class(b1Folder));
    assert(isa(t1Folder,'char'), 'generateStructB1T1Data:args', 't1Folder is type %s, must be char.',class(t1Folder));
    assert(isa(b1Keys,'cell'),   'generateStructB1T1Data:args', 'b1Keys is type %s, must be cell.'  ,class(b1Keys));
    assert(isa(t1Key,'char'),    'generateStructB1T1Data:args', 't1Key is type %s, must be char.'   ,class(t1Key));

    %% Setup flags and hardcoded file prefixes
    %

    b1Flag = 'b1';
    t1Flag = 't1';

    b1FilePrefix  = 'b1_';
    t1FilePrefix  = 't1_';
    fileExtention = '.mnc';

    %% Create struct
    %

    s = struct;

    s.b1Folder = b1Folder;
    s.t1Folder = t1Folder;

    s.b1Files = cell(0);
    s.t1Files = cell(0);

    for ii = 1:length(b1Keys)
        % Temp container to be used in t1Files definition, directory not in
        % prefix
        s.b1Files{ii} = [b1FilePrefix, getSuffix(b1Flag,b1Keys{ii}), fileExtention];

        s.t1Files{ii} = [s.t1Folder, t1FilePrefix, getSuffix(t1Flag,t1Key), '_', s.b1Files{ii}];

        % Append folder prefix
        s.b1Files{ii} = [s.b1Folder, s.b1Files{ii}];
    end

end

function suffix = getSuffix(sFlag,key)
    b1Flag = 'b1';
    t1Flag = 't1';

    if strcmp(sFlag, b1Flag)
        b1KeySet   =  {'epi'     , 'clt_da' , 'bic_da' , 'bs'                 , 'afi'    , 'nominal'};
        b1ValueSet =  {'epseg_da', 'clt_tse', 'bic_tse', 'clt_gre_bs_cr_fermi', 'clt_afi', 'nominal'};
        b1MapObj = containers.Map(b1KeySet,b1ValueSet);

        suffix = b1MapObj(key);

    elseif strcmp(sFlag, t1Flag)
        t1KeySet   =  {'gre'    , 'vfa'    , 'vfa_spoil'    };
        t1ValueSet =  {'gre_vfa', 'clt_vfa', 'clt_vfa_spoil'};
        t1MapObj = containers.Map(t1KeySet,t1ValueSet);

        suffix = t1MapObj(key);
    else
        error('generateStructB1T1Data::getSuffix : Unknown flag.');
    end

end
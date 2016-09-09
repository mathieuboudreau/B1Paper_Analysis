function outputString = escapeUnderscores(inputString)
%ESCAPEUNDERSCORE Replaces underscore (_) by its escaped counterpart (\_)
%everywhere in string or cells of strings.
%
%   --arg--
%   inputString: Can be char or cell of chars
%
%   --return--
%   outputString: Same format as input

    outputString = strrep(inputString, '_', '\_');

end


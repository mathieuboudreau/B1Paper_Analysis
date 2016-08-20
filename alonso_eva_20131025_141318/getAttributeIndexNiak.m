function Index = getAttributeIndexNiak(niak_header,att_string)
%GETATTRIBUTEINDEXNIAK Looks through the variable attributes of a Minc file
%loaded with Niak, and outputs the index of the attributes to help call the
% value in niak_header.details.acquisition.attvalue
%
%   niak_header = Variable containing the Minc header information using
%   Niak.
%
%   att_string = String to be searched through in
%   niak_header.details.acquisition
%
%   Author: Mathieu Boudreau
%   Date: February 5 2014
%   Institute: McConnell Brain Imaging Center, Montreal Neurological Institute
%

    IndexC=strfind(niak_header.details.acquisition.varatts,att_string);
    Index = find(not(cellfun('isempty', IndexC)));

end


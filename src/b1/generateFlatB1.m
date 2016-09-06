function [flatB1] = generateFlatB1(mincTemplate, value, b1Out)
%GENERATEFLATB1 Generate and save a flat B1 map in the MINC file format.
%   Requirements: NIAK tools with additional niak_write_minc_ss custom file
%                 for single-slice images.
%
%   --args--
%   mincTemplate: String containing name of *.mnc file that has the 
%                 desired dimensions and properties of output B1 file
%
%   value: Value of output homogenous/flat B1 map
%
%   b1Out: String containing name of output *.mnc file.
%
%   --return--
%   flatB1: Matrix of B1 map that was written to file
%

[template_hdr, template] = niak_read_minc(mincTemplate);

flatB1 = template;

flatB1(:) = double(value);


b1hdr = template_hdr;
b1hdr.file_name = b1Out;
niak_write_minc_ss(b1hdr,flatB1);

end

function rootPath = fmrihmt_RootPath()
% Return the path to the root fmrihmt directory
%
% This function must reside in the directory at the base of the fmrihmt
% directory structure.  It is used to determine the location of various
% sub-directories.

rootPath=which('fmrihmt_RootPath');

rootPath=fileparts(rootPath);

return

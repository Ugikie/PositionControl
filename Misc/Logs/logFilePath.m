function [logFileFullPath] = logFilePath(optionalFileName)
%LOGFILEPATH Summary of this function goes here
%   Detailed explanation goes here
matlab.desktop.editor.openDocument(which('logFilePath.m')); 
currentDate = datestr(now,'mmm-dd-yy');
currentTime = datestr(now,'hh.mm.ss');
if (nargin < 1)
    logFileName = strcat(currentDate,'_',currentTime);
else
    logFileName = strcat(optionalFileName,'_',currentDate,'_',currentTime,'_log');
end    
logFilePath = fileparts(matlab.desktop.editor.getActiveFilename);
logFileFullPath = fullfile(logFilePath, strcat(logFileName,'.txt'));
fprintf('Beginning Measurements %s\n',datestr(now));
matlab.desktop.editor.openDocument(which('PositionController.m'));
end


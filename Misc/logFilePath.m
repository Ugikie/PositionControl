function [logFileFullPath] = logFilePath()
%LOGFILEPATH Summary of this function goes here
%   Detailed explanation goes here

%logPath = matlab.desktop.editor.getActiveFilename;
currentDate = datestr(now,'mm-dd-yy');
currentTime = datestr(now,'hh:mm:ss');
logFileName = strcat(currentDate,'_',currentTime,'_log.txt');
logFilePath = '~/Desktop/PositionControl/Misc/Logs/';
logFileFullPath = strcat(logFilePath,logFileName);
fprintf('Beginning Measurements %s\n',logFileName);
end


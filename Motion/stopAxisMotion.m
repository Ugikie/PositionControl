function [] = stopAxisMotion(MI4190,loadBarProgress,loadBar)
%STOPAXISMOTION Summary of this function goes here
%   Detailed explanation goes here
fprintf('[%s] Stopping Axis Motion\n', datestr(now,'HH:MM:SS.FFF'));
waitbar(loadBarProgress,loadBar,sprintf('Stopping Axis Motion'));
fprintf(MI4190, 'CONT1:AXIS(1):MOT:STOP');
end


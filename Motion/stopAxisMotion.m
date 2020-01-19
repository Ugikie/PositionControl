function [] = stopAxisMotion(MI4190,loadBarProgress,measApp)
%STOPAXISMOTION Summary of this function goes here
%   Detailed explanation goes here
fprintf('[%s] Stopping Axis Motion\n', datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine(sprintf('[%s] Stopping Axis Motion\n', datestr(now,'HH:MM:SS.FFF')));
measApp.updateProgressBar(loadBarProgress,sprintf('Stopping Axis Motion'));
fprintf(MI4190, 'CONT1:AXIS(1):MOT:STOP');
end


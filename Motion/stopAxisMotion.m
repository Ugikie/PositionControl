function [] = stopAxisMotion(MI4190)
%STOPAXISMOTION Summary of this function goes here
%   Detailed explanation goes here
fprintf('[%s] Stopping Axis Motion\n', datestr(now,'HH:MM:SS.FFF'));
fprintf(MI4190, 'CONT1:AXIS(1):MOT:STOP');
end


function [] = moveAxisToPosition(MI4190,desiredPos,AZCurrPos)
%MOVEAXISTOPOSITION Summary of this function goes here
%   Detailed explanation goes here

if (getAZCurrVelocity(MI4190) == 0.0000)
    fprintf('[%s] Moving Axis (AZ) from position: %.2f, to desired position: %.2f',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, desiredPos);
    fprintf(MI4190, 'CONT1:AXIS(1):POS:COMM %f\n', desiredPos);
    fprintf(MI4190, 'CONT1:AXIS(1):MOT:STAR');
    dots(4);
else
    fprintf('[%s] Warning: Axis is in motion and cannot be moved!\n',datestr(now,'HH:MM:SS.FFF'));
end
end


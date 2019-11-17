function [] = incrementAxisByDegree(MI4190,incrementAmount)
%INCREMENTAXISBYDEGREE Summary of this function goes here
%   Detailed explanation goes here
fprintf(MI4190, 'CONT1:AXIS(1):POS:INCR %.2f\n', incrementAmount);
fprintf(MI4190, 'CONT1:AXIS(1):MOT:STAR');
end


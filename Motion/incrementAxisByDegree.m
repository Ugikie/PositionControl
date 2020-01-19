function [] = incrementAxisByDegree(MI4190,incrementAmount,measApp)
%INCREMENTAXISBYDEGREE Increments Axis (AZ) by specified degree amount
%   Simply issues a command to the MI4190 position controller that
%   increments the current position by the desired degree amount. Useful
%   when taking measurements with a specific degree interval.
if (measApp.wantToStop) return; end
updateLamps(1,measApp,false,true);
fprintf(MI4190, 'CONT1:AXIS(1):POS:INCR %.2f\n', incrementAmount);
fprintf(MI4190, 'CONT1:AXIS(1):MOT:STAR');

end


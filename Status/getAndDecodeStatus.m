function [AZCurrStat] = getAndDecodeStatus(MI4190,measApp)
%GETANDDECODESTATUS Gets and returns the current status values of Axis (AZ)
%   Axis status is returned as an integer representing a 16-bit number,
%   where each bit has a respective meaning for the axis status options.
%   This function gets that value, and decodes each bit, returning a list
%   of the different status values of the axis at a moment in time.
%   Details on page 3-42 of MI-4192 Manual.
if (measApp.wantToStop) delete(measApp); return; end

fprintf(MI4190, 'CONT1:AXIS(1):STAT?');
AZCurrStat = char(fread(MI4190, 100))';

if (measApp.wantToStop) delete(measApp); return; end

decStat = str2double(regexp(AZCurrStat,'\d*','match'));

binStat = dec2bin(decStat) - '0';
binStat = [zeros(1,12 - length(binStat) + 1) binStat];
idx = 12; %bits 13, 14, and 15 of status are unused.
for i = binStat
    if (i == 1)
        switch idx
        case 12
            AZCurrStat = [AZCurrStat 'Status Changed., '];
        case 11
            AZCurrStat = [AZCurrStat 'Property Changed, '];
        case 10
            AZCurrStat = [AZCurrStat 'Position Trigger Active'];
        case 9
            AZCurrStat = [AZCurrStat 'Axis is Indexed, '];
        case 8
            AZCurrStat = [AZCurrStat 'Axis is Active, '];
        case 7
            AZCurrStat = [AZCurrStat 'Axis in Motion, '];
            measApp.InMotionLamp.Color = 'green';
        case 6
            AZCurrStat = [AZCurrStat 'Error Limit Active, '];
        case 5
            AZCurrStat = [AZCurrStat 'Axis Enabled, '];
        case 4
            AZCurrStat = [AZCurrStat 'PAU Fault, '];
            measApp.FaultLamp.Color = 'red';
        case 3
            AZCurrStat = [AZCurrStat 'Forward Limit Active, '];
        case 2
            AZCurrStat = [AZCurrStat 'Reverse Limit Active, '];
        case 1
            AZCurrStat = [AZCurrStat 'Home Switch Active, '];
        case 0
            AZCurrStat = [AZCurrStat 'Latch is Set, '];
        otherwise
            AZCurrStat = [AZCurrStat 'Error in status decoding!'];    
        end   
    end
    idx = idx - 1;
end
measApp.writeConsoleLine(sprintf('\nAZ Current Status: %s\n',AZCurrStat));

end


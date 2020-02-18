function [] = setVNACentFreq(centerFreq,units,MI4190,measApp)
%SETVNACENTFREQ Sets the center frequency on the VNA
%   Switches the current instrument from the MI4190 to the VNA, sends the
%   command to change the center frequency, and then switches the current
%   instrument back to the MI4190.
if (measApp.wantToStop) return; end

fprintf(MI4190, '++addr 16');
fprintf(MI4190, sprintf('STAR %f %s',centerFreq,units));
fprintf(MI4190, sprintf('STOP %f %s',centerFreq,units));
fprintf(MI4190, '++addr 4');

if (measApp.wantToStop) return; end

end


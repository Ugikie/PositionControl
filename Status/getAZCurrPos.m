function [AZCurrPosDoub] = getAZCurrPos(MI4190,measApp)
%GETAZCURRPOS Gets the current Position of the AZ Axis
%       Get the current position of the AZ axis and store it in AZCurrPosChar
%       Convert AZCurrPosChar from a char array to a string, then to double
if (measApp.wantToStop) AZCurrPosDoub = 0; return; end

fprintf(MI4190, 'CONT1:AXIS(1):POS:CURR?');
AZCurrPosChar = char(fread(MI4190, 100))';
AZCurrPosDoub = str2double(convertCharsToStrings(AZCurrPosChar));
measApp.StatusTable.Data{1,1} = AZCurrPosDoub;
measApp.rotateHornImage(AZCurrPosDoub);
measApp.CurrentAngleGuage.Value = AZCurrPosDoub;
drawnow();

if (measApp.wantToStop) AZCurrPosDoub = 0; return; end
end


function [AZCurrVelDoub] = getAZCurrVelocity(MI4190,measApp)
%GETAZCURRPOS Gets the current Position of the AZ Axis
%       Get the current position of the AZ axis and store it in AZCurrPosChar
%       Convert AZCurrPosChar from a char array to a string, then to double
if (measApp.wantToStop) AZCurrVelDoub = 0; return; end

fprintf(MI4190, 'CONT1:AXIS(1):VEL:CURR?');
AZCurrVelChar = char(fread(MI4190, 100))';
AZCurrVelDoub = str2double(convertCharsToStrings(AZCurrVelChar));
measApp.StatusTable.Data{3,1} = AZCurrVelDoub;
updateLamps(AZCurrVelDoub,measApp,false,(AZCurrVelDoub >= 0.5) || (AZCurrVelDoub <= -0.5));
drawnow();
if (measApp.wantToStop) AZCurrVelDoub = 0; return; end
end


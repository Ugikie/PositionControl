function [] = updateLamps(AZCurrVel,measApp,USRPsMeasuring,inMotion)
%LAMPS Updates the status lamps in the Measurement App
%   Checks if the MI4190 is Idle, Moving, or if the USRPs are measuring,
%   and will update the lamps on the applet accordingly.
if (measApp.wantToStop) return; end
measApp.StatusTable.Data{3,1} = AZCurrVel;

if ((AZCurrVel <= 0.5) && (AZCurrVel >= -0.5) && ~USRPsMeasuring && ~inMotion)
   measApp.IdleLamp.Color = 'green';
   measApp.InMotionLamp.Color = [0.65 0.65 0.65];
   measApp.MeasuringLamp.Color = [0.65 0.65 0.65];
elseif (~USRPsMeasuring && inMotion)
   measApp.IdleLamp.Color = [0.65 0.65 0.65];
   measApp.InMotionLamp.Color = 'green';
   measApp.MeasuringLamp.Color = [0.65 0.65 0.65];
elseif (USRPsMeasuring)
   measApp.IdleLamp.Color = [0.65 0.65 0.65];
   measApp.InMotionLamp.Color = [0.65 0.65 0.65];
   measApp.MeasuringLamp.Color = 'green';
else
   measApp.IdleLamp.Color = 'red';
   measApp.InMotionLamp.Color = 'red';
   measApp.MeasuringLamp.Color = 'red';

end
drawnow();
end


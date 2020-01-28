function [] = moveAxisToPosition(MI4190,desiredPos,AZCurrPos,loadBarProgress,measApp,incrementSize,anglesRemaining)
%MOVEAXISTOPOSITION Commands Axis (AZ) to move to specified degree position
%   Ensures that the Axis is not moving before sending a command to move to
%   the specified position. Different than incrementAxsByDegree in that
%   this will move to the exact degree specified.
if (measApp.wantToStop) return; end

AZCurrVel = getAZCurrVelocity(MI4190,measApp);
updateLamps(AZCurrVel,measApp,false,(AZCurrVel >= 0.5) || (AZCurrVel <= -0.5));

if ((AZCurrVel >= -0.01) && (AZCurrVel <= 0.01))
    
    if (measApp.wantToStop) return; end
    updateLamps(AZCurrVel,measApp,false,true);
    
    fprintf('[%s] Moving Axis (AZ) from position: %.2f, to desired position: %.2f',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, desiredPos);
    measApp.writeConsoleLine(sprintf('[%s] Moving Axis (AZ) from position: %.2f, to desired position: %.2f',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, desiredPos));
    measApp.updateProgressBar(loadBarProgress,sprintf('Moving Axis (AZ) from position: %.2f, to desired position: %.2f',AZCurrPos, desiredPos));
    drawnow();
    pause(0.0001);
    fprintf(MI4190, 'CONT1:AXIS(1):POS:COMM %f\n', desiredPos);
    fprintf(MI4190, 'CONT1:AXIS(1):MOT:STAR');
    dots(4);
    verifyIfInPosition(MI4190,desiredPos,0.6,loadBarProgress,measApp,anglesRemaining,incrementSize);
    
    if (measApp.wantToStop) return; end
    
else
    cprintf('err','[%s][WARNING] Axis is in motion and cannot be moved!\n',datestr(now,'HH:MM:SS.FFF'));
    measApp.writeConsoleLine(sprintf('[%s][WARNING] Axis is in motion and cannot be moved!\n',datestr(now,'HH:MM:SS.FFF')));
    updateLamps(AZCurrVel,measApp,false,(AZCurrVel >= 0.5) || (AZCurrVel <= -0.5));
    measApp.updateProgressBar(loadBarProgress,sprintf('Warning: Axis is in motion and cannot be moved!'));
end
end


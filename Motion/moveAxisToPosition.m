function [] = moveAxisToPosition(MI4190,desiredPos,AZCurrPos,loadBarProgress,loadBar)
%MOVEAXISTOPOSITION Commands Axis (AZ) to move to specified degree position
%   Ensures that the Axis is not moving before sending a command to move to
%   the specified position. Different than incrementAxsByDegree in that
%   this will move to the exact degree specified.

if (getAZCurrVelocity(MI4190) == 0.0000)
    
    if getappdata(loadBar,'canceling')
            cancelSystem(loadBarProgress,loadBar)
            return
    end
    
    fprintf('[%s] Moving Axis (AZ) from position: %.2f, to desired position: %.2f',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, desiredPos);
    waitbar(loadBarProgress,loadBar,sprintf(' Moving Axis (AZ) from position: %.2f, to desired position: %.2f',AZCurrPos, desiredPos));
    fprintf(MI4190, 'CONT1:AXIS(1):POS:COMM %f\n', desiredPos);
    fprintf(MI4190, 'CONT1:AXIS(1):MOT:STAR');
    dots(4);
else
    cprintf('err','[%s][WARNING] Axis is in motion and cannot be moved!\n',datestr(now,'HH:MM:SS.FFF'));
    waitbar(loadBarProgress,loadBar,sprintf('Warning: Axis is in motion and cannot be moved!'));
end
end


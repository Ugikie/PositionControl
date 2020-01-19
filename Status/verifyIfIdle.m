function [axisIdle] = verifyIfIdle(MI4190,AZCurrVel,measApp)
%VERIFYIFIdle A simple check to see if the Axis (AZ) is not moving.
%   Since the axis decreases its velocity very slowly towards 0, it is
%   important to continuously check until it is completely stopped. Also,
%   since it takes time for the controller to respond, we have to query it
%   every 1.5 seconds.
while (AZCurrVel ~= 0.0000)
        axisIdle = false;
        pause(1.5);
        AZCurrVel = getAZCurrVelocity(MI4190,measApp);
end
axisIdle = true;
end


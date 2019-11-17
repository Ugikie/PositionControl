function [axisIdle] = verifyIfIdle(MI4190,AZCurrVel)
%VERIFYIFIdle Summary of this function goes here
%   Detailed explanation goes here
while (AZCurrVel ~= 0.0000)
        axisIdle = false;
        pause(1.5);
        AZCurrVel = getAZCurrVelocity(MI4190);
end
axisIdle = true;
end


function [axisInPosition] = verifyIfInPosition(MI4190,desiredPosition, positionError,verbose)
%VERIFYIFINPOSITION Will notify the user when Axis (AZ) is in its desired pos.
%       Queries the MI4190 every 2 seconds for its current
%       position, if it is at the desired position, then it breaks from the loop
%       and notifies the user.
if (nargin < 4)
    verbose = 'a';
end
desiredPosMin = desiredPosition - positionError;
desiredPosMax = desiredPosition + positionError;
axisInPosition = false;
tic
    while toc<=60
          fprintf('[%s] Verifying if Axis is in Position',datestr(now,'HH:MM:SS.FFF'));
          AZCurrPosDoub = getAZCurrPos(MI4190);
          AZCurrVel = getAZCurrVelocity(MI4190);
          dots(4)
          if ((AZCurrPosDoub >= desiredPosMin) && (AZCurrPosDoub <= desiredPosMax))
              if (verbose == 'v')
                fprintf('[%s] Axis (AZ) is in desired position: %.2f. Time elapsed: %.2f seconds.\n',datestr(now,'HH:MM:SS.FFF'), AZCurrPosDoub, toc');
              end
              axisInPosition = true;
              break;
          
          elseif (AZCurrVel == 0.00)
              moveAxisToPosition(MI4190,desiredPosition,AZCurrPosDoub);
          end
    end
    if(~axisInPosition && (AZCurrVel == 0.00))
        moveAxisToPosition(MI4190,desiredPosition,AZCurrPosDoub);
    end
end
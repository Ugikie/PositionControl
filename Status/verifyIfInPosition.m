function [axisInPosition] = verifyIfInPosition(MI4190,desiredPosition, positionError,loadBarProgress,loadBar,measurementApp,anglesRemaining,incrementSize,verbose)
%VERIFYIFINPOSITION Will notify the user when Axis (AZ) is in its desired pos.
%       Queries the MI4190 every 4 seconds for its current
%       position, if it is at the desired position, then it breaks from the loop
%       and notifies the user.
if (nargin < 9)
    
    verbose = 'a';

end
desiredPosMin = desiredPosition - positionError;
desiredPosMax = desiredPosition + positionError;
axisInPosition = false;
tic
    while toc<=80
          pause(1);
          fprintf('[%s] Verifying if Axis is in Position',datestr(now,'HH:MM:SS.FFF'));
          waitbar(loadBarProgress,loadBar,sprintf('Verifying if Axis is in Position'));
          
          AZCurrPos = getAZCurrPos(MI4190);
          AZCurrVel = getAZCurrVelocity(MI4190);
          if (incrementSize == 'N')
            measurementApp.StatusTable.Data = {AZCurrPos;desiredPosition;AZCurrVel;'N/A'};
          else
            measurementApp.StatusTable.Data = {AZCurrPos;AZCurrPos + incrementSize;AZCurrVel;anglesRemaining};
          end
          
          
          if getappdata(loadBar,'canceling')
            cancelSystem(loadBarProgress,loadBar)
            break
          end
          
          dots(4)
          
          if ((AZCurrPos >= desiredPosMin) && (AZCurrPos <= desiredPosMax))
              waitbar(loadBarProgress,loadBar,sprintf('Axis (AZ) is in desired position. Continuing...'));
              if (verbose == 'v')
                fprintf('[%s] Axis (AZ) is in desired position: %.2f. Time elapsed: %.2f seconds.\n',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, toc');
              end
              axisInPosition = true;
              break;
          
          elseif (AZCurrVel == 0.00)
              moveAxisToPosition(MI4190,desiredPosition,AZCurrPos,loadBarProgress,loadBar,measurementApp,incrementSize,anglesRemaining);
          end
    end
    if(~axisInPosition && (AZCurrVel == 0.00))
        moveAxisToPosition(MI4190,desiredPosition,AZCurrPos,loadBarProgress,loadBar,measurementApp,incrementSize,anglesRemaining);
    end
end
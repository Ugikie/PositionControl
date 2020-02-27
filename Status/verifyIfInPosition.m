function [axisInPosition] = verifyIfInPosition(MI4190,desiredPosition, positionError,loadBarProgress,measApp,anglesRemaining,incrementSize,verbose)
%VERIFYIFINPOSITION Will notify the user when Axis (AZ) is in its desired pos.
%       Queries the MI4190 every 4 seconds for its current
%       position, if it is at the desired position, then it breaks from the loop
%       and notifies the user.
if (measApp.wantToStop) return; end

if (nargin < 8)
    
    verbose = 'a';

end
desiredPosMin = desiredPosition - positionError;
desiredPosMax = desiredPosition + positionError;
axisInPosition = false;
tic
    while toc<=80
          
          if (verbose == 'v')
            fprintf('[%s] Verifying if Axis is in Position',datestr(now,'HH:MM:SS.FFF'));
            dots(4);
            measApp.writeConsoleLine(sprintf('[%s] Verifying if Axis is in Position. . .',datestr(now,'HH:MM:SS.FFF')));
            measApp.updateProgressBar(loadBarProgress,sprintf('Verifying if Axis is in Position'));
          end
          drawnow();
          if (measApp.wantToStop) return; end
          
          AZCurrPos = getAZCurrPos(MI4190,measApp);
          AZCurrVel = getAZCurrVelocity(MI4190,measApp);          
          
          if (measApp.wantToStop) return; end
          
          if ((AZCurrPos >= desiredPosMin) && (AZCurrPos <= desiredPosMax))
              if (verbose == 'v')
                measApp.updateProgressBar(loadBarProgress,sprintf('Axis (AZ) is in desired position. Continuing...'));
                fprintf('[%s] Axis (AZ) is in desired position: %.2f. Time elapsed: %.2f seconds.\n',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, toc');
                measApp.writeConsoleLine(sprintf('[%s] Axis (AZ) is in desired position: %.2f. Time elapsed: %.2f seconds.\n',datestr(now,'HH:MM:SS.FFF'), AZCurrPos, toc'));
                measApp.StatusTable.Data{2,1} = measApp.StatusTable.Data{1,1} + incrementSize;
              end
              axisInPosition = true;
              break;
          
          elseif (AZCurrVel == 0.00)
              moveAxisToPosition(MI4190,desiredPosition,AZCurrPos,loadBarProgress,measApp,incrementSize,anglesRemaining);
          end
    end
    
    if (measApp.wantToStop) return; end
    updateLamps(AZCurrVel,measApp,false,(AZCurrVel >= 0.5) || (AZCurrVel <= -0.5));
    
    if(~axisInPosition && (AZCurrVel == 0.00))
        moveAxisToPosition(MI4190,desiredPosition,AZCurrPos,loadBarProgress,measApp,incrementSize,anglesRemaining);
    end
    drawnow();
end
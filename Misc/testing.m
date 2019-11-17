% a = -90:5:90;
% f = waitbar(0,'Please wait...');
% pause(0.5)
% itr = 1;
% for i = a
%     waitbar((itr/length(a)),f,sprintf('Measurement in progress. Current Angle: %.2f',i));
%     itr = itr + 1;
%     pause(1)
%     waitbar((itr/length(a)),f,sprintf('Moving Axis (AZ)'));
%     pause(0.5)
% end
% close(f)


close all; clear all; clc;
startTime = datestr(now,'HH:MM:SS.FFF');

loadBar = waitbar(0,'Initializing MI4190...');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
%verifyIfInPosition(MI4190,AZStartPos,POSITION_ERROR,0,loadBar,'v');

%Allow user to input desired increment size for degree changes on Axis (AZ)
incrementSize = -1;
while ((incrementSize <= 0) || (incrementSize > 180)) 
    
    fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
    
    waitbar(0,loadBar,sprintf('Waiting for user input...')); 
    incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
end
degInterval = -90:incrementSize:90;

%Loops through each degree in the interval and communicates with the USRP
%to take automatic measurements, with many checks along the way to ensure
%the safety of the system.
itr = 0;

for currentDegree = degInterval
    itr = itr + 1;
    loadBarProgress = (itr/length(degInterval));
    waitbar(loadBarProgress,loadBar,sprintf('Measurement in progress. Current Angle: %.2f',currentDegree));
    fprintf('\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    %verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar,'v');
    
    fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
    unix('echo Turn on GNU');
    
    %Calls the USRP Error Checking function that for now simulates a random
    %USRP error by generating a '1' for an error and '0' for no error.
    %usrpErrorChecker(loadBarProgress,loadBar);
    
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement
    %AZCurrVel = getAZCurrVelocity(MI4190);
    %AZIdle = verifyIfIdle(MI4190,AZCurrVel);
    
    %Make sure Axis (AZ) position did not change during USRP error checking
    %and also check that it is not moving.
   % AZInPosition = verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar);
    if (true)
        
       % fprintf('[%s] Measure angle %.2f',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190));
        waitbar(loadBarProgress,loadBar,sprintf('Taking Measurement at %.2f degrees...',currentDegree));
        dots(3);
        
        if (currentDegree ~= degInterval(end))
            
            fprintf('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            waitbar(loadBarProgress,loadBar,sprintf('Incrementing MI4190 Position by %.2f degrees',incrementSize));
            dots(4);
          %  incrementAxisByDegree(MI4190,incrementSize);
            
        else
            
            fprintf('[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
            waitbar(1,loadBar,sprintf('Done with current set of measurements!'));
            
        
        end
        
    %elseif (~AZIdle)
        
     %   stopAxisMotion(MI4190,loadBarProgress,loadBar);
    
    end
    
end
endTime = datestr(now,'HH:MM:SS.FFF');
fprintf('Elapsed Time: %s\n',datestr(datetime(endTime) - datetime(startTime),'HH:MM:SS'));
close(loadBar);
%fclose(MI4190);



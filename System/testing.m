close all; clear all; clc;

logFile = logFilePath();
diary(logFile);
cprintf('strings','Saving log to: %s\n',logFile);
fprintf('\n');
%===================================SETUP=================================%
% % Specify the virtual serial port created by USB driver. It is currently
% % configured to work for a Mac, so if a PC is being used this will need to
% % be changed (e.g., to a port such as COM3)
% MI4190 = serial('/dev/ttyUSB0');                 % Linux
%     %if it does not work on linux, you may have to run the command:
%     % 'sudo chmod 666 /dev/ttyUSB0' to enable permissions
% %MI4190 = serial('/dev/tty.usbserial-PX2DN8ZM'); % Mac
% %MI4190 = serial('COM3');                        % PC
% 
% % Prologix Controller 4.2 requires CR as command terminator, LF is
% % optional. The controller terminates internal query responses with CR and
% % LF. Responses from the instrument are passed through as is. (See Prologix
% % Controller Manual)
% MI4190.Terminator = 'CR/LF';
% 
% % Reduce timeout to 0.5 second (default is 10 seconds)
% MI4190.Timeout = 0.5;
% 
% % Open virtual serial port
% fclose(MI4190);
% fopen(MI4190);
% 
% pause(1)
% 
% warning('off','MATLAB:serial:fread:unsuccessfulRead');
% 
% % Configure as Controller (++mode 1), instrument address 4, and with
% % read-after-write (++auto 1) enabled
% fprintf(MI4190, '++mode 1');
% fprintf(MI4190, '++addr 4');
% fprintf(MI4190, '++auto 1');
% 
% % Read the id of the Controller to verify connection:
% fprintf(MI4190, '*idn?');
% idn = char(fread(MI4190, 100))'
% %===============================END SETUP=================================%
% 
% %Check status of axis, returns an integer value representing a 16 bit value
% %of status bits. Details on page 3-42 of MI-4192 Manual
% %==Add function later to decode status value==%
% fprintf(MI4190, 'CONT1:AXIS(1):STAT?');
% axis1CurrStatChar = char(fread(MI4190, 100))'
% 
% %Get current position of Axis (AZ) and store it in AZCurrPosChar
% %Convert AZCurrPosChar from a char array to a string, then to double
% AZCurrPos = getAZCurrPos(MI4190);

%Define the ideal starting position of the Axis (AZ) and the threshold in
%which the AZ should be in. Usually sits within +- 0.5 degrees of the
%commanded position. Using 0.6 to get just outside that range.
AZStartPos = -90.0000;
POSITION_ERROR = 0.6;

%Create a waitbar to show progress during measurement cycle. Add elapsed
%time
startTime = datestr(now,'HH:MM:SS.FFF');
loadBar = waitbar(0,'Initializing MI4190...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);
setappdata(loadBar,'canceling',0);

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
%verifyIfInPosition(MI4190,AZStartPos,POSITION_ERROR,0,loadBar,'v');

%Allow user to input desired increment size for degree changes on Axis (AZ)
incrementSize = -1;
while (~getappdata(loadBar,'canceling') && (incrementSize <= 0) || (incrementSize > 180)) 
    
    fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
    
    waitbar(0,loadBar,sprintf('Waiting for user input...')); 
    incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
end
degInterval = -90:incrementSize:90;


%Initiates the boot process for the USRP N210 & N310.
bootUSRPs(0,loadBar);
gnuFileName = '/ArrayTest3.py ';
gnuFilePath = fileparts(matlab.desktop.editor.getActiveFilename);

%Loops through each degree in the interval and communicates with the USRP
%to take automatic measurements, with many checks along the way to ensure
%the safety of the system.
itr = 0;
for currentDegree = degInterval
    if (currentDegree == degInterval(1))
        takeFirstMeasurementCommand = ['sudo timeout 30 python ' gnuFilePath gnuFileName num2str(currentDegree)];
    else
        takeMeasurementCommand = ['sudo timeout 12 python ' gnuFilePath gnuFileName num2str(currentDegree)];
    end
    itr = itr + 1;
    loadBarProgress = (itr/length(degInterval));
    
    if getappdata(loadBar,'canceling')
        cancelSystem(loadBarProgress,loadBar)
        return;
    end
    
    waitbar(loadBarProgress,loadBar,sprintf('Measurement in progress. Current Angle: %.2f',currentDegree));
    cprintf('-comment','\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    
  %  verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar,'v');
    
    %verify connection to USRP via uhd_find_devices
    %Calls the USRP Error Checking function that for now simulates a random
    %USRP error by generating a '1' for an error and '0' for no error.
    usrpErrorChecker(loadBarProgress,loadBar);
        
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement
 %   AZCurrVel = getAZCurrVelocity(MI4190);
 %   AZIdle = verifyIfIdle(MI4190,AZCurrVel);
    
    %Make sure Axis (AZ) position did not change during USRP error checking
    %and also check that it is not moving.
    %AZInPosition = verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar);
    if (true)
        
        if getappdata(loadBar,'canceling')
            cancelSystem(loadBarProgress,loadBar)
            break
        end
        
        fprintf('\n[%s] Measure angle %.2f. . .\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
        if(currentDegree == degInterval(1))
            system(takeFirstMeasurementCommand);
        else
            system(takeMeasurementCommand);
        end
        
        waitbar(loadBarProgress,loadBar,sprintf('Taking Measurement at %.2f degrees...',currentDegree));
        
        if (currentDegree ~= degInterval(end))
            
            if getappdata(loadBar,'canceling')
                cancelSystem(loadBarProgress,loadBar)
                break
            end
            
            fprintf('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            waitbar(loadBarProgress,loadBar,sprintf('Incrementing MI4190 Position by %.2f degrees',incrementSize));
        %    incrementAxisByDegree(MI4190,incrementSize);
            dots(4);
            
        else
            
            cprintf('-comments','[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
            waitbar(1,loadBar,sprintf('Done with current set of measurements!'));
            
        
        end
        
    elseif (~AZIdle)
        
      %  stopAxisMotion(MI4190,loadBarProgress,loadBar);
    
    end
    
end

endTime = datestr(now,'HH:MM:SS.FFF');
fprintf('Elapsed Time: %s\n',datestr(datetime(endTime) - datetime(startTime),'HH:MM:SS'));

delete(loadBar);
%fclose(MI4190);
cprintf('strings','Log saved to: %s\n',logFile);
diary off;


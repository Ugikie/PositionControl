close all; clear all; clc;

measApp = startApp();

[logFileName,logFile] = logFilePath();
diary(logFile);
cprintf('strings','Saving log to: %s\n',logFile);
fprintf('\n');
measApp.writeConsoleLine('Saving log to: %s\n',logFile);

if (measApp.wantToStop) delete(measApp); return; end

%===================================SETUP=================================%
% Specify the virtual serial port created by USB driver. It is currently
% configured to work for a Mac, so if a PC is being used this will need to
% be changed (e.g., to a port such as COM3)
MI4190 = serial('/dev/ttyUSB0');                 % Linux
    %if it does not work on linux, you may have to run the command:
    % 'sudo chmod 666 /dev/ttyUSB0' to enable permissions.
%MI4190 = serial('/dev/tty.usbserial-PX2DN8ZM'); % Mac
%MI4190 = serial('COM3');                        % PC

% Prologix Controller 4.2 requires CR as command terminator, LF is
% optional. The controller terminates internal query responses with CR and
% LF. Responses from the instrument are passed through as is. (See Prologix
% Controller Manual)
MI4190.Terminator = 'CR/LF';

% Reduce timeout to 0.5 second (default is 10 seconds)
MI4190.Timeout = 0.5;

% Open virtual serial port
fclose(MI4190);
fopen(MI4190);
measApp.MI4190Obj = MI4190;

if (measApp.wantToStop) delete(measApp); return; end

pause(1)

if (measApp.wantToStop) delete(measApp); return; end

warning('off','MATLAB:serial:fread:unsuccessfulRead');

if (measApp.wantToStop) delete(measApp); return; end

% Configure as Controller (++mode 1), instrument address 4, and with
% read-after-write (++auto 1) enabled
fprintf(MI4190, '++mode 1');
fprintf(MI4190, '++addr 4');
fprintf(MI4190, '++auto 1');

if (measApp.wantToStop) delete(measApp); return; end

% Read the id of the Controller to verify connection:
fprintf(MI4190, '*idn?');
idn = char(fread(MI4190, 100))';
measApp.writeConsoleLine('Position Controller ID: %s\n',idn);
%===============================END SETUP=================================%

if (measApp.wantToStop) delete(measApp); return; end

%Check status of axis, returns an integer value representing a 16 bit value
%of status bits. Details on page 3-42 of MI-4192 Manual
%==Add function later to decode status value==%
fprintf(MI4190, 'CONT1:AXIS(1):STAT?');
AZCurrStat = char(fread(MI4190, 100))';
measApp.writeConsoleLine('AZ Current Status: %s\n',AZCurrStat);

if (measApp.wantToStop) delete(measApp); return; end

%Get current position of Axis (AZ) and store it in AZCurrPos, along with
%the current Velocity in AZCurrVel.
AZCurrPos = getAZCurrPos(MI4190);
AZCurrVel = getAZCurrVelocity(MI4190);

if (measApp.wantToStop) delete(measApp); return; end

%Define the ideal starting position of the Axis (AZ) and the threshold in
%which the AZ should be in. Usually sits within +- 0.5 degrees of the
%commanded position. Using 0.6 to get just outside that range.
AZStartPos = -90.0000;
POSITION_ERROR = 0.6;
measApp.StatusTable.Data = {AZCurrPos;AZStartPos;AZCurrVel;'N/A'};

if (measApp.wantToStop) delete(measApp); return; end

%Create a waitbar to show progress during measurement cycle. Add elapsed
%time
startTime = datestr(now,'HH:MM:SS.FFF');
loadBar = waitbar(0,'Initializing MI4190...','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
frames = java.awt.Frame.getFrames();
frames(end).setAlwaysOnTop(1);
setappdata(loadBar,'canceling',0);
measApp.loadBarObj = loadBar;

if (measApp.wantToStop) delete(measApp); return; end

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
verifyIfInPosition(MI4190,AZStartPos,POSITION_ERROR,0,loadBar,measApp,'N','N','v');

%Allow user to input desired increment size for degree changes on Axis (AZ)
incrementSize = -1;
while ((incrementSize <= 0) || (incrementSize > 180)) 
       
    waitbar(0,loadBar,sprintf('Waiting for user input...'));
    
    %incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
    if (measApp.wantToStop) break; end
    incrementSize = measApp.IncrementSizeEditField.Value;
    while (incrementSize == 0)
        fprintf('[%s] Please enter a valid increment size!\n',datestr(now,'HH:MM:SS.FFF'))
        measApp.writeConsoleLine('[%s] Please enter a valid increment size!\n',datestr(now,'HH:MM:SS.FFF'))
        while (incrementSize == 0)
            if (measApp.wantToStop) break; end
            incrementSize = measApp.IncrementSizeEditField.Value;
            pause(1)
        end
        if (measApp.wantToStop) break; end
    end
    if (measApp.wantToStop) break; end
end
if (measApp.wantToStop) delete(measApp); return; end
fprintf('[%s] Increment size chosen: %.2f\n',datestr(now,'HH:MM:SS.FFF'),incrementSize)
measApp.writeConsoleLine('[%s] Increment size chosen: %.2f\n',datestr(now,'HH:MM:SS.FFF'),incrementSize)
measApp.IncrementSizeEditField.Editable = false;
degInterval = -90:incrementSize:90;



%Initiates the boot process for the USRP N210 & N310.
%%%bootUSRPs(0,loadBar,measApp);
gnuFileName = '/ArrayTest3.py ';
gnuFilePath = fileparts(matlab.desktop.editor.getActiveFilename);
%Loops through each degree in the interval and communicates with the USRP
%to take automatic measurements, with many checks along the way to ensure
%the safety of the system.
itr = 0;
for currentDegree = degInterval
    if (measApp.wantToStop) break; end
    
    takeMeasurementCommand = ['sudo python ' gnuFilePath gnuFileName ' ' num2str(incrementSize) ' ' logFileName ' ' num2str(currentDegree)];
    
    itr = itr + 1;
    loadBarProgress = (itr/length(degInterval));
    
    [~,idx] = find(degInterval == currentDegree);
    anglesRemaining = length(degInterval) - idx;
    
    if (measApp.wantToStop) break; end
    
    waitbar(loadBarProgress,loadBar,sprintf('Measurement in progress. Current Angle: %.2f',currentDegree));
    cprintf('-comment','\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    measApp.writeConsoleLine('[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    
    verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar,measApp,anglesRemaining,incrementSize,'v');
    if (measApp.wantToStop) break; end
    %verify connection to USRP via uhd_find_devices
    %Calls the USRP Error Checking function that for now simulates a random
    %USRP error by generating a '1' for an error and '0' for no error.
   %%% usrpErrorChecker(loadBarProgress,loadBar);
    
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement
    AZCurrVel = getAZCurrVelocity(MI4190);
    AZIdle = verifyIfIdle(MI4190,AZCurrVel);
    AZCurrPos = getAZCurrPos(MI4190);
    measApp.StatusTable.Data = {AZCurrPos;AZCurrPos + incrementSize;AZCurrVel;anglesRemaining};

    %Make sure Axis (AZ) position did not change during USRP error checking
    %and also check that it is not moving.
    AZInPosition = verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,loadBar,measApp,anglesRemaining,incrementSize);
    if (AZIdle && AZInPosition)
        
        if (measApp.wantToStop) break; end
           
        fprintf('\n[%s] Taking measurement at %.2f degrees\n',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190));
        measApp.writeConsoleLine('[%s] Taking measurement at %.2f degrees\n',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190));
        
        waitbar(loadBarProgress,loadBar,sprintf('Taking Measurement at %.2f degrees...',currentDegree));
        
       %%%[~,usrpMeasurement] = system(takeMeasurementCommand);

        if (currentDegree ~= degInterval(end))
            
            if (measApp.wantToStop) break; end
                
            fprintf('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            measApp.writeConsoleLine('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            waitbar(loadBarProgress,loadBar,sprintf('Incrementing MI4190 Position by %.2f degrees',incrementSize));
            incrementAxisByDegree(MI4190,incrementSize);
            dots(4);
            
        else
            
            cprintf('-comments','[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
            measApp.writeConsoleLine('[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
            waitbar(1,loadBar,sprintf('Done with current set of measurements!'));
            
        
        end
        
    elseif (~AZIdle)
        
        stopAxisMotion(MI4190,loadBarProgress,loadBar);
    
    end
    if (measApp.wantToStop) break; end
end

endTime = datestr(now,'HH:MM:SS.FFF');
elapsedTime = datestr(datetime(endTime) - datetime(startTime),'HH:MM:SS');
fprintf('Elapsed Time: %s\n',elapsedTime);
measApp.writeConsoleLine('Elapsed Time: %s\n',elapsedTime);

cprintf('strings','Log saved to: %s\n',logFile);
measApp.writeConsoleLine('Log saved to: %s\n',logFile);
delete(measApp);
diary off;


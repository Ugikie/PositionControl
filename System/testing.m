close all; clear all; clc;

measApp = startApp();

[logFileName,logFile] = logFilePath();
diary(logFile);
cprintf('strings','Saving log to: %s\n',logFile);
fprintf('\n');
measApp.writeConsoleLine(sprintf('Saving log to: %s\n',logFile));

if (measApp.wantToStop) delete(measApp); return; end

%===================================SETUP=================================%
% Specify the virtual serial port created by USB driver. It is currently
% configured to work for a Mac, so if a PC is being used this will need to
% be changed (e.g., to a port such as COM3)
MI4190 = serial('/dev/ttyUSB0');                 % Linux
system('sudo chmod 666 /dev/ttyUSB0');
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
measApp.writeConsoleLine(sprintf('Position Controller ID: %s\n',idn));
%===============================END SETUP=================================%

if (measApp.wantToStop) delete(measApp); return; end

%Check status of Axis (AZ) Details in function description.
AZCurrStat = getAndDecodeStatus(MI4190,measApp)

if (measApp.wantToStop) delete(measApp); return; end

%Get current position of Axis (AZ) and store it in AZCurrPos, along with
%the current Velocity in AZCurrVel.
AZCurrPos = getAZCurrPos(MI4190,measApp);
AZCurrVel = getAZCurrVelocity(MI4190,measApp);

if (measApp.wantToStop) delete(measApp); return; end

%Define the ideal starting position of the Axis (AZ) and the threshold in
%which the AZ should be in. Usually sits within +- 0.5 degrees of the
%commanded position. Using 0.6 to get just outside that range.
AZStartPos = -90.0000;
POSITION_ERROR = 0.6;

measApp.StatusTable.Data{2,1} = AZStartPos;
measApp.StatusTable.Data{4,1} = 'N/A';

if (measApp.wantToStop) delete(measApp); return; end

%Create a waitbar to show progress during measurement cycle. Add elapsed
%time
startTime = datestr(now,'HH:MM:SS.FFF');

if (measApp.wantToStop) delete(measApp); return; end

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
verifyIfInPosition(MI4190,AZStartPos,POSITION_ERROR,0,measApp,'N','N','v');

if (measApp.wantToStop) delete(measApp); return; end

%Allow user to input desired increment size for degree changes on Axis (AZ)
incrementSize = measApp.incrementSizeObj;
while ((incrementSize <= 0) || (incrementSize > 180)) 
    if (measApp.wantToStop) break; end
    updateLamps(AZCurrVel,measApp,false,false);
    measApp.updateProgressBar(0,sprintf('Waiting for user input...'));
    
    %incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
    
    incrementSize = measApp.incrementSizeObj;
    while (incrementSize == 0)
        fprintf('[%s] Please enter a valid increment size!\n',datestr(now,'HH:MM:SS.FFF'))
        measApp.writeConsoleLine(sprintf('[%s] Please enter a valid increment size!\n',datestr(now,'HH:MM:SS.FFF')))
        while (incrementSize == 0)
            if (measApp.wantToStop) break; end
            incrementSize = measApp.incrementSizeObj;
            pause(1)
        end
        if (measApp.wantToStop) break; end
    end
    if (measApp.wantToStop) break; end
end
if (measApp.wantToStop) delete(measApp); return; end

fprintf('[%s] Increment size chosen: %.2f\n',datestr(now,'HH:MM:SS.FFF'),incrementSize)
measApp.writeConsoleLine(sprintf('[%s] Increment size chosen: %.2f\n',datestr(now,'HH:MM:SS.FFF'),incrementSize))
measApp.IncrementSizeEditField.Editable = false;
measApp.IncrementSizeConfirmButton.Enable = false;
degInterval = -90:incrementSize:90;

centerFreq = measApp.centerFreqObj;
centerFreqUnits = measApp.centerFreqUnitsObj;
while (centerFreq == 0 || strcmp(centerFreqUnits,'Select units...'))
    fprintf('[%s] Please enter a valid center frequency!\n',datestr(now,'HH:MM:SS.FFF'))
    measApp.writeConsoleLine(sprintf('[%s] Please enter a valid center frequency!\n',datestr(now,'HH:MM:SS.FFF')))
    while (centerFreq == 0 || strcmp(centerFreqUnits,'Select units...'))
        if (measApp.wantToStop) break; end
        centerFreq = measApp.centerFreqObj;
        centerFreqUnits = measApp.centerFreqUnitsObj;
        pause(1);
    end
    if (measApp.wantToStop) break; end
end
if (measApp.wantToStop) return; end

fprintf('[%s] Center frequency chosen: %.5f %s\n',datestr(now,'HH:MM:SS.FFF'),centerFreq,centerFreqUnits)
measApp.writeConsoleLine(sprintf('[%s] Center frequency chosen: %.5f %s\n',datestr(now,'HH:MM:SS.FFF'),centerFreq,centerFreqUnits))
measApp.CenterFrequencyValue.Editable = false;
measApp.CenterFrequencyUnits.Enable = false;
measApp.CenterFreqConfirmButton.Enable = false;
setVNACentFreq(centerFreq,centerFreqUnits,MI4190,measApp);

if (measApp.wantToStop) return; end

%Initiates the boot process for the USRP N210 & N310.
%%%bootUSRPs(0,measApp);
gnuFileName = '/ArrayTest3.py ';
gnuFilePath = fileparts(matlab.desktop.editor.getActiveFilename);
%Loops through each degree in the interval and communicates with the USRP
%to take automatic measurements, with many checks along the way to ensure
%the safety of the system.
measApp.itrObj = 0;
for currentDegree = degInterval
    if (measApp.wantToStop) break; end
    
    takeMeasurementCommand = ['sudo python ' gnuFilePath gnuFileName ' ' num2str(incrementSize) ' ' logFileName ' ' num2str(currentDegree)];

    measApp.itrObj = measApp.itrObj + 1;
    loadBarProgress = (measApp.itrObj/length(degInterval));
    
    [~,idx] = find(degInterval == currentDegree);
    anglesRemaining = length(degInterval) - idx;
    
    measApp.StatusTable.Data{2,1} = measApp.StatusTable.Data{1,1} + incrementSize;
    measApp.StatusTable.Data{4,1} = anglesRemaining;
    drawnow();
    if (measApp.wantToStop) break; end
    
    %measApp.updateProgressBar(loadBarProgress,sprintf('Measurement in progress. Current Angle: %.2f',currentDegree));
    cprintf('-comment','\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    measApp.writeConsoleLine(sprintf('\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree));
    
    verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,measApp,anglesRemaining,incrementSize,'v');
    if (measApp.wantToStop) break; end
    %verify connection to USRP via uhd_find_devices
    %Calls the USRP Error Checking function that for now simulates a random
    %USRP error by generating a '1' for an error and '0' for no error.
   %%% usrpErrorChecker(loadBarProgress,measApp);
    
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement   
    %can remove for efficiency (happens in the next line in verifyIfInPos) %AZCurrPos = getAZCurrPos(MI4190,measApp);
    %can remove for efficiency %measApp.StatusTable.Data = {AZCurrPos;AZCurrPos + incrementSize;AZCurrVel;anglesRemaining};
    %Make sure Axis (AZ) position did not change during USRP error checking
    %and also check that it is not moving.
    AZInPosition = verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,loadBarProgress,measApp,anglesRemaining,incrementSize);
    AZCurrVel = getAZCurrVelocity(MI4190,measApp);
    AZIdle = verifyIfIdle(MI4190,AZCurrVel,measApp);
    if (measApp.wantToStop) return; end
    
    if (AZIdle && AZInPosition)
        
        if (measApp.wantToStop) break; end
           
        fprintf('\n[%s] Taking measurement at %.2f degrees\n',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190,measApp));
        measApp.writeConsoleLine(sprintf('[%s] Taking measurement at %.2f degrees\n',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190,measApp)));
        measApp.updateProgressBar(loadBarProgress,sprintf('Taking Measurement at %.2f degrees...',currentDegree));
        updateLamps(AZCurrVel,measApp,true,false);
        pause(1.5);
       %%%[~,usrpMeasurement] = system(takeMeasurementCommand);
        
        if (currentDegree ~= degInterval(end))
            
            if (measApp.wantToStop) break; end
            
            fprintf('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            measApp.writeConsoleLine(sprintf('[%s] Incrementing MI4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize));
            measApp.updateProgressBar(loadBarProgress,sprintf('Incrementing MI4190 Position by %.2f degrees',incrementSize));
            
            incrementAxisByDegree(MI4190,incrementSize,measApp);
            dots(4);
            
        else
            updateLamps(AZCurrVel,measApp,false,false);
            
            cprintf('-comments','[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
            measApp.writeConsoleLine(sprintf('[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF')));
            waitbar(1,sprintf('Done with current set of measurements!'));
            
        
        end
        
    elseif (~AZIdle)
        
        stopAxisMotion(MI4190,loadBarProgress,measApp);
    
    end
    if (measApp.wantToStop) break; end
end

endTime = datestr(now,'HH:MM:SS.FFF');
elapsedTime = datestr(datetime(endTime) - datetime(startTime),'HH:MM:SS');
fprintf('Elapsed Time: %s\n',elapsedTime);
measApp.writeConsoleLine(sprintf('Elapsed Time: %s\n',elapsedTime));
measApp.writeConsoleLine(sprintf('Log saved to: %s\n',logFile));
cprintf('strings','Log saved to: %s\n',logFile);

if (~isempty(measApp))
    delete(measApp);
    clear measApp;
end

if (~isempty(MI4190) && isvalid(MI4190))
    fclose(MI4190);
    delete(MI4190);
    clear MI4190;
end

if (exist('measApp','var'))
    delete(measApp);
end

diary off;


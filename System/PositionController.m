
close all; clear all; clc;
%===================================SETUP=================================%
% Specify the virtual serial port created by USB driver. It is currently
% configured to work for a Mac, so if a PC is being used this will need to
% be changed (e.g., to a port such as COM3)
% MI4190 = serial('/dev/tty.usbserial-PX2DN8ZM');
MI4190 = serial('COM3');

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

pause(1)

warning('off','MATLAB:serial:fread:unsuccessfulRead');

% Configure as Controller (++mode 1), instrument address 4, and with
% read-after-write (++auto 1) enabled
fprintf(MI4190, '++mode 1');
fprintf(MI4190, '++addr 4');
fprintf(MI4190, '++auto 1');

% Read the id of the Controller to verify connection:
fprintf(MI4190, '*idn?');
idn = char(fread(MI4190, 100))'
%===============================END SETUP=================================%

%Check status of axis, returns an integer value representing a 16 bit value
%of status bits. Details on page 3-42 of MI-4192 Manual
%==Add function later to decode status value==%
fprintf(MI4190, 'CONT1:AXIS(1):STAT?');
axis1CurrStatChar = char(fread(MI4190, 100))'

%Get current position of Axis (AZ) and store it in AZCurrPosChar
%Convert AZCurrPosChar from a char array to a string, then to double
AZCurrPos = getAZCurrPos(MI4190);

%Define the ideal starting position of the Axis (AZ) and the threshold in
%which the AZ should be in. Usually sits within +- 0.5 degrees of the
%commanded position. Using 0.6 to get just outside that range.
AZStartPos = -90.0000;
POSITION_ERROR = 0.6;

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
verifyIfInPosition(MI4190,AZStartPos,POSITION_ERROR,'v');

%Allow user to input desired increment size for degree changes on Axis (AZ)
incrementSize = -1;
while ((incrementSize <= 0) || (incrementSize > 180)) 
    fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
    incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
end
degInterval = -90:incrementSize:90;

%Loops through each degree in the interval and communicates with the USRP
%to take automatic measurements, with many checks along the way to ensure
%the safety of the system.
for currentDegree = degInterval
    
    fprintf('\n[%s] Current Degree Measurement: %.2f\n',datestr(now,'HH:MM:SS.FFF'),currentDegree);
    verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR,'v');
    
    fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
    unix('echo Turn on GNU');
    
    %Calls the USRP Error Checking function that for now simulates a random
    %USRP error by generating a '1' for an error and '0' for no error.
    usrpErrorChecker();
    
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement
    AZCurrVel = getAZCurrVelocity(MI4190);
    AZIdle = verifyIfIdle(MI4190,AZCurrVel);
    
    %Make sure Axis (AZ) position did not change during USRP error checking
    %and also check that it is not moving.
    AZInPosition = verifyIfInPosition(MI4190,currentDegree,POSITION_ERROR);
    if (AZIdle && AZInPosition)
        fprintf('[%s] Measure angle %.2f',datestr(now,'HH:MM:SS.FFF'),getAZCurrPos(MI4190));
        dots(3);
        if (currentDegree ~= degInterval(end))
            fprintf('[%s] Increment 4190 Position by %.2f degrees',datestr(now,'HH:MM:SS.FFF'),incrementSize);
            incrementAxisByDegree(MI4190,incrementSize);
            dots(4);
        else
            fprintf('[%s] Done with current set of measurements!\n',datestr(now,'HH:MM:SS.FFF'));
        end
    elseif (~AZIdle)
        stopAxisMotion(MI4190);
    end
    
end

fclose(MI4190);



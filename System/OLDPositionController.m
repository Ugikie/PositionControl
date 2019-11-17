
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
char(fread(MI4190, 100))'
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
positionError = 0.6;

%If the current position of Axis (AZ) is outside the range of the desired
%starting position, in this case outside the range: (-90.06,-89.94), then
%command it to go to the starting position (-90.00). 'v' enables verbose
verifyIfInPosition(MI4190,AZStartPos,positionError,'v');

%Allow user to input desired increment size for degree changes on AZ axis
incrementSize = -1;
while ((incrementSize <= 0) || (incrementSize > 180)) 
    incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
end
degInterval = -90:incrementSize:90;

for currentDegree = degInterval
    noErrors = true;
    fprintf('\nCurrent Degree Measurement: %.2f\n',currentDegree);
    verifyIfInPosition(MI4190,currentDegree,positionError,'v');
    unix('echo Turn on GNU');
    tic
    while toc<=60
          dots(4);
          usrpError = randsrc(1,1,[0,1;0.9,0.1]); %replace with input from USRP saying if had error or not
          while (usrpError)
              noErrors = false;
              fprintf('Error in USRP Boot\n');
              unix('echo Restart GNU and USRP');
              dots(4);
              usrpError = randsrc(1,1,[0,1;0.7,0.3]); %replace with input from USRP saying if had error or not
              if (~usrpError)
                  fprintf('Error Cleared from USRP. Time elapsed: %.2f seconds\n',toc');
                  break;
              end
          end
          break;
    end
    
    if (noErrors)
        fprintf('No initial Error!\n');    
    end
    
    %Get Axis (AZ) current Velocity and make sure it is idle before
    %taking measurement
    AZCurrVel = getAZCurrVelocity(MI4190);
    AZIdle = verifyIfIdle(MI4190,AZCurrVel);
    
    %at this point gnu should be on and usrp should be running
    %lets make sure there are no faults or errors with the 4190, make sure
    %it is not moving, and that it is still in the desired position for the
    %current measurement
    %if all is good, then begin to take measurements on the USRP for t sec.
    AZInPosition = verifyIfInPosition(MI4190,currentDegree,positionError);
    if (AZIdle && AZInPosition)
        fprintf('Measure angle %.2f',getAZCurrPos(MI4190));
        dots(3);
        if (currentDegree ~= degInterval(end))
            fprintf('Increment 4190 Position by %.2f degrees',incrementSize);
            incrementAxisByDegree(MI4190,incrementSize);
            dots(4);
        else
            fprintf('Done with current set of measurements!\n');
        end
    end
    
end

fclose(MI4190);



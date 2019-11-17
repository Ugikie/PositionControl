% Array response vector measurements using a D300 positioner and an
% Advantest R3860A VNA. Set up VNA prior to running (frequency, power, 
% calibration, etc.). Ensure computer and VNA are connected to the same
% router with the same workgroup name.
clc
clear all
close all

% Angle resolution in measurements (degrees)
phiStep   = 2;
phiEnd    = 360;

dataPath = './Data/';

% Set up VNA display
[status,out] = unix('"/Applications/National Instruments/NI-488.2/Interactive Control" < "setDisplay.txt"');

% Save VNA data command
saveDataCmd = '"/Applications/National Instruments/NI-488.2/Interactive Control" < saveData.txt';

% Set up the positioner
D300 = serial('/dev/tty.usbserial', 'BaudRate', 9600);
D300.Terminator = 'LF';
D300.DataTerminalReady = 'off';
D300.RequestToSend = 'off';
D300.FlowControl = 'software';
D300.Timeout = 2;

fopen(D300)

% fprintf('Resetting the positioner (60 seconds)')
% fwrite(D300,'RE ') % Reset the unit
% pause(60)

fwrite(D300,'LD ') % Disable the limits in order to get 360 degrees movement
fwrite(D300,'I ') % Execute commands immediately
fwrite(D300,'PS1900 ') % Set the pan speed
fwrite(D300,'TS1900 ') % Set the tilt speed

oneSecArc = 1/(60*60);
PR = 92.5714;
angRes = PR*oneSecArc;
angStep = 1; % The step size of the measurement angles in degrees
posAdj = angStep/angRes;

startPan = 'PP-7000 ';
startTilt = 'TP0 '; % Goes from -3500 to 1165
fwrite(D300,startPan);
fwrite(D300,startTilt);
%fwrite(D300,'A ');
pause(10)

%numThetas = thetaEnd/thetaStep;
numThetas = 0;
numPhis = phiEnd/phiStep;
    
for p = 1:numPhis
    traceName = ['DualPIFAs Theta=90' ' Phi=',num2str((p-1)*phiStep)];
    saveTraceCmd = ['FILE:STOR:DISP:TRAC "D:\\MyData\\Brad\\PIFAs\\' traceName '"'];
    fid = fopen('storeTrace.txt','w');
    fprintf(fid,saveTraceCmd);
    fclose(fid);
    [status,out] = unix(saveDataCmd);
    pause(0.5);

    deviceCmd = ['PO' num2str(round(phiStep/angRes)) ' '];
    fwrite(D300,deviceCmd);
    %fwrite(D300,'A ');
    clc
    fprintf('Current Angle: %i%s\n',p*phiStep,char(176));
    pause(1)
    
    if mod(p,100) == 0
        
        fclose(D300)
        delete(D300)
        clear D300
        pause(1)

        D300 = serial('/dev/tty.usbserial', 'BaudRate', 9600);
        D300.Terminator = 'LF';
        D300.DataTerminalReady = 'off';
        D300.RequestToSend = 'off';
        D300.FlowControl = 'software';
        D300.Timeout = 2;

        fopen(D300)
        pause(1)
    end

end

traceName = ['DualPIFAs Theta=90' ' Phi=',num2str(p*phiStep)];
saveTraceCmd = ['FILE:STOR:DISP:TRAC "D:\\MyData\\Brad\\PIFAs\\' traceName '"'];
fid = fopen('storeTrace.txt','w');
fprintf(fid,saveTraceCmd);
fclose(fid);
[status,out] = unix(saveDataCmd);
pause(1);


fclose(D300)
delete(D300)
clear D300

[status,out] = unix('open ''smb://guest:@192.168.1.116/PIFAs''');
pause(10)
[status,out] = unix(['cp /Volumes/PIFAs/*.csv ' dataPath]);
pause(5)

ReadPhiMeasurements(phiStep,phiEnd,dataPath);
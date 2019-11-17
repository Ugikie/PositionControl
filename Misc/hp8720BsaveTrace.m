% This script copies the trace displayed on the HP 8720B VNA to a computer 
% using the Prologix Controller and plots it. 
% Brad Jackson, CSUN
% Sept. 1, 2018

% Instructions:
% Turn on the VNA and allow it to warm up and reach a stable temperature. 
% Set the desired start/stop frequencies, number of points, etc., and then 
% perform a calibration. Once the calibration is complete, ensure the 
% display is showing a single log magnitude plot (in dB) of the desired
% S-parameter. The code was written to record S11 magnitude data in dB and 
% may need to be modified slightly for other S-parameters (or to save phase
% data). Ensure the Prologix Controller is connected to the HPIB port of 
% the VNA and a USB port of a computer before running. You can ignore the
% "Caution: addressed to talk with nothing to say" message on the VNA.

close all; clear all; clc;

% Specify the virtual serial port created by USB driver. It is currently
% configured to work for a Mac, so if a PC is being used this will need to
% be changed (e.g., to a port such as COM3)
vna = serial('/dev/tty.usbserial-PX2DN8ZM');

% Prologix Controller 4.2 requires CR as command terminator, LF is
% optional. The controller terminates internal query responses with CR and
% LF. Responses from the instrument are passed through as is. (See Prologix
% Controller Manual)
vna.Terminator = 'CR/LF';

% Reduce timeout to 0.5 second (default is 10 seconds)
vna.Timeout = 0.5;

% Open virtual serial port
fopen(vna);

pause(1)

warning('off','MATLAB:serial:fread:unsuccessfulRead');

% Configure as Controller (++mode 1), instrument address 16, and with
% read-after-write (++auto 1) enabled
fprintf(vna, '++mode 1');
fprintf(vna, '++addr 16');
fprintf(vna, '++auto 1');

% Read the start/stop frequencies and number of points from the VNA:
fprintf(vna, 'STAR?');
startFreq = char(fread(vna, 30))';
startFreq = str2num(startFreq(1:24));

fprintf(vna, 'STOP?');
stopFreq = char(fread(vna, 30))';
stopFreq = str2num(stopFreq(1:24));

fprintf(vna, 'POIN?');
numPoints = char(fread(vna, 30))';
numPoints = str2num(numPoints(1:24));

% Compute the expected frequency points from the VNA. The 8720B has a 100
% KHz frequency resolution, so round to this.
calcFreqs = 1e5*round((startFreq:(stopFreq-startFreq)/(numPoints-1):stopFreq)/1e5);

% Initialize the matrices that will be saving the recorded data
S11 = [];
freq = [];

% Hold the sweep so that the trace doesn't change while the data is read
fprintf(vna,'HOLD');

% The following loop moves the marker to each data point on the display, 
% reading both the S-parameter data and the frequency at each point
for n = 1:numPoints
    
    % Determine the current frequency in GHz based on the calculated 
    % frequencies
    curFreq = calcFreqs(n)/1e9;
    curFreqStr = num2str(curFreq);
    
    % Provide an update on the progress
    clc;
    fprintf('Saving data at: %2.3f GHz (Point %i/%i)\n',curFreq,n,numPoints);
    
    % Construct the command that will move the marker on the VNA to the
    % next data point
    mvMkrCmd = ['MARK1 ' curFreqStr ' GHZ'];

    % Issue the command to the VNA to move the marker
    fprintf(vna, mvMkrCmd);
    
    % Save the marker data to the VNA disk
    fprintf(vna, 'MARKDISC');
    
    % Output the marker data so that it can be read
    fprintf(vna, 'OUTPMARK');

    % Read the marker data
    curMarker = char(fread(vna, 100))';
    
    % Parse the data to extract only the S-parameter magnitude
    curS11 = str2num(curMarker(1:14));
    
    % Add this data point to the others that have previously been saved
    S11 = [S11; curS11];
    
    % Parse the output data for the frequency. This should be the same as
    % the calculated frequency, but this is to be sure it's the frequency
    % reported by the VNA
    curFreq = str2num(curMarker(34:49));
    
    % Add this frequency point to the others that have previously been 
    % saved
    freq = [freq;curFreq];

end

% Close the connection to the VNA
fclose(vna);

% Plot the data (this should look identical to the display on the VNA with
% the only exception of different y-axis limits)
plot(freq/1e9,S11,'-b','linewidth',2);
xlabel('Frequency (GHz)');
ylabel('S_{11} (dB)');
xlim([startFreq/1e9 stopFreq/1e9])
ylim([-40 0])
set(gca,'FontSize', 18);
set(gcf, 'Position', [500, 300, 900, 500]);
grid on

% Prepare the figure for saving
ti = get(gca,'TightInset');
set(gca,'Position',[ti(1) ti(2) 1-ti(3)-ti(1) 1-ti(4)-ti(2)]);
width = 30;
height = 20;
set(gcf, 'PaperUnits','centimeters');
set(gcf, 'PaperSize', [width height]);
set(gcf, 'PaperPositionMode', 'manual');
set(gcf, 'PaperPosition',[0 0 width height]);

% Save the figure as a PDF
print(gcf,'S11','-dpdf','-r300')

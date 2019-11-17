close all; clear all; clc;

MI4190 = fopen('testcomms.txt', 'w');
fprintf(MI4190, 'CONT1:AXIS(1):POS:COMM %f', -90.00);
fclose(MI4190);

%Allow user to input desired increment size for degree changes on AZ axis
incrementSize = -1;
while ((incrementSize <= 0) || (incrementSize > 180)) 
    incrementSize = input('Enter the desired degree increment size (Must be between 1-180): ');
end
degInterval = 1:incrementSize:180;

usrpError = false;
for currentDegree = degInterval
    noErrors = true;
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
    fprintf('Measure angle %.2f\n',currentDegree);
    dots(4);
    fprintf('Increment 4190 Position by %.2f degrees.\n',incrementSize);
    dots(4);
    %incrementAxisByDegree(MI4190,incrementSize);
    %at this point gnu should be on and usrp should be running
    %lets make sure there are no faults or errors with the 4190, make sure
    %it is not moving, and that it is still in the desired position for the
    %current measurement
    %if all is good, then begin to take measurements on the USRP for t sec.
    
end

function dots(delayAmount)
%dots Summary of this function goes here
%   Detailed explanation goes here
for i = 1:delayAmount
      fprintf('. ');
      pause(1);
end
fprintf('\n');
end

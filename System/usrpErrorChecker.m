function [] = usrpErrorChecker()
%USRPERRORHANDLER Checks for errors in USRP boot and reboots if necessary
%   If a USRP error occurs, then the system will send a reboot command to
%   the USRP and wait until it responds back with a successful bootup
%   message. The program will then resume as normal to take measurements.

    MAX_ERROR_WAIT_TIME = 10000; %seconds
    
    tic
    while toc<=MAX_ERROR_WAIT_TIME
          
          dots(4);
          usrpError = randsrc(1,1,[0,1;0.9,0.1]); %replace with input from USRP saying if had error or not
          
          while (usrpError)
              
              fprintf('[%s] Error in USRP Boot\n',datestr(now,'HH:MM:SS.FFF'));
              
              fprintf('[%s] ',datestr(now,'HH:MM:SS.FFF'));
              unix('echo Restart GNU and USRP');
              dots(4);
              
              usrpError = randsrc(1,1,[0,1;0.7,0.3]); %replace with input from USRP saying if had error or not
              if (~usrpError)
                  
                  fprintf('[%s] Error Cleared from USRP. Time elapsed: %.2f seconds\n',datestr(now,'HH:MM:SS.FFF'),toc');
                  break;
              
              end
              
          end
          
          fprintf('[%s] No initial Error!\n',datestr(now,'HH:MM:SS.FFF'));
          
          break;
    
    end
    
end


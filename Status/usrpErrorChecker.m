function [] = usrpErrorChecker(loadBarProgress,loadBar)
%USRPERRORHANDLER Checks for errors in USRP boot and reboots if necessary
%   If a USRP error occurs, then the system will send a reboot command to
%   the USRP and wait until it responds back with a successful bootup
%   message. The program will then resume as normal to take measurements.

    cprintf('strings','[%s] Checking USRP for errors',datestr(now,'HH:MM:SS.FFF'));
    waitbar(loadBarProgress,loadBar,sprintf('Checking USRP for errors.'));
    dots(3);
    
    MAX_ERROR_WAIT_TIME = 10000; %seconds
    tic
    while toc<=MAX_ERROR_WAIT_TIME
          
          usrpResponse = pingUSRP();
          while (~contains(usrpResponse,'ttl=')) %TTL= will only show on a successful ping
              

              cprintf('err','[%s][ERROR] USRP is not connected!',datestr(now,'HH:MM:SS.FFF'));
              waitbar(loadBarProgress,loadBar,sprintf('USRP not connected. Rebooting it...'));
              fprintf('[%s]Rebooting USRP. . .',datestr(now,'HH:MM:SS.FFF'));
              bootUSRPs(loadBarProgress,loadBar);
             
              cprintf('strings','[%s] Checking USRP for errors. . .\n',datestr(now,'HH:MM:SS.FFF'));
              waitbar(loadBarProgress,loadBar,sprintf('Checking USRP for errors...'));
              usrpResponse = pingUSRP();
              

              if (contains(usrpResponse,'ttl='))

                  fprintf('[%s] Error Cleared from USRP. Time elapsed: %.2f seconds\n',datestr(now,'HH:MM:SS.FFF'),toc');
                  waitbar(loadBarProgress,loadBar,sprintf('Error Cleared from USRP. Continuing...'));
                  return;

              end

          end
    
          fprintf('[%s] No initial Error!\n',datestr(now,'HH:MM:SS.FFF'));
          waitbar(loadBarProgress,loadBar,sprintf('No initial Error from USRP. Continuing...'));
          
          break;
    
    end
    
end

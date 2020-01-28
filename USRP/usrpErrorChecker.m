function [] = usrpErrorChecker(loadBarProgress,measApp)
%USRPERRORHANDLER Checks for errors in USRP boot and reboots if necessary
%   If a USRP error occurs, then the system will send a reboot command to
%   the USRP and wait until it responds back with a successful bootup
%   message. The program will then resume as normal to take measurements.

    cprintf('strings','[%s] Checking USRP for errors',datestr(now,'HH:MM:SS.FFF'));
    measApp.writeConsoleLine(sprintf('[%s] Checking USRP for errors',datestr(now,'HH:MM:SS.FFF')));
    measApp.updateProgressBar(loadBarProgress,sprintf('Checking USRP for errors...'));
    drawnow();
    dots(3);
    
    MAX_ERROR_WAIT_TIME = 10000; %seconds
    tic
    while toc<=MAX_ERROR_WAIT_TIME
          
          usrpResponse = pingUSRP();
          while (~contains(usrpResponse,'ttl=')) %TTL= will only show on a successful ping
              

              cprintf('err','[%s] [ERROR] USRP is not connected!\n',datestr(now,'HH:MM:SS.FFF'));
              measApp.writeConsoleLine(sprintf('[%s][ERROR] USRP is not connected!',datestr(now,'HH:MM:SS.FFF')));
              measApp.updateProgressBar(loadBarProgress,sprintf('USRP not connected. Rebooting it...'));
              fprintf('[%s] Rebooting USRP. . .\n',datestr(now,'HH:MM:SS.FFF'));
              measApp.writeConsoleLine(sprintf('[%s] Rebooting USRP. . .',datestr(now,'HH:MM:SS.FFF')));
              
              measApp.N310Lamp.Color = 'red';
              measApp.N310DisconnectedLabel.Text = 'N310 | Disconnected';
              drawnow();
              bootUSRPs(loadBarProgress,measApp);
             
              cprintf('strings','[%s] Checking USRP for errors. . .\n',datestr(now,'HH:MM:SS.FFF'));
              measApp.writeConsoleLine(sprintf('[%s] Checking USRP for errors. . .\n',datestr(now,'HH:MM:SS.FFF')));
              measApp.updateProgressBar(loadBarProgress,sprintf('Checking USRP for errors...'));
              drawnow();
              usrpResponse = pingUSRP();
              

              if (contains(usrpResponse,'ttl='))

                  fprintf('[%s] Error Cleared from USRP. Time elapsed: %.2f seconds\n',datestr(now,'HH:MM:SS.FFF'),toc');
                  measApp.writeConsoleLine(sprintf('[%s] Error Cleared from USRP. Time elapsed: %.2f seconds\n',datestr(now,'HH:MM:SS.FFF'),toc'));
                  measApp.updateProgressBar(loadBarProgress,sprintf('Error Cleared from USRP. Continuing...'));
                  measApp.N310Lamp.Color = 'green';
                  measApp.N310DisconnectedLabel.Text = 'N310 | Connected';
                  drawnow();
                  return;

              end

          end
    
          fprintf('[%s] No USRP Error!\n',datestr(now,'HH:MM:SS.FFF'));
          measApp.writeConsoleLine(sprintf('[%s] No USRP Error!\n',datestr(now,'HH:MM:SS.FFF')));
          measApp.updateProgressBar(loadBarProgress,sprintf('No initial Error from USRP. Continuing...'));
          drawnow();
          break;
    
    end
    
end

function [] = bootUSRPs(loadBarProgress,measApp)
%BOOTUSRPS Summary of this function goes here
%   Detailed explanation goes here
if (measApp.wantToStop) return; end

fprintf('[%s] Booting up USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine(sprintf('[%s] Booting up USRPs. . .\n',datestr(now,'HH:MM:SS.FFF')));
measApp.updateProgressBar(loadBarProgress,sprintf('Booting up USRPs...'));
drawnow();
n310IP = '192.168.10.2';
n210IP = '192.168.10.15';
%User must type in their password (because of sudo) once the program hits this command...
%just type it into the command window and hit 'Enter'. Working on a fix for
%this.... 
[~,usrpBoot] = system('bash USRPBoot');
while ~(contains(usrpBoot,n310IP) && contains(usrpBoot,n210IP))
    cprintf('err','[%s] [ERROR] USRP not found. Rebooting. . .\n',datestr(now,'HH:MM:SS.FFF'));
    measApp.writeConsoleLine(sprintf('[%s] [ERROR] USRP not found. Rebooting. . .\n',datestr(now,'HH:MM:SS.FFF')));
    [~,usrpBoot] = system('bash USRPBoot');
    
    measApp.N210Lamp.Color = 'red';
    measApp.N210DisconnectedLampLabel.Text = 'N210 | Disconnected';
    measApp.N310Lamp.Color = 'red';
    measApp.N310DisconnectedLabel.Text = 'N310 | Disconnected';
    drawnow();
end
fprintf('[%s] Verified connection to USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine(sprintf('[%s] Verified connection to USRPs. . .\n',datestr(now,'HH:MM:SS.FFF')));
measApp.updateProgressBar(loadBarProgress,sprintf('Verified connection to USRPs...'));

if (measApp.wantToStop) return; end
fprintf('[%s] USRP N210 Has IP: ',datestr(now,'HH:MM:SS.FFF'));
cprintf('-comment','%s\n',n210IP);
measApp.writeConsoleLine(sprintf('[%s] USRP N210 Has IP: %s and is now connected.\n',datestr(now,'HH:MM:SS.FFF'),n210IP));
measApp.N210Lamp.Color = 'green';
measApp.N210DisconnectedLampLabel.Text = 'N210 | Connected';

fprintf('[%s] USRP N310 Has IP: ',datestr(now,'HH:MM:SS.FFF'));
cprintf('-comment','%s\n',n310IP);
measApp.writeConsoleLine(sprintf('[%s] USRP N310 Has IP: %s and is now connected.\n',datestr(now,'HH:MM:SS.FFF'),n310IP));
measApp.N310Lamp.Color = 'green';
measApp.N310DisconnectedLabel.Text = 'N310 | Connected';

fprintf('[%s] Initiating USRP N210. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine(sprintf('\n[%s] Initiating USRP N210. . .',datestr(now,'HH:MM:SS.FFF')));
measApp.updateProgressBar(loadBarProgress,sprintf('Initiating USRP N210...'));

drawnow();
if (measApp.wantToStop) return; end
    
%Will run instantly and without output, because it is a continuous process 
%and Matlab will get stuck without adding the '&'
system('bash USRPN210Boot &'); 
end


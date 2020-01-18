function [] = bootUSRPs(loadBarProgress,loadBar,measApp)
%BOOTUSRPS Summary of this function goes here
%   Detailed explanation goes here
if (measApp.wantToStop) return; end

fprintf('[%s]Booting up USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine('[%s]Booting up USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));
waitbar(loadBarProgress,loadBar,sprintf('Booting up USRPs...')); 
n310IP = '192.168.10.2';
n210IP = '192.168.10.15';
[~,usrpBoot] = system('bash USRPBoot');
while ~(contains(usrpBoot,n310IP) && contains(usrpBoot,n210IP))
    cprintf('err','[%s][ERROR] USRP not found. Rebooting. . .\n',datestr(now,'HH:MM:SS.FFF'));
    measApp.writeConsoleLine('[%s][ERROR] USRP not found. Rebooting. . .\n',datestr(now,'HH:MM:SS.FFF'));
    [~,usrpBoot] = system('bash USRPBoot');
end
waitbar(loadBarProgress,loadBar,sprintf('Verified connection to USRPs...'));
fprintf('[%s]Verified connection to USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine('[%s]Verified connection to USRPs. . .\n',datestr(now,'HH:MM:SS.FFF'));

if (measApp.wantToStop) return; end

fprintf('USRP N310 Has IP: ');
cprintf('-comment','%s\n',n310IP);
measApp.writeConsoleLine('USRP N310 Has IP: %s\n',n310IP);

fprintf('USRP N210 Has IP: ');
cprintf('-comment','%s\n',n210IP);
measApp.writeConsoleLine('USRP N210 Has IP: %s\n',n210IP);

waitbar(loadBarProgress,loadBar,sprintf('Initiating USRP N210...'));
fprintf('[%s]Initiating USRP N210. . .\n',datestr(now,'HH:MM:SS.FFF'));
measApp.writeConsoleLine('[%s]Initiating USRP N210. . .\n',datestr(now,'HH:MM:SS.FFF'));

if (measApp.wantToStop) return; end
    
%Will run instantly and without output, because it is a continuous process 
%and Matlab will get stuck without adding the '&'
system('bash USRPN210Boot &'); 
end


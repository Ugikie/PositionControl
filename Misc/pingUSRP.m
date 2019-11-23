function [usrpPingResponse] = pingUSRP()
%PINGUSRP Summary of this function goes here
%   Detailed explanation goes here
if (randsrc(1,1,[1,0;0.9,0.1]))
    [~,usrpPingResponse] = system('ping -n 3 127.0.0.1');
else
    [~,usrpPingResponse] = system('ping -n 3 192.168.10.1');
end
end


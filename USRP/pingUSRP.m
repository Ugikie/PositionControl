function [usrpPingResponse] = pingUSRP()
%PINGUSRP Summary of this function goes here
%   Detailed explanation goes here
[~,usrpPingResponse] = system('ping -c 3 192.168.10.2');
end


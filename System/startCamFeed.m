function [anechoicCam,camSize] = startCamFeed()
%STARTCAMFEED Summary of this function goes here
%   Detailed explanation goes here
anechoicCam = ipcam('http://192.168.10.7:80/streaming/channels/1/httppreview', 'admin', 'USRPN310!');
end


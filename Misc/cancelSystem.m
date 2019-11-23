function [] = cancelSystem(src,event,logFile)
%CANCELSYSTEM Summary of this function goes here
%   Detailed explanation goes here
    fprintf('\n[%s] Cancelling. . .\n',datestr(now,'HH:MM:SS.FFF'));

    hFigures = allchild( groot );
    hWaitbar = hFigures( arrayfun( @(h) strcmp( h.Tag, 'TMWWaitbar' ), hFigures ) );
    delete( hWaitbar );
    
    %fclose(MI4190);
    cprintf('strings','Log saved to: %s\n',logFile);
    diary off;
end


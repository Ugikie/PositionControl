function [] = cancelSystem(loadBarProgress,loadBar)
    waitbar(loadBarProgress,loadBar,sprintf('Cancelling...'));
    fprintf('\n[%s] Cancelling\n',datestr(now,'HH:MM:SS.FFF'));
end

function [] = cancelSystem(loadBarProgress,loadBar)
    waitbar(loadBarProgress,loadBar,sprintf('Cancelling...'));
    fprintf('\n[%s] Cancelling',datestr(now,'HH:MM:SS.FFF'));
    dots(2);
end

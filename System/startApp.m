function [measurementApp] = startApp()
%STARTAPP Opens the measurement app.
%   Opens the measument GUI and sets the window to always be on top.
measurementApp = app1();
pause(2);
activeWindows = matlab.internal.webwindowmanager.instance.windowList;
index = ismember({activeWindows.Title},'Measurement App');
if any(index)
    activeWindows(index).setAlwaysOnTop(true);
end
event.Source.Visible = false;
end


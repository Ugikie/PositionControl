a = -90:5:90;
f = waitbar(0,'Please wait...');
pause(0.5)
itr = 1;
for i = a
    waitbar((itr/length(a)),f,sprintf('Measurement in progress. Current Angle: %.2f',i));
    itr = itr + 1;
    pause(1)
    waitbar((itr/length(a)),f,sprintf('Moving Axis (AZ)'));
    pause(0.5)
end
close(f)

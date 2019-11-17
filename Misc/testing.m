t = timer('TimerFcn', 'stat=false;' ,StartDelay',10);
start(t)

stat=true;
while(stat==true)
  pause(0.75);
  fprintf('. ')
  pause(0.75);
end
% Read rainfall for the last 7 days from a ThingSpeak channel and 
% visualize variations using the MATLAB HISTOGRAM function. 
   
% Channel 703956 contains data from the DPI Weather Station, located 
% in Batemans Bay, NSW. The data is collected once every 15 minutes. Field 
% 2 contains rainfall data. 
% Channel ID to read data from 
readChannelID = 703956; 
   
% Temperature Field ID 
rainID = 2; 
   
% Channel Read API Key   
% If your channel is private, then enter the read API 
% Key between the '' below:   
 readAPIKey = 'HJZQ41XW5YEBNOYX'; 

format longG
t = now
t2=datetime(datevec(now))
t1=t2-7 %takes 8 days to capture Day1's rain ie. from 9amDay0 to 9amDay1

 [data, timeStamps] = thingSpeakRead(readChannelID,'Fields',rainID, 'DateRange',[datetime(t1),datetime(t2)],'ReadKey',readAPIKey,'outputformat','timetable');

 
 % reverse order to get same as thingspeak
  data.Timestamps.TimeZone='Australia/Sydney';  
 syd=data.Timestamps(end)
 
 data.Timestamps.TimeZone='UTC';
 utc=data.Timestamps(end)
 
 
 data(1:5,:)
 
 %% manual sum=
 ld.d25=data.Timestamps>datetime(2019,7,24,9,0,0,'timezone','Australia/Sydney')& data.Timestamps<datetime(2019,7,25,9,0,0,'timezone','Australia/Sydney');
 ld.d26=data.Timestamps>datetime(2019,7,25,9,0,0,'timezone','Australia/Sydney');
 
 sumd25=sum(data.Precipitationmm(ld.d25));
 sumd26=sum(data.Precipitationmm(ld.d26));
 
%%
  
% %solution 1 for 9 to 9
% % change hour in first date to 9am
% t1.Hour=9;
% t1.Minute=0;
% t1.Second=0;
% t1.TimeZone='Australia/Sydney';  %assign time zone
 
% t2.Hour=9;
% t2.TimeZone='Australia/Sydney';
% newTimes = t1:hours(24):t2;  %create vector of datetimes at 9am
% dailysummidnight1 = retime(data,newTimes,'sum');   %sum to those datetimes
% %right value, right time, more finicky.
% 
% % solution 2 for 9 to 9, change the time zones - correct but need to
% change the day to one day later - will do this in display
 data.Timestamps.TimeZone='+1'; %+1 UTC is 9 hours previous 
 dailysummidnight2 = retime(data, 'daily', 'sum');
 dailysummidnight2.Timestamps.TimeZone='Australia/Sydney';

 
% % %  matt's code
%   weekrain = dailysummidnight2(3:8,1); %removes Day0 ie 8 to 7days
%   weeksum = sum(weekrain.Precipitationmm);
%   weeksumR = round(weeksum,1);
%   weekrainX = weekrain.Timestamps %+1; %add day to date 
  
%jbw - alternative
week1=dailysummidnight2(end-6:end,:); % last day - 6 days inclusive
weeksum2=round(sum(week1.Precipitationmm),1);
%   

x=week1.Timestamps + days(1) -hours(9);  % create new xaxis with proper display times
 figure

  bar(x, week1.Precipitationmm)
  set(gca,'xtick',x)
  grid on
 ylabel('Rainfall in millermeters');
 title('Rainfall for last 7 days');
 barlabels = arrayfun(@(value) num2str(value,'%2.1f'),week1.Precipitationmm,'UniformOutput',false);
 text(x, week1.Precipitationmm, barlabels,'HorizontalAlignment','center','VerticalAlignment','bottom');
 box off
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%   original
 
 % Read rainfall for the last 7 days from a ThingSpeak channel and 
% visualize variations using the MATLAB HISTOGRAM function. 
   
% Channel 703956 contains data from the DPI Weather Station, located 
% in Batemans Bay, NSW. The data is collected once every 15 minutes. Field 
% 2 contains rainfall data. 
% Channel ID to read data from 
readChannelID = 703956; 
   
% Temperature Field ID 
rainID = 2; 
   
% Channel Read API Key   
% If your channel is private, then enter the read API 
% Key between the '' below:   
 readAPIKey = 'HJZQ41XW5YEBNOYX'; 

format longG
t = now
t2=datetime(datevec(now))
t1=t2-7 %takes 8 days to capture Day1's rain ie. from 9amDay0 to 9amDay1

 [data, timeStamps] = thingSpeakRead(readChannelID,'Fields',rainID, 'DateRange',[datetime(t1),datetime(t2)],'ReadKey',readAPIKey,'outputformat','timetable');
 data(1:5,:)
 data.Timestamps.TimeZone='UTC';
 utc=data.Timestamps(end)
 data.Timestamps.TimeZone='Australia/Sydney';
 syd=data.Timestamps(end)
  
% %solution 1 for 9 to 9
% % change hour in first date to 9am
% t1.Hour=9;
% t1.Minute=0;
% t1.Second=0;
% t1.TimeZone='Australia/Sydney';  %assign time zone
 
% t2.Hour=9;
% t2.TimeZone='Australia/Sydney';
% newTimes = t1:hours(24):t2;  %create vector of datetimes at 9am
% dailysummidnight1 = retime(data,newTimes,'sum');   %sum to those datetimes
% %right value, right time, more finicky.
% 
% % solution 2 for 9 to 9, change the time zones
 data.Timestamps.TimeZone='+1'; %+1 UTC is 9 hours previous 
 dailysummidnight2 = retime(data, 'daily', 'sum');
 dailysummidnight2.Timestamps.TimeZone='Australia/Sydney';

  weekrain = dailysummidnight2(3:8,1); %removes Day0 ie 8 to 7days
  %weekrain.Timestamps +1'; %add day to date 
  weeksum = sum(weekrain.Precipitationmm);
  weeksumR = round(weeksum,1);
  
 %
 figure
  weekrainX = weekrain.Timestamps %+1; %add day to date 
  bar(weekrainX, weekrain.Variables)
  grid on
 ylabel('Rainfall in millermeters');
 title('Rainfall for last 7 days');
 barlabels = arrayfun(@(value) num2str(value,'%2.1f'),weekrain.Variables,'UniformOutput',false);
 text(weekrainX, weekrain.Variables, barlabels,'HorizontalAlignment','center','VerticalAlignment','bottom');
 box off
 text(7 ,0, ['Weekly Total (mm)= ' num2str(weeksumR)],'Rotation', 90, 'Color','blue','FontSize',11);
 %%
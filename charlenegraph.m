g% Read temperature for the last 10 hours from a ThingSpeak channel and 
% visualize temperature variations using the MATLAB HISTOGRAM function. 
   
% Channel 12397 contains data from the MathWorks Weather Station, located 
% in Natick, Massachusetts. The data is collected once every minute. Field 
% 4 contains temperature data. 
% Channel ID to read data from 
readChannelID = 703956; 
   
% Temperature Field ID 
rainID = 2; 
   
% Channel Read API Key   
% If your channel is private, then enter the read API 
% Key between the '' below:   
readAPIKey = 'HJZQ41XW5YEBNOYX'; 

format longG
t = now;
t2=datetime(datevec(now));
t1=t2-6;

%data being read in local time.
[data, timeStamps] = thingSpeakRead(readChannelID,'Fields',rainID, 'DateRange',[datetime(t1),datetime(t2)],'ReadKey',readAPIKey,'outputformat','timetable');

%%

data.Timestamps.TimeZone='UTC';

data.Timestamps.TimeZone='Australia/Sydney';


%solution 1 for 9 to 9
% change hour in first date to 9am
t1.Hour=9;
t1.Minute=0;
t1.Second=0;
t1.TimeZone='Australia/Sydney';  %assign time zone

t2.Hour=9;
t2.TimeZone='Australia/Sydney';
newTimes = t1:hours(24):t2;  %create vector of datetimes at 9am
dailysummidnight1 = retime(data,newTimes,'sum');   %sum to those datetimes
%right value, right time, more finicky.

% solution 2 for 9 to 9, change the time zones
data.Timestamps.TimeZone='+1'; %9 hours previous +1 UTC
dailysummidnight2 = retime(data, 'daily', 'sum');
dailysummidnight2.Timestamps.TimeZone='Australia/Sydney';



%also both of these methods assign the sum of precip from jun 23-jun24 to jun 23, not jun
%24.  







bar(dailysum.Timestamps, dailysum.Variables)

xlabel('Date');
ylabel('Rainfall in millermeters');
title('Rainfall for last 7 days');
grid on;

%% thingspeak:
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
t1=t2-6

[data, timeStamps] = thingSpeakRead(readChannelID,'Fields',rainID, 'DateRange',[datetime(t1),datetime(t2)],'ReadKey',readAPIKey,'outputformat','timetable');
data(1:5,:)
 data.Timestamps.TimeZone='UTC';
 utc=data.Timestamps(end)
data.Timestamps.TimeZone='Australia/Sydney';
%UTC-5 = 15hours behind Sydney, converts midnight to 9am%
 %data.Timestamps.TimeZone='UTC-5'; 
 syd=data.Timestamps(end)
 
  dailydata = retime(data,'daily');
  dailysum = retime(data, 'daily', 'sum');
  weeksum = sum(dailysum.Precipitationmm);
 %
 figure
  bar(dailysum.Timestamps, dailysum.Variables)
  grid on
 %  xlabel('Date');
 ylabel('Rainfall in millermeters');
 title({'Rainfall for last 7 days','Orange Station'});
 barlabels = arrayfun(@(value) num2str(value,'%2.1f'),dailysum.Variables,'UniformOutput',false);
 text(dailysum.Timestamps, dailysum.Variables, barlabels,'HorizontalAlignment','center','VerticalAlignment','bottom');
 box off
 text(2,.2, {'weekly sum= ' num2str(weeksum)}, 'Color','blue','FontSize',14);
 % datacursormode on
 %%


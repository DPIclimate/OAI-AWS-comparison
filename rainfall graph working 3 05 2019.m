% Read temperature for the last 10 hours from a ThingSpeak channel and 
% visualize temperature variations using the MATLAB HISTOGRAM function. 
   
% Channel 12397 contains data from the MathWorks Weather Station, located 
% in Natick, Massachusetts. The data is collected once every minute. Field 
% 4 contains temperature data. 
% Channel ID to read data from 
readChannelID = 462617; 
   
% Temperature Field ID 
rainID = 2; 
   
% Channel Read API Key   
% If your channel is private, then enter the read API 
% Key between the '' below:   
readAPIKey = '1M44JWBZCDB1B8IR'; 

format longG
t = now
%t.TimeZone = 'Australia/Sydney'
tt = datetime(t, 'ConvertFrom','datenum')
t2 = floor(t)
d2 = datetime(t2, 'ConvertFrom','datenum')
t3 = datetime('now')
t4 = datestr(t)
t5.TimeZone = 'Australia/Sydney'
t6 = (tt + hours(10))

% [data, timeStamps ] = thingSpeakRead(readChannelID,'Fields',solarID, 'DateRange',[datetime(tt-7),datetime(tt)],'ReadKey',readAPIKey);
[data, timeStamps ] = thingSpeakRead(readChannelID,'Fields',rainID, 'DateRange',[datetime(t6-8),datetime(t6)],'ReadKey',readAPIKey,'outputformat','timetable');
dailydata = retime(data,'daily');
dailysum = retime(data, 'daily', 'sum')
dailysum.Properties.DimensionNames
dailysum.Variables
dailysum.Timestamps

dailysum([1],:) = []
size(dailysum)



bar(dailysum.Timestamps, dailysum.Variables)

xlabel('Date');
ylabel('Rainfall in millermeters');
title('Rainfall for last 7 days');
grid on;



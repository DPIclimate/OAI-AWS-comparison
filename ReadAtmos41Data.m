

%jbw note: thingspeak read auto reads data in local time but without
%assigning timezone.  repeat of times during DST is then not properly
%converted to UTC 
%
% api read on the other hand can auto assign timezone, but requires some
% fiddling to get to datetime - also fields are in character format instead
% of numerical and fieldnames cannot be automatically inserted.
% 
% therefore using a combination of webread and thingspeakread
cd('G:\AR2\Crc\ClimateUnit\Projects\EDIS\jenmatlab\OAI_station_compare')
% %% api
% 
% api='http://api.thingspeak.com/channels/462617/feed.json?start=2018-04-01%2000:00:00&end=2018-05-29%2000:00:00&timezone=Australia%2FSydney';
% s=webread(api);
% 
% % api='http://api.thingspeak.com/channels/462617/feed.json?start=2018-03-31%2000:00:00&end=2018-04-02%2011:11:11&timezone=UTC';
% % s2=webread(api);
% 
% T1=struct2table(s.feeds); %convert structure 2 table
% tz=datetime(T1.created_at,'inputformat','yyyy-MM-dd''T''HH:mm:ssXXX','timezone','UTC');  %return UTC+11 in UTC time (no dst)
% 

%% Retrieve data from ThingSpeak channel for ATMOS41


% Channel ID to read data from
readChannelID1 = 462617; %atmos41-01
readChannelID2 = 462618; %atmos41-02

%%%%%%% 1
startDate = 'February 1, 2019 00:00';  %max 8000
endDate = 'February 9, 2019 00:00';
% Specify date range
dateRange = [datetime(startDate),datetime(endDate)];
% Read data including the timestamp, and channel information. %timestamp is
% auto converted to local (AEST) time
[data1a,channelInfo1] = thingSpeakRead(readChannelID1,'Fields',1:8,...
                          'DateRange',dateRange,'outputformat','timetable');   
api='http://api.thingspeak.com/channels/462617/feed.json?start=2019-02-01%2000:00:00&end=2019-02-09%2000:00:00&timezone=Australia%2FSydney';
s=webread(api);
T1=struct2table(s.feeds); %convert structure 2 table
tz=datetime(T1.created_at,'inputformat','yyyy-MM-dd''T''HH:mm:ssXXX','timezone','Australia/Sydney');  %return UTC+11 in UTC time (no dst)                   
data1a.Timestamps=tz;       

[data2a,channelInfo2] = thingSpeakRead(readChannelID2,'Fields',1:8,...
                          'DateRange',dateRange,'outputformat','timetable');                        
api='http://api.thingspeak.com/channels/462618/feed.json?start=2019-02-01%2000:00:00&end=2019-02-09%2000:00:00&timezone=Australia%2FSydney';
s=webread(api);
T1=struct2table(s.feeds); %convert structure 2 table
tz=datetime(T1.created_at,'inputformat','yyyy-MM-dd''T''HH:mm:ssXXX','timezone','Australia/Sydney');  %return UTC+11 in UTC time (no dst)                   
data2a.Timestamps=tz;                       

%% combine sensor feeds
% data1i = retime(data1,'regular','linear','TimeStep',minutes(15));
% data2i = retime(data2,'regular','linear','TimeStep',minutes(15));
% datai=synchronize(data1i,data2i);


data=synchronize(data1a,data2a);
dif=diff(data.Timestamps);
difi=find(dif<seconds(60)); %if less than 60 seconds, count as 1 measurement


for j=difi'
    if all(ismissing(data(j,1:8)))
        data(j,1:8)=data(j+1,1:8);
    else
        data(j,9:16)=data(j+1,9:16);
    end
end
 data(difi+1,:)=[];
 atmos41data=data;
 
 save OAI_atmos41_feb1week atmos41data
%%  OoW data
[num,txt,raw]=xlsread('OW421198.csv');
VarNames=txt(3,2:2:14);
v2=matlab.lang.makeValidName(VarNames,'ReplacementStyle','delete');



time=datetime(txt(5:end,1),'inputformat','dd/MM/yyyy h:mm:ss a','timezone','Australia/Sydney');
time.TimeZone='UTC';

data=raw(5:end,2:2:14);
data=cell2mat(data);

OWdata=array2timetable(data,'RowTimes',time,'VariableNames',v2);


  save OW_OAI_AWS OWdata

%% BoM station data
dd=dir('bomdata\*.csv');
for d=1:length(dd)
    [num{d},txt{d},raw{d}]=xlsread(['bomdata\' dd(d).name]);
end


time=[];
for t=1:length(dd)
    t2=datetime(txt{1,t}(7:end,2),'inputformat','dd/MM/yyyy','timezone','Australia/Sydney');
    time=[time; t2];    
end
clear t2 t

VarNames=txt{1,1}(6,[3:6,11:15]);
v2=matlab.lang.makeValidName(VarNames,'ReplacementStyle','delete');


data=[];
for t=1:length(dd)
    t2=raw{1,t}(7:end,[3:6,11:15]);
    data=[data; t2];    
end

wind=nan(length(data),1);
%convert windstr to deg direction and convert calm to 0 %todo - check if
%this is valid
wind(strcmp('N',data(:,8)))=360;
wind(strcmp('NNE',data(:,8)))=25;
wind(strcmp('NE',data(:,8)))=45;
wind(strcmp('ENE',data(:,8)))=65;
wind(strcmp('E',data(:,8)))=90;
wind(strcmp('ESE',data(:,8)))=115;
wind(strcmp('SE',data(:,8)))=135;
wind(strcmp('SSE',data(:,8)))=155;
wind(strcmp('S',data(:,8)))=180;
wind(strcmp('SSW',data(:,8)))=205;
wind(strcmp('SW',data(:,8)))=225;
wind(strcmp('WSW',data(:,8)))=245;
wind(strcmp('W',data(:,8)))=270;
wind(strcmp('WNW',data(:,8)))=295;
wind(strcmp('NW',data(:,8)))=315;
wind(strcmp('NNW',data(:,8)))=335;
data(:,8)=num2cell(wind);


c=find(strcmp('Calm',data(:,9)));
data(c,9)=num2cell(0);




data=cell2mat(data);


BoMdata=array2timetable(data,'RowTimes',time,'VariableNames',v2);

save BoM_OAI_manual BoMdata

clearvars
load OW_OAI_AWS.mat
load OAI_atmos41.mat
load BoM_OAI_manual.mat


%% clean up missing vals
atmos41data.WindSpeedms(atmos41data.WindSpeedms<0)=NaN;
atmos41data.WindDirectiondeg(atmos41data.WindDirectiondeg<0)=NaN;
atmos41data.AtmosPressurekPa(atmos41data.AtmosPressurekPa==0)=NaN;
%% Daily Resample


atmos41data.Timestamps.TimeZone='Australia/Sydney';
OWdata.Time.TimeZone='Australia/Sydney';




T41sum=retime(atmos41data,'daily','sum');
T41mean=retime(atmos41data,'daily','mean');
T41min=retime(atmos41data,'daily','min');
T41max=retime(atmos41data,'daily','max');
% nansum returns 0 if all elements are NaN.  find aggregations where all
% elements are NaN and replace with NaN
allnan=retime(atmos41data,'daily',@(x) all(isnan(x)));
atmos41varnames=atmos41data.Properties.VariableNames;
for i=1:size(atmos41data,2)
    T41sum.(atmos41varnames{i})(allnan.(atmos41varnames{i}))=NaN;
    T41mean.(atmos41varnames{i})(allnan.(atmos41varnames{i}))=NaN;
    T41min.(atmos41varnames{i})(allnan.(atmos41varnames{i}))=NaN;
    T41max.(atmos41varnames{i})(allnan.(atmos41varnames{i}))=NaN;
end



TOWsum=retime(OWdata,'daily','sum');
TOWmean=retime(OWdata,'daily','mean');
TOWmin=retime(OWdata,'daily','min');
TOWmax=retime(OWdata,'daily','max');


TBoM=retime(BoMdata,T41sum.Timestamps);
TBoM.meanT = mean(TBoM{:,1:2},2);

%% hourly resample
T41sumh=retime(atmos41data,'hourly','sum');
T41meanh=retime(atmos41data,'hourly','mean');
T41minh=retime(atmos41data,'hourly','min');
T41maxh=retime(atmos41data,'hourly','max');
% nansum returns 0 if all elements are NaN.  find aggregations where all
% elements are NaN and replace with NaN
allnanh=retime(atmos41data,'hourly',@(x) all(isnan(x)));
for i=1:size(atmos41data,2)
    T41sumh.(atmos41varnames{i})(allnanh.(atmos41varnames{i}))=NaN;
    T41meanh.(atmos41varnames{i})(allnanh.(atmos41varnames{i}))=NaN;
    T41minh.(atmos41varnames{i})(allnanh.(atmos41varnames{i}))=NaN;
    T41maxh.(atmos41varnames{i})(allnanh.(atmos41varnames{i}))=NaN;
end
% 
figure
plot(T41minh.Timestamps, T41minh.AirTempdegC,T41maxh.Timestamps,T41maxh.AirTempdegC)
set(gca,'xlim',[datetime(2018,7,1,'timezone','UTC') datetime(2018,7,31,'timezone','UTC')])
% plot(T41min.Timestamps,T41max.AirTempdegC-T41min.AirTempdegC)

%%
Tows=sort(TOWmean.BaroPressurehPa);
T41s=sort(T41mean.AtmosPressurekPa*10);

figure
plot(Tows,T41s,'o');
% set(gca,'xlim',[0 25],'ylim',[0 25])
%%  Daily Mins and Max
% 

figure
subplot(1,2,1)
p1=histogram(T41min.AirTempdegC,20);
hold on
p2=histogram(TOWmin.AirTemperature,20);
p5=histogram(TBoM.MinimumTemperatureC,20);
legend('Atmos41','Office of Water','BoM')
% set(ph1,'facecolor','b')
title('Daily Minimum Temperatures')
subplot(1,2,2)
p3=histogram(T41max.AirTempdegC,20);
hold on
p4=histogram(TOWmax.AirTemperature,20);
p6=histogram(TBoM.MaximumTemperatureC,20);
legend('Atmos41','Office of Water','BoM')
% set(ph2,'facecolor','r')
title('Daily Maximum Temperatures')



figure
subplot(1,2,1)
p1=histogram(T41sum.Precipitationmm,20);
hold on
p2=histogram(TOWsum.Rainfallmm,20);
legend('Atmos41','Office of Water')
% set(ph1,'facecolor','b')
title('Daily Total Rainfall')
subplot(1,2,2)
p3=histogram(T41mean.AtmosPressurekPa*10,20);
hold on
p4=histogram(TOWmean.BaroPressurehPa,20);
legend('Atmos41','Office of Water')
% set(ph2,'facecolor','r')
title('Daily Mean Pressure')
%% Calculate Table statistics
%population means and SDs, min max,
%comparison statistics, r value, av error, etc.

%% Daily time series
% close all



figure('Position',[242          25        2076        1313])
subplot(4,2,1)
plot(TOWsum.Time,TOWsum.Rainfallmm,T41sum.Timestamps,T41sum.Precipitationmm,TBoM.Time, TBoM.Rainfallmm)
legend('Office of Water','Atmos41','BoM')
title('Daily Total Rainfall')
ylabel('Rainfall (mm)')

subplot(4,2,2)
plot(TOWmean.Time,TOWmean.GlobalRadWSqM,T41mean.Timestamps,T41mean.SolarRadiationWm2)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Radiation')
ylabel('Radiation (W/m^2)')

subplot(4,2,3)
plot(TOWmean.Time,TOWmean.AirTemperature,T41mean.Timestamps,T41mean.AirTempdegC,TBoM.Time,TBoM.meanT)
legend('Office of Water','Atmos41','BoM')
title('Office of Water vs Atmos41 Mean Daily Air Temp')
ylabel('Air Temp {\circ}C')

subplot(4,2,4)
plot(TOWmean.Time,TOWmean.BaroPressurehPa,T41mean.Timestamps,T41mean.AtmosPressurekPa*10)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Pressure')
ylabel('Pressure (hPa)')

subplot(4,2,5)
plot(TOWmean.Time,TOWmean.AvWindSpeedMs,T41mean.Timestamps,T41mean.WindSpeedms,TBoM.Time,TBoM.x9amWindSpeedkmh/3.6)
legend('Office of Water','Atmos41','BoM @9am')
title('Office of Water vs Atmos41 Mean Daily Wind speed')
ylabel('Wind speed (m/s)')

subplot(4,2,6)
plot(TOWmean.Time,TOWmean.WindDirDeg,T41mean.Timestamps,T41mean.WindDirectiondeg,TBoM.Time,TBoM.x9amWindDirection)
legend('Office of Water','Atmos41','BoM @9am')
title('Office of Water vs Atmos41 Mean Daily Wind Direction')
ylabel('Degrees')

subplot(4,2,7)
plot(TOWmean.Time,TOWmean.RelativeHumidity,T41mean.Timestamps,T41mean.RelHumidity,TBoM.Time,TBoM.x9amRelativeHumidity)
legend('Office of Water','Atmos41','BoM @9am')
title('Office of Water vs Atmos41 Mean Daily Relative Humidity')
ylabel('Relative Humidity (%)')


% print(gcf,'atmos41vOoWtimeseries','-dpng','-r100')


%% daily correlations
% close all

figure('Position',[498          38        1949        1300])
subplot(3,3,1)
scatter(TOWsum.Rainfallmm,T41sum.Precipitationmm)
title('Daily Total Rainfall (mm)')
hold on
%plot 1:1 line
x=0:30;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWsum.Rainfallmm,T41sum.Precipitationmm,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(8,18,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


subplot(3,3,2)
scatter(TOWmean.GlobalRadWSqM,T41mean.SolarRadiationWm2)
title('Daily Mean Solar Radiation (W/m^2)')
hold on
%plot 1:1 line
x=0:500;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.GlobalRadWSqM,T41mean.SolarRadiationWm2,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(200,150,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);



subplot(3,3,3)
scatter(TOWmean.AirTemperature,T41mean.AirTempdegC)
title('Daily Mean Air Temp ({\circ}C)')

hold on
%plot 1:1 line
x=0:30;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.AirTemperature,T41mean.AirTempdegC,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,15,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


subplot(3,3,4)
scatter(TOWmean.BaroPressurehPa,T41mean.AtmosPressurekPa*10)
title('Daily Mean Atmos Pressure (hPa)')

hold on
%plot 1:1 line
x=890:930;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.BaroPressurehPa,T41mean.AtmosPressurekPa*10,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(895,910,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);

subplot(3,3,5)
scatter(TOWmean.AvWindSpeedMs,T41mean.WindSpeedms)
title('Daily Mean Wind Speed (m/s)')

hold on
%plot 1:1 line
x=0:8;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.AvWindSpeedMs,T41mean.WindSpeedms,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(6,2,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);

subplot(3,3,6)
scatter(TOWmean.WindDirDeg,T41mean.WindDirectiondeg)
title('Daily Mean Wind Dir (degrees)')

hold on
%plot 1:1 line
x=0:360;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.WindDirDeg,T41mean.WindDirectiondeg,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,150,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
set(gca,'xlim',[ 0 360],'ylim',[ 0 360]);

subplot(3,3,7)
scatter(TOWmean.RelativeHumidity,T41mean.RelHumidity)
title('Relative Humidity (%)')

hold on
%plot 1:1 line
x=0:100;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.RelativeHumidity,T41mean.RelHumidity,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,15,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


print(gcf,'atmos41vOoW_correlation','-dpng','-r100')

%% daily correlations w BoM
% close all

figure('Position',[498          38        1949        1300])
subplot(3,3,1)
s1=scatter(T41sum.Precipitationmm,TOWsum.Rainfallmm,'filled');
hold on
s2=scatter(T41sum.Precipitationmm,TBoM.Rainfallmm,'filled');
title('Daily Total Rainfall (mm)')
hold on
%plot 1:1 line
x=0:30;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWsum.Rainfallmm,T41sum.Precipitationmm,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(8,18,string,'fontsize',16,'color',[0 0.4470 0.7410])

% ylabel('OoW and BoM')
ylabel(['{\color[rgb]{0 0.4470 0.7410}OoW','\color{black} and ', '\color[rgb]{0.8500 0.3250 0.0980}BoM}'],'fontweight','bold')

xlabel('Atmos41')
set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


subplot(3,3,2)
scatter(T41mean.SolarRadiationWm2,TOWmean.GlobalRadWSqM)
title('Daily Mean Solar Radiation (W/m^2)')
hold on
%plot 1:1 line
x=0:500;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.GlobalRadWSqM,T41mean.SolarRadiationWm2,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(200,150,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);



subplot(3,3,3)
scatter(T41mean.AirTempdegC,TOWmean.AirTemperature)
title('Daily Mean Air Temp ({\circ}C)')

hold on
%plot 1:1 line
x=0:30;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.AirTemperature,T41mean.AirTempdegC,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,15,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


subplot(3,3,4)
scatter(TOWmean.BaroPressurehPa,T41mean.AtmosPressurekPa*10)
title('Daily Mean Atmos Pressure (hPa)')

hold on
%plot 1:1 line
x=890:930;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.BaroPressurehPa,T41mean.AtmosPressurekPa*10,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(895,910,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);

subplot(3,3,5)
scatter(TOWmean.AvWindSpeedMs,T41mean.WindSpeedms)
title('Daily Mean Wind Speed (m/s)')

hold on
%plot 1:1 line
x=0:8;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.AvWindSpeedMs,T41mean.WindSpeedms,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(6,2,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);

subplot(3,3,6)
scatter(TOWmean.WindDirDeg,T41mean.WindDirectiondeg)
title('Daily Mean Wind Dir (degrees)')

hold on
%plot 1:1 line
x=0:360;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.WindDirDeg,T41mean.WindDirectiondeg,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,150,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
set(gca,'xlim',[ 0 360],'ylim',[ 0 360]);

subplot(3,3,7)
scatter(TOWmean.RelativeHumidity,T41mean.RelHumidity)
title('Relative Humidity (%)')

hold on
%plot 1:1 line
x=0:100;
y=x;
plot(x,y,'k','linewidth',2);
text(max(x),max(y),'1:1 line','fontsize',12)

%calculate r value
[r,pv]=corrcoef(TOWmean.RelativeHumidity,T41mean.RelHumidity,'rows','complete');
Y = sprintf('%.2f',r(1,2));
string=['r=' Y];
% string2=['p<' num2str(pv(1,2))];
text(20,15,string,'fontsize',16)

xlabel('OoW')
ylabel('Atmos41')
% set(gca,'xlim',[ 0 30],'ylim',[ 0 30]);


%% raw time series



figure('Position',[242          25        2076        1313])
a1=subplot(4,2,1);
plot(OWdata.Time,OWdata.Rainfallmm,atmos41data.Timestamps,atmos41data.Precipitationmm)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Daily Total Rainfall')
ylabel('Rainfall (mm)')

a2=subplot(4,2,2);
plot(OWdata.Time,OWdata.GlobalRadWSqM,atmos41data.Timestamps,atmos41data.SolarRadiationWm2)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Radiation')
ylabel('Radiation (W/m^2)')

a3=subplot(4,2,3);
plot(OWdata.Time,OWdata.AirTemperature,atmos41data.Timestamps,atmos41data.AirTempdegC)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Air Temp')
ylabel('Air Temp {\circ}C')

a4=subplot(4,2,4);
plot(OWdata.Time,OWdata.BaroPressurehPa,atmos41data.Timestamps,atmos41data.AtmosPressurekPa*10)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Pressure')
ylabel('Pressure (hPa)')

a5=subplot(4,2,5);
plot(OWdata.Time,OWdata.AvWindSpeedMs,atmos41data.Timestamps,atmos41data.WindSpeedms)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Wind speed')
ylabel('Wind speed (m/s)')

a6=subplot(4,2,6);
plot(OWdata.Time,OWdata.WindDirDeg,atmos41data.Timestamps,atmos41data.WindDirectiondeg)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Wind Direction')
ylabel('Degrees')

a7=subplot(4,2,7);
plot(OWdata.Time,OWdata.RelativeHumidity,atmos41data.Timestamps,atmos41data.RelHumidity)
legend('Office of Water','Atmos41')
title('Office of Water vs Atmos41 Mean Daily Relative Humidity')
ylabel('Relative Humidity (%)')




linkaxes([a1 a2 a3 a4 a5 a6 a7], 'x')
% set(gca,'xlim',[datetime(2018,7,1,'timezone','UTC') datetime(2018,8,30,'timezone','UTC')])

% print(gcf,'atmos41vOoWtimeseries_noresampling','-dpng','-r100')


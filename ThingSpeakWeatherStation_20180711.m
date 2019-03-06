% ThingSpeak Weather Station Data Analysis
%
% This script includes examples of reading data from ThingSpeak channel and
% performing various kind of visualization on the data. 
%
% Retrieve the data first (see the first section) before executing other sections. 
%
% ThingSpeak Support Toolbox on File Exchange is required to run this script.
% It can be downloaded here:
% http://www.mathworks.com/matlabcentral/fileexchange/52244-thingspeak-support-toolbox
%
% Copyright 2016 The MathWorks, Inc.


%% Retrieve data from ThingSpeak channel
startDate = 'June 1, 2018';
endDate = 'June 30, 2018';

% Channel ID to read data from
readChannelID = 456671;
% Specify date range
dateRange = [datetime(startDate),datetime(endDate)];
% Read data including the timestamp, and channel information.
[data,time,channelInfo] = thingSpeakRead(readChannelID,'Fields',1:8,...
                          'DateRange',dateRange);                    
% Create variables to store different sorts of data
rainData = data(:,2);
windSpeedData = data(:,5);
windDirectionData = data(:,6);
windGustData = data(:,7);
temperatureData = data(:,8);

% Channel ID to read data from
readChannelID = 456672;
% Specify date range
dateRange = [datetime(startDate),datetime(endDate)];
% Read data including the timestamp, and channel information.
[data,time,channelInfo] = thingSpeakRead(readChannelID,'Fields',1:2,...
                          'DateRange',dateRange);                    
% Create variables to store different sorts of data

pressureData = data(:,1);
humidityData = data(:,2);

%% Temperature, Humidity, Pressure, Rain, WindSpeed, WindDirection histogram

% Create a figure to display plots
figure

% Temperature histogram
subplot(2,3,1) % Create 2-by-3 axis on the same figure, and work on the first axis
histogram(temperatureData);
title(channelInfo.FieldDescriptions{1});
grid on

% Humidity histogram
subplot(2,3,2)
histogram(humidityData);
title(channelInfo.FieldDescriptions{2});
grid on

% Pressure histogram
subplot(2,3,3)
histogram(pressureData);
title(channelInfo.FieldDescriptions{3});
grid on

% Rain fall histogram
subplot(2,3,4)
histogram(rainData);
title(channelInfo.FieldDescriptions{4});
grid on

% WindSpeed histogram
subplot(2,3,5)
histogram(windSpeedData);
title(channelInfo.FieldDescriptions{5});
grid on

% Wind Direction histogram
rad = windDirectionData*pi/180; % Convert to radians
rad = -rad+pi/2; % Adjust the wind direction data to match map compass, such that North is equal to 0 degree
subplot(2,3,6)
rose(rad,12) % Plot the wind direction histogram in a polar axis 
title(channelInfo.FieldDescriptions{7})
ax = gca;
ax.View = [-90 90]; % Rotate axis 90 degrees counterclock-wise such that North is equal to 0 degree


%% Smooth Temperature and Trend

% Remove missing data from the temperature variable, in order to perform
% the fitting methods
idx = ~isnan(temperatureData);
rawTemp = temperatureData(idx);
newTime = time(idx);

% Smooth the raw temperature data with local 60-point mean values
smoothTemp = movmean(temperatureData(idx),60);

% Fit the data for a trend line
[p,~,mu]= polyfit(datenum(newTime),rawTemp,1);
trend = polyval(p,datenum(newTime),[],mu);

% Optional: fit the data by using the sum of eight sine functions
% To use the fit function, the Curve Fitting Toolbox is required.
% It can be downloaded here: http://www.mathworks.com/products/curvefitting/
f = fit(datenum(newTime),rawTemp,'sin8');

% Plot the raw data, smooth data, trend and fitting curve
figure
hold on
plot(newTime,rawTemp,'b') % Plot the raw temperature 
plot(newTime,smoothTemp,'g','LineWidth',1.5) % Plot the smoothing curve
plot(newTime,trend,'m','LineWidth',2) % Plot the trend line
plot(f) % Plot the fitting curve
hold off
xlim([datenum(time(1)) datenum(time(end))]) % Adjust the x-axis to properly display the curves
xlabel('Date')
ylabel('Temperature (F)')
legend({'Raw Data','Smooth Data','Trend','Fitting Curve'},'Location','NE')


%% Daily Temperature Statistics

% Remove missing data
idx = ~isnan(temperatureData);
rawTemp = temperatureData(idx);
newTime = time(idx);

% Plot temperature for each day. 
figure
hold on
% Use dateshift and findgroups functions to bin the temperature data in
% terms of individual day
timeShift = dateshift(newTime,'start','day'); % Shift hour, minute, and second to the start of each day, i.e. 00:00:00
dayGroup = findgroups(timeShift); % Group the shifted time in terms of day
splitapply(@plot,second(newTime,'secondofday')/3600,rawTemp,dayGroup); % Apply the plot function to the temperature for each day by using the group defined above

% Compute the absolute Max, Min, and Mean for each hour 
hourGroup = findgroups(hour(newTime)); % Create a vector of grouping number for each hour
tMax = splitapply(@max,rawTemp,hourGroup); % Calculate the max for each hour
tMin = splitapply(@min,rawTemp,hourGroup); % Calculate the min for each hour
tMean = splitapply(@mean,rawTemp,hourGroup); % Calculate the mean for each hour

% Prepare x and y data for the average and the variation area
xHalf = [0,repelem(1:23,2),24]; % x coordinate at the end points for each interval (each hour)
x = [xHalf, fliplr(xHalf)]; % x coordinate for variation area (including both bottom and top profiles)
tMax = repelem(tMax,2); % y coordinate for max per hour
tMin = repelem(tMin,2); % y coordinate for min per hour
tMean = repelem(tMean,2);% y coordinate for mean per hour
y = [tMin; flipud(tMax)]; % y coordinate for variation area (bottom and top)

% Plot Statistics
plot([0,24], [max(tMax),max(tMax)],'.--k', 'LineWidth',1.5) % Plot global Max as a horizontal line
plot([0,24], [min(tMin),min(tMin)],'.--k', 'LineWidth',1.5) % Plot global Min as a horizontal line
h1 = fill(x,y, 'b', 'LineStyle', 'none', 'FaceAlpha', 0.1); % Highlight the variation area per hour
h2 = plot(xHalf,tMean,'--','LineWidth',2); % Plot average per hour
hold off
title('Daily temperature over the past week')
ylabel('Temperature (F)')
xlabel('Day Time')
axis tight % Adjust axis to fit the plot
ylim([20 80]) % Adjust to allow space on the top and at the bottom of the axis
ax = gca; % Get the current axis object
ax.XTick = 1:24; % Change the X-Tick to 24 hours 
legend([h1,h2],'Variation per hour','Average per hour')


%% Compare with historical temperature data on March 7, 2011-2015

% Load historical data
rawData = load('March7'); % Load the data file named "March7" in the current folder.
rawData = struct2cell(rawData); % Convert the structure rawData to cell, which allows numeric indexing without knowing the field name.

% Calculate hourly Max, Min, and Mean for historical data
m = zeros(24,length(rawData)); % Pre-allocate matrix
for i = 1:length(rawData) % Loop over all years (2011-2015)
    histData = rawData{i}; % Get the temperature data for the i-th year
    hourGroup = findgroups(hour(histData.TimeEST)); % Group for each hour
    m(:,i) = splitapply(@mean,histData.TemperatureF,hourGroup); % Calculate the average temperature for each hour
end
histMax = max(m,[],2); % Max per hour
histMin = min(m,[],2); % Min per hour
histMean = mean(m,2); % Mean per hour

% Temperature on March 7,2016 per hour
temp = temperatureData(month(time)==3 & day(time)==7);
s = second(time(month(time)==3 & day(time)==7),'secondofday'); % Coresponding time slot in seconds
s = s/3600; % Convert to hours

% Plot
figure
% In the first subplot, show the historical temperatures for each year
subplot(2,1,1) 
plot(m, 'LineWidth',2)
title('Daily Temperature on March 7, 2011-2015')
ylabel('Temperature (F)')
legend({'2011','2012', '2013', '2014','2015'})
ax = gca;
ax.XTick = 1:24; % Change the X-Tick to 24 hours
% In the second subplot, compare the current temperature with historical data
subplot(2,1,2) 
hold on
plot(s,temp,'g', 'LineWidth',2) % Plot temperature on March 7, 2016
plot(histMax,'--','LineWidth',2) % Plot historical max
plot(histMin,'--','LineWidth',2) % Plot historical min
plot(histMean,'--','LineWidth',2) % Plot historical mean
hold off
title('Daily Temperature on March 7 - Current v.s. History')
ylabel('Temperature (F)')
legend({'March 7, 2016','Historical Max', 'Historical Min', 'Historical Mean'})
ax = gca;
ax.XTick = 1:24; % Change the X-Tick to 24 hours 


%% Temperature and Humidity 3D bar charts

% Create a day range vector
dayRange = day(dateRange(1):dateRange(2));
% Pre-allocate matrix
weatherData = zeros(length(dayRange),24);

% Generate temperature 3D bar chart
% Get temperature per whole clock for each day
for m = 1:length(dayRange) % Loop over all days
    for n = 1:24 % Loop over 24 hours
        if any(day(time)==dayRange(m) & hour(time)==n); % Check if data exist for this specific time
            hourlyData = temperatureData((day(time)==dayRange(m) & hour(time)==n)); % Pull out the hourly temperature from the matrix
            weatherData(m,n) = hourlyData(1); % Assign the temperature at the time closest to the whole clock
        end
    end
end

% Plot
figure
h = bar3(datenum(dateRange(1):dateRange(2)), weatherData);
for k = 1:length(h) % Change the face color for each bar
    h(k).CData = h(k).ZData;
    h(k).FaceColor = 'interp';
end
title('Temperature Distribution')
xlabel('Hour of Day')
ylabel('Date')
datetick('y','mmm dd') % Change the Y-Tick to display specified date format 
ax = gca;
ax.XTick = 1:24; % Change the X-Tick to 24 hours 
ax.YTickLabelRotation = 30; % Rotate label for better display
colorbar % Add a color bar to indicate the scaling of color


% Generate humidity 3D bar chart
% Get humidity per whole clock for each day
for m = 1:length(dayRange) % Loop over all days
    for n = 1:24 % Loop over 24 hours
        if any(day(time)==dayRange(m) & hour(time)==n); % Check if data exist for this specific time
            hourlyData = humidityData((day(time)==dayRange(m) & hour(time)==n)); % Pull out the hourly humidity from the matrix
            weatherData(m,n) = hourlyData(1); % Assign the humidity at the time closest to the whole clock
        end
    end
end

% Plot
figure
h = bar3(datenum(dateRange(1):dateRange(2)), weatherData);
for k = 1:length(h) % Change the face color for each bar
    h(k).CData = h(k).ZData;
    h(k).FaceColor = 'interp';
end
title('Humidity Distribution')
xlabel('Hour of Day')
ylabel('Date')
datetick('y','mmm dd') % Change the Y-Tick to display specified date format 
ax = gca;
ax.XTick = 1:24; % Change the X-Tick to 24 hours 
ax.YTickLabelRotation = 30; % Rotate label for better display
colorbar % Add a color bar to indicate the scaling of color


%% Interpolation and contour for Temperature, Humidity and Pressure

% Replace missing data by interpolation, rather than removing the missing
% data directly from the variable. This allows to keep the dimension of the
% array being consistent
xNew = linspace(1,size(data,1),100)'; % Create new x coordinates
tNew = interp1(temperatureData(~isnan(temperatureData)),xNew,'linear','extrap'); % Temperature interpolation. Extrapolation is applied here in case that the last entry is NaN.
hNew = interp1(humidityData(~isnan(humidityData)),xNew,'linear','extrap'); % Humidity interpolation
pNew = interp1(pressureData(~isnan(pressureData)),xNew,'linear','extrap'); % Pressure interpolation

% Find the index of the max pressure
[pMax,idx] = max(pNew);

% Create surface fitting data
sf = fit([tNew,hNew],pNew,'linearinterp');

% Plot
figure
hsf = plot(sf,[tNew,hNew],pNew); % Plot the surface with nodes. This plot function is provided in Curve Fitting Toolbox. The output is an array of a surface object and a line object.
hsf(1).EdgeColor = 'interp'; % Change face edge color of the surface
hsf(1).FaceAlpha = 0.5; % Change the transparency of the surface
xlabel('Temperature')
ylabel('Humidity')
zlabel('Pressure')
title('Linear Interpolation Surface')

% 2D View with the location of max pressure
figure
hsf = plot(sf); % Plot the surface only
hsf.EdgeColor = 'interp'; % Change face edge color
hold on
plot3(tNew(idx),hNew(idx),pMax,'r.', 'MarkerSize',30) % Plot the location of max pressure
text(tNew(idx)+2,hNew(idx)+2,pMax,['P= ',num2str(pMax),', T=',...
    num2str(tNew(idx)),', H=',num2str(hNew(idx))]) % Display the values at the location above
title('Contour of the Pressure')
xlabel('Temperature')
ylabel('Humidity')
grid off
view(2) % Set the view to 2D, i.e., observing the plot from top to bottom along z-axis
hold off


%% Dew Point

% Convert temperature from Fahrenheit to Celsius
tempC = (5/9)*(temperatureData-32);

% Calculate dew point. Refer to Wiki (https://en.wikipedia.org/wiki/Dew_point) for the formula and more details  
% Specify the constants for water vapor (b) and barometric (c) pressure.
b = 17.67;
c = 243.5;
% Calculate the intermediate value 'gamma'
gamma = log(humidityData/100) + b*tempC ./ (c+tempC);
% Calculate dew point in Celsius
dewPoint = c*gamma ./ (b-gamma);

% Convert to dew point in Fahrenheit
dewPointF = (dewPoint*1.8) + 32;

% Plot
figure
hold on
plot(time, dewPointF,'d') % Plot dew points
xlabel('Time')
ylabel('Dew Point')
xlim([datenum(time(1)) datenum(time(end))]) % Adjust the x-axis limits
fill([xlim fliplr(xlim)], [68 68 80 80], 'r', 'LineStyle', 'none', 'FaceAlpha', 0.1) % Highlight the uncomfortable zone
text(0.7*datenum(time(1)) + 0.3*datenum(time(end)), 75, 'Uncomfortable', 'FontWeight','bold') % Add text for the zone
fill([xlim fliplr(xlim)], [50 50 68 68], 'g', 'LineStyle', 'none', 'FaceAlpha', 0.1) % Highlight the comfortable zone
text(0.7*datenum(time(1)) + 0.3*datenum(time(end)), 60, 'Comfortable', 'FontWeight','bold') % Add text for the zone
fill([xlim fliplr(xlim)], [min(ylim) min(ylim) 50 50], 'y', 'LineStyle', 'none', 'FaceAlpha', 0.1) % Highlight the dry zone
text(0.65*datenum(time(1)) + 0.35*datenum(time(end)), 20, 'Dry', 'FontWeight','bold') % Add text for the zone
hold off


%% Wind Compass and Feather

% Specify the latest n+1 wind directions to be displayed
n = 9;

% Convert to radians
rad = windDirectionData*pi/180;

% Create a feather plot
% Remove missing data and any wind speed with value 0 
idx = (~isnan(rad)) & (~isnan(windSpeedData)) & (windSpeedData~=0);
% Convert polar coordinates to Cartesian. Note that dividing by the maximum
% wind speed allows to scale the length of each arrow by its relative wind
% speed, rather than the wind direction.
[x,y] = pol2cart(rad(idx),windSpeedData(idx)/max(windSpeedData(idx)));
% Plot
figure
subplot(2,1,2)
feather(x((end-n):end),y((end-n):end)) % Plot the feather
xlim([0 n+2]) % Adjust the x-axis
ylim([-1 1]) % Adjust the y-axis
xlabel(['The last ',num2str(n+1),' wind direction']) % Add x lable
title('Wind Direction Changes')
grid on
ax = gca;
ax.YTickLabel = {}; % Hide the Y-Tick
ax.XTick = 1:(n+1); % Adjust the X-Tick for n+1 data

% Create a compass plot
% Adjust the wind direction to match map compass, such that North is equal to 0 degree
rad = -rad+pi/2;
% Calculate the cosine component
u = cos(rad) .* windSpeedData; % x coordinate of wind speed on circular plot
% Calculate the sine component
v = sin(rad) .* windSpeedData; % y coordinate of wind speed on circular plot
% Plot
subplot(2,1,1)
compass(u((end-n):end),v((end-n):end)) % Plot compass
title('Wind Compass')
ax = gca;
ax.View = [-90 90]; % Rotate axis 90 degrees counterclock-wise such that North is equal to 0 degree


%% Instant Weather Flag

% Convert to radians
theta = windDirectionData(end)*pi/180;

% Covert wind speed to a relative angle of the wind flag with z axis, by
% assuming the max wind speed is 5mph.
maxWindSpeed = 5;
speedAngle = pi/2*windSpeedData(end)/maxWindSpeed;
ytheta = pi-speedAngle;

% Create the cone as a flag
% Specify the radius of the cone
ConeRadius = 0.1;
% Create coordinate limits and rotation matrix
xMax = 1.5;
xMin = -xMax;
yMax = 1.5;
yMin = -yMax;
zMax = 1.5;
zMin = -0.5;
yRotate = [cos(ytheta) 0 sin(ytheta); 
           0 1 0;
           -sin(ytheta) 0 cos(ytheta)];
zRotate = [cos(theta) -sin(theta) 0;
           sin(theta) cos(theta) 0;
           0 0 1];
% Create the cone surface data
t = [0;ConeRadius];
[X,Y,Z]=cylinder(t,50);
% Adjust the direction of the cone flag such that the cone is pointing down
% along z-axis
XYZ = zRotate*(yRotate*[X(2,:);Y(2,:);Z(2,:)]);
X(2,:) = XYZ(1,:); % Pull out x coordinate of the cone
Y(2,:) = XYZ(2,:); % Pull out y coordinate of the cone
Z(2,:) = XYZ(3,:); % Pull out z coordinate of the cone
Z = Z + zMax; % Raise the flag to the top of the post

% Plot 
figure
c = jet; % Define the colormap

% Plot the cone and use the instant temperature data to display its color
h = surf(X,Y,Z,'FaceColor', c(round(temperatureData(end)/100*64),:),...
    'LineStyle','none','FaceAlpha',0.8,'FaceLighting','gouraud');
% Add lights to adjust the color of the cone
light('Position',[xMin 0 0],'Color',c(round(temperatureData(end)/100*64),:))
light('Position',[xMax 0 0],'Color',c(round(temperatureData(end)/100*64),:))
light('Position',[0 yMax 0],'Color',c(round(temperatureData(end)/100*64),:))
light('Position',[0 yMin 0],'Color',c(round(temperatureData(end)/100*64),:))

% Plot directions and the vertical post
hold on
plot3(0,0,zMax,'k.', 'MarkerSize',25) % Post
plot3([0 0],[0 0],[0 zMax],'k','LineWidth',3) % Top node of the post
plot3([xMin xMax],[0 0],[0 0],'k') % WE directions
plot3([0 0],[yMin yMax],[0 0],'k') % NS directions

% Plot auxiliary projection to help identify the direction where the flag
% points to
plot3([cos(theta)*sin(speedAngle) cos(theta)*sin(speedAngle)],...
        [0 sin(theta)*sin(speedAngle)],[0 0],'k--')
plot3([0 cos(theta)*sin(speedAngle)],[sin(theta)*sin(speedAngle) sin(theta)*sin(speedAngle)],[0 0],'k--')
plot3([cos(theta)*sin(speedAngle) cos(theta)*sin(speedAngle)],...
    [sin(theta)*sin(speedAngle) sin(theta)*sin(speedAngle)],[0 zMax-cos(speedAngle)],'k--')
hold off

% Add direction letters, color and annotations
text([0,0,xMax,xMin,0], [yMax,yMin,0,0,0], [0.05,0,0,-0.05,zMax+0.15],...
    {'N','S','E','W',['Wind Speed = ',num2str(round(windSpeedData(end),1)),'mph']})
colormap('jet')
cb = colorbar; % Get the colorbar object
colorbar('Ticks',linspace(cb.Limits(1), cb.Limits(2),6),...
         'TickLabels',{'Freeze','Cold','Cool','Neutral','Warm','Hot'}) % Label the color bar in terms of the human feeling about the temperature
title('Weather Flag')
axis equal
axis off

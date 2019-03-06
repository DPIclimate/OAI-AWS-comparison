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
[data,time,channelInfo] = thingSpeakRead(readChannelID,'Fields',2:7,...
                          'DateRange',dateRange);                    
% Create variables to store different sorts of data
rainData = data(:,2);
windSpeedData = data(:,5);
windDirectionData = data(:,6);
%windGustData = data(:,7);


%% Wind Compass and Feather

% Specify the latest n+1 wind directions to be displayed
n = 30;

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

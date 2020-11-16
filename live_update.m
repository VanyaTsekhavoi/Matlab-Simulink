function live_update
%Global variables 
sampleLength = 1/12500;
mouseClick = 1;

% Create data and 2-by-2 tiled chart layout
t = tiledlayout('flow');
fig = t.Parent;

%----------------------Callback set----------------------------------------

set(fig,'WindowButtonDownFcn',@mouseDownCallback)

% Top left plot
aaa = nexttile;
angle = plot(aaa,1);
title('Angle Plot')
ylabel('rad')
angle.Color = 'g'; 

% Top right plot
nexttile;
velocity = plot(1);
title('Velocity Plot')
ylabel('rad/s')
velocity.Color = 'm';

% Bottom left plot
nexttile;
current =  plot(1);
title('Current Plot')
ylabel('A')
current.Color = 'r';

t.TileSpacing = 'compact';
t.Padding = 'normal';
%{%}

%Data extract--------------------------------------------------------------

fid = fopen('~/Documents/Projects/File', 'r'); %file with statistic
if fid == -1
    error('File is not opened');
end

O = fread(fid,630546,'uint8=>float','l');

f = find(O == 255,26);
A = O(f(end):end);
A = A(1:(length(A) - mod(length(A),21)));

A = reshape(A,21, [])';

for l=2:4:21
    A(:,l) = A(:,l)*2^12 + A(:,l+1)*2^8 + A(:,l+2)*2^4 + A(:,l+3);
end


CurrentSensor = (A(:,2)' - 2077) * 0.00653;
CurrentSensor2 = smooth(CurrentSensor, 5001,'sgolay',9).';
InputVoltage = A(:,6)' * 0,004833984; % 0.000805664 * 6

Angle = (A(:,10)' - 32767)./ 10;
Velocity = (A(:,14)' - 32767)./ 10;

Velocity2 = smooth(Velocity, 1501,'sgolay',9).';
Velocity3 = Velocity2(1:end) * 0.05 + [0 Velocity2(2:end)] * 0.95;
Cycles = A(:,18)';

%Cumsum of t
dataLength = 0;
time = cumsum(Cycles);


%Initial values------------------------------------------------------------

%Angle   
angle.XData = [0];  
angle.YData = [0];
    
%Velocity
velocity.XData = [0]; 
velocity.YData = [0];
        
%Current
current.XData = [0];
current.YData = [0];


%--------------------- Infinite loop GUI-----------------------------------

while (ishandle(aaa) && ishandle(velocity) && ishandle(current))
    
    if mouseClick == 0
        drawnow limitrate
        continue
    end
    
    try
        
    %-----------------------drawing----------------------------------------
    
    %Angle
    angle.YData = [angle.YData(1+dataLength : end) Angle];
    angle.XData = [angle.XData(1+dataLength : end) time];
    
    %Velocity
    velocity.YData = [velocity.YData(1+dataLength : end) Velocity3];
    velocity.XData = [velocity.XData(1+dataLength : end) time];
    
    %Current
    current.YData = [current.YData(1+dataLength : end) CurrentSensor2];
    current.XData = [current.XData(1+dataLength : end) time];
    
    drawnow %limitrate
    %pause(1/1000);
    
    %----------------------computing---------------------------------------    
    
    O = fread(fid,1050,'uint8=>float','l');

    f = find(O == 255,1);
    A = O(f(end):end);
    A = A(1:(length(A) - mod(length(A),21)));

    A = reshape(A,21, [])';

    for l=2:4:21
        A(:,l) = A(:,l)*2^12 + A(:,l+1)*2^8 + A(:,l+2)*2^4 + A(:,l+3);
    end

    CurrentSensor = (A(:,2)' - 2077) * 0.00653;
    CurrentSensor2 = smooth(CurrentSensor, 105,'sgolay',9).';
    InputVoltage = A(:,6)' * 0,004833984; % 0.000805664 * 6
    Angle = (A(:,10)' - 32767)./ 10;
    Velocity = (A(:,14)' - 32767)./ 10;
    Velocity2 = smooth(Velocity, 210,'sgolay',3).';
    Velocity3 = Velocity2(1:end) * 0.1 + [0 Velocity2(1:end-1)] * 0.9;
    Cycles = A(:,18)';
    time = cumsum(Cycles) + angle.XData(end);
        
    dataLength = length(Cycles);
    
    catch err
        fclose(fid);
    end
end %-------------------end of whole---------------------------------------

%-------------------------callback-----------------------------------------    

function mouseDownCallback(objectHandle, eventData)
    mouseClick = rem(mouseClick + 1, 2)
end

end




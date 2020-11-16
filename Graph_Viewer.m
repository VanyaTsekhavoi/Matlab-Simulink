function Graph_Viewer

sampleLength = 1/12500;


fid = fopen('~/Documents/Projects/Matlab-Simulink/ReqFile','r'); %file with statistic
if fid == -1
    error('File is not opened');
end

%ASCII transmission
%{
A = fscanf(fid, '%d %d %d %d %d');

dataLength = length(A) / 5;
A = reshape(A,5, [])';

CurrentSensor = (A(:,1)' - 2047) * 0.00653;
InputVoltage = A(:,2)' * 0.003222656; % 0.000805664 * 4
CosOut = A(:,3)' - 2076;
SinOut = A(:,4)' - 2048;
Cycles = A(:,5)';
%}


%{
%massiv


fid2 = fopen('~/Documents/Projects/File','r'); %MATLAB/every_s', 'r'); %file with statistic
if fid2 == -1
    error('File is not opened');
end

L = fread(fid2,Inf,'uint16','l');
R = reshape(L,3, [])';
C = R(:,1)' - 2076;
S = R(:,2)' - 2048;
V = (R(:,3)' - 32767)./ 10;

figure 
plot(C);
hold on
plot(S);
hold on
plot(V);
hold off
%-------------------------continue-----------------------------------------

%}

%Bytes in Memory transmission 

O = fread(fid,Inf,'uint8=>double','l');

f = find(O == 255,44);

A = O(f(end):end);
A = A(1:(length(A) - mod(length(A),21)));

A = reshape(A,21, [])';

for l=2:4:21
    A(:,l) = A(:,l)*2^12 + A(:,l+1)*2^8 + A(:,l+2)*2^4 + A(:,l+3);
end
    
dataLength = length(A);

%---------------------instant Characteristics------------------------------

CurrentSensor = (A(:,2)' - 32767)./ 10000;            % - 2067.5) * 0.00653;
InputVoltage = (A(:,6)' - 32767)./ 1000;             % * 00,004833984; % 0.000805664 * 6
Angle = (A(:,10)' - 32767)./ 10;
Velocity = (A(:,14)' - 32767)./ 100;
Cycles = A(:,18)';

%--------------------------------------------------------------------------

%---------------------Required Characteristics-----------------------------
CurrentSensor = (A(:,2)' - 32767)./ 10000;
ReqAngle = (A(:,6)' - 32767)./ 10;
ReqVelocity = (A(:,10)' - 32767)./ 100;
ReqAcceleration = (A(:,14)' - 32767)./ 100;
Cycles = A(:,18)';
%{%}

for l = 1:length(ReqAcceleration)
    if ReqAcceleration(l) > 50
        ReqAcceleration(l) = 50;
    end
    if ReqAcceleration(l) < -50
        ReqAcceleration(l) = -50;
    end
end
t = 1:dataLength;

figure('Name','Cycles')
plot(t,Cycles);
%plot(CosOut,SinOut,'g');

%qx = mean((CosOut))
%wx = mean(SinOut)
%aa = mean(SinOut-CosOut)

%figure шум производной
%plot(t,[0,diff(CurrentSensor)]/sampleLength,'g');


CurrentSensor2 = smooth(CurrentSensor, 5001,'sgolay',9).';
x = mean(CurrentSensor)

figure('Name','Current')
%AA = (A-2048) * 0.004355;
plot(t,CurrentSensor2,'b');
hold on;
plot(t,CurrentSensor,'r');
hold off;

InputVoltage2 = smooth(InputVoltage, 5001,'sgolay',9).';

figure('Name','Voltage')
hold on;
plot(t,InputVoltage2,'r');
hold on;
plot(t,InputVoltage,'g');
hold off;

UNwrap = Angle;

figure('Name','Angle')
hold on;
plot(t,UNwrap,'r');
hold off


%Производная по времени угла ----------------------------------------------

Velocity4 = smooth(Velocity, 1501,'sgolay',1).';% = Velocity;%

figure('Name','Velocity')
%
%plot(t, Velocity3);
hold on;
plot (t,Velocity,'m')
hold on
%plot(t, ReqAcceleration, 'g')
hold off;

fclose(fid);

%--------------------Position and Velocity error---------------------------

positionError = (A(:,2)' - 32767)./ 1000;
velocityError = (A(:,6)' - 32767)./ 1000;

figure('Name','Error Position')
plot(t, positionError, 'r');

figure('Name','Error Velocity')
plot(t, velocityError, 'g');

%------------------------Computing for model-------------------------------

FFCurrent = repelem(((ReqAcceleration .* 0.0000875 + 0.00063125) ./ 0.0175), Cycles);   %(((A(:,6)' - 32767)./ 10) .* 0.0000875 + 0.00063125) ./ 0.0175;
FFAngle = repelem(ReqAngle,Cycles);
FFVelocity = repelem(ReqVelocity,Cycles);
FFLength = length(FFCurrent);

%--------------------------------------------------------------------------

save('Variables.mat','Velocity','UNwrap','CurrentSensor','t','sampleLength','InputVoltage')
save('Simulink.mat','FFVelocity','FFAngle','FFCurrent','FFLength','Cycles','sampleLength')
end
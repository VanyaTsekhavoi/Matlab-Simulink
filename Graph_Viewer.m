function Graph_Viewer

sampleLength = 1/12500;


fid = fopen('~/Documents/Projects/File', 'r'); %file with statistic
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

O = fread(fid,Inf,'uint8=>float','l');

f = find(O == 255,26);

A = O(f(end):end);
A = A(1:(length(A) - mod(length(A),21)));

A = reshape(A,21, [])';

for l=2:4:21
    A(:,l) = A(:,l)*2^12 + A(:,l+1)*2^8 + A(:,l+2)*2^4 + A(:,l+3);
end
    
dataLength = length(A);

CurrentSensor = (A(:,2)' - 2077) * 0.00653;
%InputVoltage = A(:,6)' * 0.003222656; % 0.000805664 * 4
NewVelocity = (A(:,6)' - 32767)./ 10;
CosOut = A(:,10)' - 2076;
SinOut = A(:,14)' - 2048;
Cycles = A(:,18)';
Angle = (A(:,10)' - 32767)./ 10;
Velocity = (A(:,14)' - 32767)./ 10;
%{%}


t = 1:dataLength;

figure
plot(t,Cycles);
%plot(CosOut,SinOut,'g');

%qx = mean((CosOut))
%wx = mean(SinOut)
%aa = mean(SinOut-CosOut)

%figure шум производной
%plot(t,[0,diff(CurrentSensor)]/sampleLength,'g');


CurrentSensor2 = smooth(CurrentSensor, 5001,'sgolay',9).';
x = mean(CurrentSensor)

figure
%AA = (A-2048) * 0.004355;
plot(t,CurrentSensor2,'b');
hold on;
plot(t,CurrentSensor,'r');
hold off;

figure
hold on;
%plot(t,InputVoltage,'r');
hold off;


atn = zeros(1,dataLength);
atn2 = zeros(1,dataLength);

for l=1:dataLength
    atn(l)=atan(SinOut(l)/CosOut(l));
    atn2(l)=atan2(SinOut(l),CosOut(l));% + 3.14;
end

UNwrap = unwrap(atn2) ./2;


%RC filterK = 0.05;
K = 0.2;
K_1 = 1 - K;
atn3 = atn2;
for i=2:dataLength
    atn3(i) = K_1 * atn3(i-1) + K * atn3(i);% + K * atn2(i-1);    
end

UNwrap = Angle;

figure
plot(t,atn2);
hold on
plot(t,atn3, 'g');
hold on;
plot(t,UNwrap,'r');
hold off


%Производная по времени угла ----------------------------------------------

Velocity3 = zeros(1,dataLength);

for l=2:dataLength
  Velocity3(l) = (atn2(l) - atn2(l-1)) / sampleLength;
  if atn2(l-1)- atn2(l) > 3.14
    Velocity3(l) = (atn2(l) + 6.28 - atn2(l-1)) / sampleLength;
  elseif atn2(l-1) - atn2(l) < -3.14
    Velocity3(l) = -(6.28 - atn2(l) + atn2(l-1)) / sampleLength;
  end
end
Velocity3 = Velocity3 ./ Cycles;  
Velocity3 = Velocity3 ./2; %


Velocity4 = smooth(Velocity, 1501,'sgolay',1).';% = Velocity;%
Velocity5 = smooth(NewVelocity, 1501,'sgolay',1).';

figure
%
%plot(t, Velocity3);
hold on;
plot (t,Velocity,'m')
hold on
plot(t, NewVelocity, 'g')
hold off;

min(atn2)
max(atn2)
fclose(fid);
save('Variables.mat','Velocity3','Velocity4','InputVoltage','CurrentSensor2','Cycles','t')
end
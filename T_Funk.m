function T_Funk

%step(1/(2 * ((1+1*2/2) + (1+1*2/2)*1*s + s*s)))

clc
clear

load('Variables')
%s = tf('s')
% Сигналы
Ts=sampleLength;
J = 0.0000875;
L = 0.0225;
Mtr = 1.4917e-04;
kconstruct = 0.0178;

y = Velocity;
u = InputVoltage;
D=iddata(y.',u.',Ts);

%Механическая часть системы
Res = diff(y(3500:4000))/Ts;   %discrete time = sampleLength * Cycles
Res = Res ./ Cycles(3501:4000);
Res = smooth(Res, 5001,'sgolay',9).';
l=length(Res);
tt = 1:l;
figure 
plot(tt,Res)
Rez = mean(Res);
Rez = Rez*J

I = CurrentSensor(3501:4000);
k = (Res .*J + Mtr) ./ (I);

figure
plot(tt,k)
k = mean(k)

%tfest
sys = tfest(D,2,0)
step(sys)


init = idtf([NaN/(J * L)],[1 (16.3/L+NaN/J) (NaN*NaN+16.3*NaN/(J*L))])
sys = tfest(D,init)
step(sys)


n = sys.Numerator
m = sys.Denominator
%k = n * J * L
%figure
%plot(tay ,meean, 'r');
%ktr = (m(3) / n - k) * k / 16.3


pidTuner(sys,'pid')
end
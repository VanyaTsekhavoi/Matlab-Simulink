function T_Funk

%step(1/(2 * ((1+1*2/2) + (1+1*2/2)*1*s + s*s)))

clc
clear

load('Variables')
%s = tf('s')
% Сигналы
Ts=0.0001;
J = 0.0000875;
L = 0.0225;
Mtr = 6.3125e-04;
kconstruct = 0.0178;

y = Velocity4;
u = InputVoltage;
D=iddata(y.',u.',Ts);

%Механическая часть системы
Res = diff(y(5000:8000))/Ts;   %5 для сэмплирования = микроконтроллера,2 для учета половины заполнения буфера
Res = Res ./ Cycles(5001:8000);
Res = smooth(Res, 5001,'sgolay',9).';
l=length(Res);
tt = zeros(1,l);
for i=1:l
    tt(i)=i;
end
figure 
plot(tt,Res)
Rez = mean(Res);
Rez = Rez*J

I = CurrentSensor2(5001:8000);
k = (Res .*J + Mtr) ./ (I + 0.7875);

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
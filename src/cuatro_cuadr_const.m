%% Constants 
clear;
La=40.5e-3;
Ra=10.7;
Le=44;
Re=220;
Ke=1.795;
% Kf=1e-2;
Kt=1.795;
Jeq=0.026;
beq=0.01;

%% Polos sistema
A = [0 1 0;
    0 -beq/Jeq Kt/Jeq;
    0 -Ke/La -Ra/La];
p_i = eig(A);
syms s;
(s-p_i(1))*(s-p_i(2))*(s-p_i(3))
%% Sintonia Serie PID Izaje
wn = sqrt(abs(p_i(2)*p_i(3)));
n = 2.5;
wpos = 10;
wv = n * wpos;
wi = wpos / n;
ba = Jeq * wv;
ksa = ba * wpos;
kisa = ksa * wi;
Tau=1e-3;
P=2.2e3;

wmax= 5000*2*pi/60
Tmax=P/wmax

% IaMax=1.8;
% 
% Fnom =  14.1/(Kt*IaMax) 
% 
% Kf = Fnom/9.375 
% wnom= (30-Ra*IaMax)/(Fnom*Ke)
% Tmax = IaMax*Fnom*Kt
% P=wnom*Tmax
% Pmax=30*1.8

%
% Rated power  PN=2.2 [kW]
% Rated speed nN=1840/4900[rpm]
% Armature voltage UAN=420[V] 
% Field voltage UEN=220[V] 
% Rated motor torque Tm=12.47[Nm] 
% Armature resistance RA=10.7 [?] 
% Field resistance RE=220[?]
% Armature inductance LA=40.5[mH]
% Field inductance LE=44[H] Inertia                                       
% J=0.026[kgm2] 
% Motor constant k=1.795 
%Damping coefficient Fv=0.01 

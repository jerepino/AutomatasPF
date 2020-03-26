clc;
clear;
close all;

%% Traslacion de Carro
Rw = 0.5;%Radio Primitivo Rueda [m]
i_c = 15;%Relacion de Transmision "Caja Reductora"
Jw = 2;%Momento de Inercia de Ruedas eje lento [kg.m2]
Jm_c = 10;%Momento de Inercia de Motor y Freno eje rapido [kg.m2]
beq_c = 30;%Friccion Mecanica [N.m/(rad/s)]; definir bw y bm

%% Izaje de Carga
Rd = 0.75;%Radio Primitivo Tambor [m]
i_i = 30;%Relacion de Transmision "Caja Reductora"
Jd = 8;%Momento de Inercia de Tambor eje lento [kg.m2]
Jm_i = 30;%Momento de Inercia de Motor y Freno eje rapido [kg.m2]
beq_i = 18;%Friccion Mecanica [N.m/(rad/s)]; definir bw y bm

%% Cable
Bw = 30;%Amortiguamiento propio Cable [kN/(m/s)]
Kw = 1800;%Rigidez a traccion Cable [kN/m]

%% Carga Apoyada
Kcy = 1.3e8;%Rigidez Vertical
bcy = 500;%Friccion Vertical
bcx = 1000;%Friccion Horizontal

%% Masas
Mc = 50000;%Masa de Carro
Mh = 5000;%Masa de la Carga
%Gancho Vacio ml=15000
%Nominal 65.000
%Minima 17.000
Mt = Mc+Mh;%Masa Total

%% Gravedad
g = 9.80665;%[m/s2]

%% Equivalentes
Jeq_c = (Mt*(Rw^2)/(i_c^2))+(Jw/(i_c^2))+Jm_c;
beq_c = beq_c;
Jeq_i = (-Mh*Rd^2/(i_i^2))+(Jd/i_i^2)+Jm_i;
beq_i = beq_i;

%% Condiciones Iniciales
y0 = 45;
ysb = 15;
xt_0 = 10;%Puede ir de -30 a 50 mts; Velocidad max +/- 4[m/s]; Acceleraci�n max +/- 1[m/s2]
yl_0 = 10;%Puede ir de -20 a 40 mts; Velocidad max +/- 1.5[m/s] carga nominal;  Velocidad max +/- 3[m/s] sin carga; 
%Acceleracion max +/- 1[m/s2] cargado o sin carga
xl_0 = 10;
lh_0 = 10;
yc0 =-10;

%% Modulador de torque
Tau = 0.001; %[s]
%% Torque maximo carro
amax_c = 1; %[m/s^2]
Fmax_c = Mc * amax_c; 
Tmax_c = Fmax_c * Rw / i_c;
%% Polos sistema Carro
Ac = [0 1;0 -beq_c/Jeq_c];
p = eig(Ac);
syms s;
(s-p(1))*(s-p(2));
%% Sintonia Serie PID Carro
wn_c = abs(p(2));
n_c = 2.5;
wpos_c = wn_c*5;
wv_c = n_c * wpos_c;
wi_c = wpos_c / n_c;
ba_c = Jeq_c * wv_c
ksa_c = ba_c * wpos_c
kisa_c = ksa_c * wi_c
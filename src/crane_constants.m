clc;
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  DATOS                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Traslacion de Carro
Rw = 0.5;     % Radio Primitivo Rueda [m]
i_c = 15;     % Relacion de Transmision "Caja Reductora"
Jw = 2;       % Momento de Inercia de Ruedas eje lento [kg.m2]
Jm_c = 10;    % Momento de Inercia de Motor y Freno eje rapido [kg.m2]
beq_c = 30;   % Friccion Mecanica [N.m/(rad/s)]; definir bw y bm

% Izaje de Carga
Rd = 0.75;    % Radio Primitivo Tambor [m]
i_i = 30;     % Relacion de Transmision "Caja Reductora"
Jd = 8;       % Momento de Inercia de Tambor eje lento [kg.m2]
Jm_i = 30;    % Momento de Inercia de Motor y Freno eje rapido [kg.m2]
beq_i = 18;   % Friccion Mecanica [N.m/(rad/s)]; definir bw y bm

% Cable
Bw = 30e3;    % Amortiguamiento propio Cable [kN/(m/s)]
Kw = 1800e3;  % Rigidez a traccion Cable [kN/m]

% Carga Apoyada
Kcy = 1.3e11; % Rigidez Vertical
bcy = 500e3;  % Friccion Vertical
bcx = 1000e3; % Friccion Horizontal

% Masas
Mc = 50000;   % Masa de Carro
Mh = 15000;   % Masa de la Carga
%Gancho Vacio ml=15000
%Nominal 65.000
%Minima 17.000
%Gancho vacio 
M_h =15000.0;  % [kg] masa gancho
% Contenedor
M_cn = 50000;  % [kg] masa contenedor nominal
M_cmin = 2000; % [kg] masa contenedor vacio
% y_c = 2.5;    % [m] altura 2.5m bajo gancho
%Gancho vacio
M_l0 = M_h;
%Gancho con carga nominal
M_ln = M_h + M_cn; %[kg] m l =65000 kg (15000 kg + 50000 kg)
%Gancho con carga minima
M_lmin = M_h + M_cmin; %[kg] m l =17000 kg (15000 kg + 2000 kg)
%Intermedia (contenedor cargado con carga menor que nominal)

% Gravedad
g = 9.80665; % [m/s2]

% Equivalentes
Jeq_c = Mc * Rw^2 / i_c^2 + Jw / i_c^2 + Jm_c;
beq_c = beq_c;
Jeq_i = (-M_lmin*(Rd^2)/(i_i^2))+(Jd/(i_i^2))+Jm_i; % Cuando M es muy grande
                                                    % se hace negativo y caga
                                                    % todo
beq_i = beq_i;

% Modulador de torque
Tau = 0.001; %[s]

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  CARRO                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Torque maximo carro
vmax_c = 4; %[m/s]
amax_c = 1; %[m/s^2]
Fmax_c = Mc * amax_c; 
Tmax_c = Jeq_c * amax_c * i_c / Rw + beq_c * vmax_c * i_c / Rw \...
    + Fmax_c * Rw / i_c; % verificar ultimo termino

% Polos sistema Carro
Ac = [0 1;0 -beq_c/Jeq_c];
p = eig(Ac);
% syms s;
% ps = simplify(det(s * eye(2) - Ac));
% (s-p(1))*(s-p(2)); % Para ver el polinomio

% Sintonia Serie PID Carro
wn_c = abs(p(2));
n_c = 4.0;
wpos_c = wn_c * 2;
wv_c = n_c * wpos_c;
wi_c = wpos_c / n_c;
ba_c = Jeq_c * wv_c;
ksa_c = ba_c * wpos_c;
kisa_c = ksa_c * wi_c;

% Bode diagram
Gc = tf([ba_c, ksa_c, kisa_c],[1, ba_c/Jeq_c, ksa_c/Jeq_c, kisa_c/Jeq_c]);
%Gcl = tf([1, 0],[1, ba_c/Jeq_c, ksa_c/Jeq_c, kisa_c/Jeq_c]);
figure(1)
% bode(Gc,{wi_c, wv_c});
H = bodeplot(Gc);%,{wpos_c/n_c, wpos_c*n_c});
title('Bode Carro');
setoptions(H,'FreqScale','linear')
grid on;

% Poles 
pGc = pole(Gc);
figure(2)
pzplot(Gc);
title('Polos Carro');
hold on;
grid on;
pzplot(tf(1,[1, 3375/7376, 0]),'r');
legend('controler','motor');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  IZAJE                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Torque maximo izaje
amax_i = 1; %[m/s^2]
vmax_i = 1.5; %[m/s]
Tmax_st = g * M_ln * Rd / i_i;
Fw_max = Kw * 0.4 + Bw * 2; % Planteo un estiramiento y velocidad maximo 
                            % en base a los resultados de una ejecucion 
                            % con torque suficiente para mantener la carga
Tmax_i = Jeq_i * amax_i * i_i / Rd + beq_i * vmax_i * i_i / Rd \...
    + Tmax_st + Fw_max * Rd / i_i; % agrego Fw!!

% Polos sistema Izaje
Ai = [0 1;0 -beq_i/Jeq_i];
pi = eig(Ai);
syms s;
pis = simplify(det(s * eye(2) - Ai));
%(s-pi(1))*(s-pi(2)); % Para ver el polinomio

% Sintonia Serie PID Izaje
wn_i = abs(pi(2));
n_i = 2.5;
wpos_i = wn_i *3;
wv_i = n_i * wpos_i;
wi_i = wpos_i / n_i;
ba_i = Jeq_i * wv_i;
ksa_i = ba_i * wpos_i;
kisa_i = ksa_i * wi_i;

% Bode diagram
Gi = tf([ba_i, ksa_i, kisa_i],[1, ba_i/Jeq_i, ksa_i/Jeq_i, kisa_i/Jeq_i]);
%Gil = tf([1, 0],[1, ba_i/Jeq_i, ksa_i/Jeq_i, kisa_i/Jeq_i]);
figure(3)
% bode(Gi,{wi_i, wv_i});
H = bodeplot(Gi);%,{wpos_i/n_i, wpos_i*n_i});
title('Bode Izaje');
setoptions(H,'FreqScale','linear')
grid on;

% Poles 
pGi = pole(Gi);
figure(4)
pzplot(Gi);
title('Polos Izaje');
hold on;
grid on;
pzplot(tf(1,[1, 32400/34891, 0]),'r');
legend('controler','motor');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          CONDICIONES INICIALES                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y0 = 45; % Distancia del piso al carro yt0. Es constante
ysb = 15;
xt_0 = 0;   % Puede ir de -30 a 50 mts
            % Velocidad max +/- 4[m/s]
            % Acceleracion max +/- 1[m/s2]
yl_0 = 35;  % Puede ir de -20 a 40 mts
            % Velocidad max +/- 1.5[m/s] carga nominal
            % Velocidad max +/- 3[m/s] sin carga 
%Acceleracion max +/- 1[m/s2] cargado o sin carga
xl_0 = 0;
yc0 =0; %perfil de obstaculos
lh_0 = sqrt((xl_0 - xt_0)^2 + (y0 - yl_0)^2)-0.35;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               BALANCEO                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sintonia Serie PID Angulo de carga
wn_a = abs(sqrt(g/lh_0)); 
n_a = 3;
wpos_a = wn_a * 10;
wv_a = n_a * wpos_a;
wi_a = wpos_a / n_a;
ba_a =  lh_0 * wv_a;
ksa_a = ba_a * wpos_a;
kisa_a = ksa_a * wi_a;
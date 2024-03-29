clc;
clear;
close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  DATOS                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Tiempo muestreo
Ts = 5e-3;
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
Kcy = 1.3e9; % Rigidez Vertical
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
Mt   = Mc + (Jw+Jm_c*i_c^2) / (Rw^2); %[kg] masa equivalente

% Gravedad
g = 9.80665; % [m/s2]

% Equivalentes
Jeq_c = Mc * Rw^2 / i_c^2 + Jw / i_c^2 + Jm_c;
beq_c = beq_c;
Jeq_i = Jd / i_i^2 + Jm_i;  % Saco Mh porque el sistema no esta acoplado por la
                            % masa, sino por Fw
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
Tmax_c = Jeq_c * amax_c * i_c / Rw + beq_c * vmax_c * i_c / Rw ...
    + Fmax_c * Rw / i_c; % verificar ultimo termino

% Polos sistema Carro
Ac = [0 1;0 -beq_c/Jeq_c];
p = eig(Ac);
% syms s;
% ps = simplify(det(s * eye(2) - Ac));
% (s-p(1))*(s-p(2)); % Para ver el polinomio

% Sintonia Serie PID Carro
wn_c = abs(p(2));
n_c = 3;
wpos_c = wn_c * 13;
wv_c = n_c * wpos_c;
wi_c = wpos_c / n_c;
ba_c = Jeq_c * wv_c;
ksa_c = ba_c * wpos_c;
kisa_c = ksa_c * wi_c;

% % Bode diagram
% Gc = tf([ba_c, ksa_c, kisa_c],[1, ba_c/Jeq_c, ksa_c/Jeq_c, kisa_c/Jeq_c]);
% %Gcl = tf([1, 0],[1, ba_c/Jeq_c, ksa_c/Jeq_c, kisa_c/Jeq_c]);
% figure(1)
% % bode(Gc,{wi_c, wv_c});
% H = bodeplot(Gc);%,{wpos_c/n_c, wpos_c*n_c});
% title('Bode Carro');
% setoptions(H,'FreqScale','linear')
% grid on;
% 
% % Poles 
% pGc = pole(Gc);
% figure(2)
% pzplot(Gc);
% title('Polos Carro');
% hold on;
% grid on;
% pzplot(tf(1,[1, 3375/7376, 0]),'r');
% legend('controler','motor');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  IZAJE                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Torque maximo izaje
amax_i = 1; %[m/s^2]
vmax_i = 3; %[m/s]
Tmax_st = g * M_ln * Rd / i_i;
Fw_max = Kw * 0.4 + Bw * 2; % Planteo un estiramiento y velocidad maximo 
                            % en base a los resultados de una ejecucion 
                            % con torque suficiente para mantener la carga
Tmax_i = Jeq_i * amax_i * i_i / Rd + beq_i * vmax_i * i_i / Rd ...
    + Tmax_st + Fw_max * Rd / i_i; % agrego Fw!!

% Polos sistema Izaje
Ai = [0 1;0 -beq_i/Jeq_i];
p_i = eig(Ai);
% syms s;
% p_is = simplify(det(s * eye(2) - Ai));
%(s-p_i(1))*(s-p_i(2)); % Para ver el polinomio

% Sintonia Serie PID Izaje
wn_i = abs(p_i(2));
n_i = 3;
wpos_i = wn_i * 10;
wv_i = n_i * wpos_i;
wi_i = wpos_i / n_i;
ba_i = Jeq_i * wv_i;
ksa_i = ba_i * wpos_i;
kisa_i = ksa_i * wi_i;

% % Bode diagram
% Gi = tf([ba_i, ksa_i, kisa_i],[1, ba_i/Jeq_i, ksa_i/Jeq_i, kisa_i/Jeq_i]);
% %Gil = tf([1, 0],[1, ba_i/Jeq_i, ksa_i/Jeq_i, kisa_i/Jeq_i]);
% figure(3)
% % bode(Gi,{wi_i, wv_i});
% H = bodeplot(Gi);%,{wpos_i/n_i, wpos_i*n_i});
% title('Bode Izaje');
% setoptions(H,'FreqScale','linear')
% grid on;
% 
% % Poles 
% pGi = pole(Gi);
% figure(4)
% pzplot(Gi);
% title('Polos Izaje');
% hold on;
% grid on;
% pzplot(tf(1,[1, 32400/34891, 0]),'r');
% legend('controler','motor');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          CONDICIONES INICIALES                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
y0 = 45; % Distancia del piso al carro yt0. Es constante
ysb = 15;
xt_0 = -25; 
sXMax=50; 
sXMin=-30;  % Puede ir de -30 a 50 mts
            % Velocidad max +/- 4[m/s]
            % Acceleracion max +/- 1[m/s2]
xl_0 = xt_0;
yl_0 = 0;
sYMax=40; 
sYMin=-20; % Puede ir de -20 a 40 mts
            % Velocidad max +/- 1.5[m/s] carga nominal
            % Velocidad max +/- 3[m/s] sin carga 
%Acceleracion max +/- 1[m/s2] cargado o sin carga


lh_0 = sqrt((xl_0 - xt_0)^2 + (y0 - yl_0)^2);% - 0.35;

% Discretizo el espacio en x

xdisc = [-25 -20 -15 -10 -5 -1 0 1 5 10 15 20 25 30 35 40 45];
nCont = [ 0   1   0   1   1  0 0 0 17  3  4  5  17  7  8  9 1];
h = 2.5;
w = 4;
yc0 = h * nCont + [zeros(1, find(xdisc == 0)-1),15 , ...
                   -18 * ones(1,size(xdisc,2) - find(xdisc == 0))]; %perfil obstaculos

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               INTERFAZ                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%             
bPosObjetivoIncremental = false; % Para check box
dIncremento = 0;
bControlAutomatico = true; % Check box
bCargaDescarga = false; % Check box
dXiniCarga = -5;
dXiniDescarga = 45;
dXiniCarga2 = 40;
dXiniDescarga2 = -10;
dYStart = 7;
dYStart2 = 0;
dYStartAuto = dYStart + 1;
dYFinish = 0;
dYFinish2 = 7;
dYFinish_Auto = dYFinish - 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               BALANCEO                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% lh = 1;
% Polos Sistema Balanceo carga
% Aa = [0 -g/lh_0; 1 0];
% Ba = [-1/lh_0; 0];
% Wc_a = ctrb(Aa, Ba);
% rank(Wc_a);
% p_a = eig(Aa); 
% syms s;
% pas = simplify(det(s * eye(2) - Aa));
% Sintonia Serie PID Angulo de carga

% Ga = tf([-(Mc+M_l0) 0],[lh_0*(M_l0+Jeq_c*i_c^2/Rw^2) 0 g*Jeq_c*i_c^2/Rw^2]);
% p_a_ = pole(Ga);
% wn_a = abs(sqrt(g/10)); 
% % wn_a = abs(p_a_(1));
% % n_a = 3;
% % leq = lh_0*(M_l0+Jeq_c*i_c^2/Rw^2);
% wpos_a = wn_a * 0.98; 
% % wv_a = n_a * wpos_a;
% % wi_a = wpos_a / n_a;
% % ba_a =  lh_0 * wv_a;
% % ksa_a = ba_a * wpos_a;
% % kisa_a = ksa_a * wi_a;
% 
% % ba_a = lh_0 * (n_a - 1) * wpos_a;
% % ksa_a = lh_0 * wpos_a^2;
% 
% %Estos funcan con ode4
% ba_a = -10 + g/wpos_a^2
% ksa_a = 2 * 0.6 * wpos_a * (10 + ba_a);

% For para varias ba_a y ksa_a
% ba_a = zeros(1,63);
% ksa_a  = zeros(1,63);
% for l_=1:63
%     wn_a = abs(sqrt(g/l_)); 
%     wpos_a = wn_a * 0.98; 
%     ba_a(l_) = -l_ + g/wpos_a^2;
%     ksa_a(l_) = 2 * 0.7 * wpos_a * (l_ + ba_a(l_));
% end

%%% Nueva sintonizacion y sus polos.
% lh = 20;
% ml = M_cn;
% 
% wpos =2* abs(sqrt((g*Mt)/(lh*(ml+Mt))));
% zita = 1;
% lq = (ml+Mt)*lh;
% ba = 3 * wpos * lq;
% ksa = wpos^2 * lq *3;%- g * Mt;
% pid = tf([ba, ksa],1);
% Ga = tf([-(ml+Mt),0],[lh*(ml+Mt), 0, (g*Mt)]);
% Gas = pid * Ga / (1 + Ga * pid) 
% step(feedback(Ga,pid))
% step(Gas);
% % % Bode diagram
% % Ga = tf([ba_a, ksa_a, kisa_a],[1, ba_a/lh_0, ksa_a/lh_0, kisa_a/lh_0]);
% % %Gal = tf([1, 0],[1, ba_a/lh_0, ksa_a/lh_0, kisa_a/lh_0]);
% figure(5)
% % bode(Ga,{wi_a, wv_a});
% H = bodeplot(Ga);%,{wpos_a/n_a, wpos_a*n_a});
% title('Bode Agulo');
% setoptions(H,'FreqScale','linear')
% grid on;
% % 
% % % Poles 
% %     wn_a = abs(sqrt(g/10)); 
% %     wpos_a = wn_a * 5; 
% %     ba_a(10) = -10 + g/wpos_a^2
% %     ksa_a(10) = 2 * .4 * wpos_a * (10 + ba_a(10))
% %     Ga = tf([ba_a(10)/(ba_a(10)+10), ksa_a(10)/(ba_a(10)+10)],[1, ksa_a(10)/(ba_a(10)+10), g/(ba_a(10)+10)]);
% pGa = pole(Ga);
% figure(6)
% pzplot(Ga);
% title('Polos Angulo');
% hold on;
% grid on;
% pzplot(tf([-(ml+Mt), 0],[lh * (ml+Mt), 0, g*Mt]),'r');
% legend('controler','angle');
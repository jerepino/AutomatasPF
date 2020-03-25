%% Parametros de modelado
%% Hanging Load (carga suspendida)
%Gancho vacío 
M_h =15000.0; %[kg] masa gancho
% Contenedor
M_cn = 50000; %[kg] masa contenedor nominal
M_cmin = 2000; %[kg] masa contenedor vacio
% y_c = 2.5; %[m] altura 2.5m bajo gancho
%Gancho vacio
M_l0 = M_h;
%Gancho con carga nominal
M_ln = M_h + M_cn; %[kg] m l =65000 kg (15000 kg + 50000 kg)
%Gancho con carga minima
M_lmin = M_h + M_cmin; %[kg] m l =17000 kg (15000 kg + 2000 kg)
%Intermedia (contenedor cargado con carga menor que nominal)
%% Trolley
%Masa carro(incluye izaje)
M_t = 50000; %[kg]
%Radio primitivo de rueda
R_tw = 0.5; %[m]
%Momento de inercia de ruedas (eje lento)
J_tw = 2.0; %[kg.m^2]
%Relacion caja reductora rueda-motor
i_t = 15.0; %[15:1]
%Momento de inercia de motor y freno (eje rarapido)
J_tm = 10.0; %[kg.m^2]
%Friccion mecanica
b_teq = 30; %[Nm/(rad/s)]
%Momento de inercia equivalente
J_teq = J_tm + J_tw / i_t^2 + M_t * (R_tw / i_t)^2; 
%% Hoist
%Radio primitivo de tambor (1 sola corrida de cable);
R_hd = 0.75; %[m]
%Momento de inercia de tambor (eje lento)
J_hd = 8.0; %[kg.m^2]
%Caja reductora: relación 
i_h = 30.0; %30:1
%Momento de inercia de motor y freno (eje rápido)
J_hm = 30.0; %[kg.m^2]
%Friccion mecanica (eje rapido)
b_heq = 18.0; %[Nm/(rad/s)]
%Momento de inercia equivalente
J_heq = J_hm + J_hd / i_h^2 - M_ln* (R_hd / i_h)^2; 
%% Wire Rope (cable)
%Rigidez a tracción
K_wr = 1800.0; %[kN/m]
%Amortiguamiento propio (fricción interna):
b_wr = 30.0; %[kN/(m/s)]
%% Gravity 
g = 9.80665; %[m/s^2]
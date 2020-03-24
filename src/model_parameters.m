%% Parametros de modelado
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
b_teq = 30; %[Nm/(rad/s]
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
%% Wire Rope (cable)
%Rigidez a tracción
K_wr = 1800.0; %[kN/m]
%Amortiguamiento propio (fricción interna):
b_wr = 30.0; %[kN/(m/s)]
%% Hanging Load (carga suspendida)
%Gancho vacío 
m_h =15000.0; %[kg] masa gancho
% Contenedor
m_cn = 50000; %[kg] masa contenedor nominal
m_cmin = 2000; %[kg] masa contenedor vacio
% y_c = 2.5; %[m] altura 2.5m bajo gancho
%Gancho vacio
m_l0 = m_h;
%Gancho con carga nominal
m_ln = m_h + m_cn; %[kg] m l =65000 kg (15000 kg + 50000 kg)
%Gancho con carga minima
m_lmin = m_h + m_cmin; %[kg] m l =17000 kg (15000 kg + 2000 kg)
%Intermedia (contenedor cargado con carga menor que nominal)
%% Gravity 
g = 9.80665; %[m/s^2]
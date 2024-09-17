function [Q_rotada,T] = RotarQ(Q, angle)
% Esta función rota la matriz Q usando un ángulo dado en grados.

% Definir la matriz de rotación
T = [cosd(angle)^2, sind(angle)^2, 2*sind(angle)*cosd(angle); 
     sind(angle)^2, cosd(angle)^2, -2*sind(angle)*cosd(angle);
     -sind(angle)*cosd(angle), sind(angle)*cosd(angle), cosd(angle)^2 - sind(angle)^2];

% Rotar la matriz Q
Q_rotada = T\Q/T';
end

clear; clc
format long
%%% Carga de archivos
% Angulos
f_angles = "combinaciones_angulos.txt";
angles = readmatrix(f_angles);
[~, numCols] = size(angles);
n = numCols;
[numRows, ~] = size(angles);
% Momentos
f_momentos = "momentos.txt";
momentos = readmatrix(f_momentos);
M = [0; 0; 50];            %%%% POR AHORA %%%%
%%% Datos del material 
t = 0.2e-3; % espesor
E_1 = 160e9;
E_2 = 8e9;
G_12 = 4.5e9;
v_12 = 0.3;
F_Lt = 700e6;
F_Lc = 700e6;
F_Tt = 100e6;
F_Tc = 100e6;
F_LT = 30e6;

%%% Almacenar resultados
TH_values = zeros(numRows, n);  % Matriz para almacenar los valores de Tsai-Hill
angles_results = angles;        % Ya tienes los ángulos, puedes copiarlos
%%% Calculo 
% Matriz Q
v_21 = v_12 * (E_2 / E_1);
d = 1 - v_12 * v_21;
Q_11 = E_1 / d;
Q_12 = v_12 * E_2 / d;
Q_21 = v_21 * E_1 / d;
Q_22 = E_2 / d;
Q_66 = G_12;
Q = [Q_11 Q_12 0; Q_21 Q_22 0; 0 0 Q_66];
% Iterar sobre cada fila de la matriz (laminado)
for i = 1:numRows
    % Almacenar Q rotadas y T por laminado
    Q_rotadas = zeros(3,3,n);
    T_rot = zeros(3,3,n);
    for j = 1:numCols
        a = angles(i,j);
        [Q_rotada,T] = RotarQ(Q, a);
        Q_rotadas(:, :, j) = Q_rotada;
        T_rot(:, :, j) = T;
    end
    % Calculo matrices de rigide D por laminado
    z = -n*t:t:n*t;
    D = zeros(3, 3);
    for k = 2:n+1
        D = D + 2*((z(k)^3 - z(k-1)^3) * Q_rotadas(:,:,k-1)) / 3;
    end
    % Resolver las ecuaciones de equilibrio para las curvaturas
    syms k_x k_y k_xy
    k = [k_x; k_y; k_xy];
    eqn = M == D * k;
    sol = solve(eqn, [k_x, k_y, k_xy]);
    curvaturas = [sol.k_x; sol.k_y; sol.k_xy];
    kappa = [curvaturas(1); curvaturas(2); curvaturas(3)];
    % Cálculo de los esfuerzos en cada lámina
    esfuerzos = zeros(3, n);
    for k = 1:n
        z_media = (z(k) + z(k+1)) / 2;  % Posición media de la lámina
        epsilon_k = z_media * kappa;     % Deformaciones en la lámina k
        sigma_k = Q_rotadas(:,:,k) * epsilon_k; % Esfuerzos en la lámina k
        esfuerzos(:,k) = sigma_k;        % Guardar esfuerzos
    end
    % Cálculo de tensiones transformadas al sistema local de la fibra
    d_m = zeros(3, n);  % Esfuerzos en el sistema local de la fibra
    for k = 1:n
        % Transformar los esfuerzos globales al sistema local de la fibra
        d_m(:,k) = T_rot(:,:,k) * esfuerzos(:,k);  % Transformar esfuerzos globales
    end
    % Criterio de Tsai-Hill
    for k = 1:n
        d_L = d_m(1, k);  
        d_T = d_m(2, k); 
        d_LT = d_m(3, k);
        TH = d_L^2/(F_Lt*F_Lc) - d_T*d_L/(F_Lt*F_Lc) + d_T^2/(F_Lt*F_Lc) + ...
         d_L*(1/F_Lt - 1/F_Lc) + d_T*(1/F_Tt - 1/F_Tc) + (d_LT/F_LT)^2;
        TH_values(i, k) = TH; 
    end
    % Mostrar el progreso
    porcentaje = (i / numRows) * 100;
    fprintf('Progreso: %.2f%%\n', porcentaje);
end
fprintf('Cálculo terminado.\n');

% Generar nombres de columnas dinámicamente
angleNames = strcat("Angulo", string(1:n));
THNames = strcat("TH", string(1:n));
columnNames = [angleNames, THNames];

% Combinar ángulos y valores de TH en una tabla
resultados_TH = array2table([angles_results, TH_values], ...
                            'VariableNames', columnNames);

% Guardar en un archivo CSV
filename = 'resultados_TH.csv';
writetable(resultados_TH, filename);

fprintf('Resultados guardados en %s\n', filename);

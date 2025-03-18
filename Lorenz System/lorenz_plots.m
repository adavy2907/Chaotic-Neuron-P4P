% Lorenz system parameters
sigma = 10;
rho = 28;
beta = 8 / 3;

% Initial conditions
y0_1 = [1; 1; 1];       % Initial condition 1
y0_1001 = [1.001; 1.001; 1.001];  % Initial condition 1.001

% Time span
t0 = 0;
t1 = 40;

% Solve the ODE for initial condition 1
[t, y] = ode45(@(t, y) derivative_lorenz(t, y, sigma, rho, beta), [t0, t1], y0_1);

% Solve the ODE for initial condition 1.001
[t_1001, y_1001] = ode45(@(t, y) derivative_lorenz(t, y, sigma, rho, beta), [t0, t1], y0_1001);

% PLOTTING ###############################################################

% Plot x vs z for both initial conditions
figure;
plot(y(:, 1), y(:, 3), 'r', 'DisplayName', 'Initial cond 1');
hold on;
plot(y_1001(:, 1), y_1001(:, 3), 'b', 'DisplayName', 'Initial cond 1.001');
title('x vs z for Lorenz ODE (with 1.001 initial cond.)');
xlabel('Z');
ylabel('X');
legend;
hold off;

% Plot X, Y, Z vs time for initial condition 1
figure;
subplot(3, 1, 1);
plot(t, y(:, 1), 'r', 'DisplayName', 'Initial cond 1');
ylabel('X');
title('X, Y, Z vs time for Lorenz System (initial cond. = 1)');

subplot(3, 1, 2);
plot(t, y(:, 2), 'b', 'DisplayName', 'Initial cond 1');
ylabel('Y');

subplot(3, 1, 3);
plot(t, y(:, 3), 'g', 'DisplayName', 'Initial cond 1');
xlabel('Time');
ylabel('Z');

% Uncomment the following lines to plot for initial condition 1.001
% subplot(3, 1, 1);
% hold on;
% plot(t_1001, y_1001(:, 1), 'b', 'DisplayName', 'Initial cond 1.001');
% hold off;
%
% subplot(3, 1, 2);
% hold on;
% plot(t_1001, y_1001(:, 2), 'b', 'DisplayName', 'Initial cond 1.001');
% hold off;
%
% subplot(3, 1, 3);
% hold on;
% plot(t_1001, y_1001(:, 3), 'b', 'DisplayName', 'Initial cond 1.001');
% hold off;
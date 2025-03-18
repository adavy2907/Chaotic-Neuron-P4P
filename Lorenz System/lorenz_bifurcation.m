% Parameters
sigma = 10;
beta = 8 / 3;
rho_values = linspace(0, 50, 500);  % Sweep rho from 0 to 50
y0 = [1; 1; 1];  % Initial condition

t0 = 0;
t1 = 100;  % Run longer to allow transients to decay
atol = 1e-5;

z_values = {};  % Initialize as a cell array

% Loop over rho values
for i = 1:length(rho_values)
    rho = rho_values(i);
    
    % Solve the ODE using ode45
    [t, y] = ode45(@(t, y) derivative_lorenz(t, y, sigma, rho, beta), [t0, t1], y0);
    
    % Take last 10% of time series (steady-state)
    steady_state = y(round(0.9 * length(y)):end, 3);
    z_values{end+1} = steady_state;  % Append to cell array
end

% Flatten results for plotting
rho_repeated = repelem(rho_values, cellfun(@length, z_values));
z_flat = vertcat(z_values{:});  % Concatenate cell array contents

% Plot bifurcation diagram
figure;
scatter(rho_repeated, z_flat, 1, 'k');
xlabel('\rho');
ylabel('Z values');
title('Bifurcation Plot of the Lorenz System');
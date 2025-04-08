% Parameters
k = 0.5;          % Decay parameter
alpha = 1.0;      % Strength of refractory effect
a = 0.5;          % External input

% Initial condition
y0 = 0.1;         % Initial internal state

% Time steps
num_steps = 100; % Number of time steps
y = zeros(num_steps, 1); % Preallocate array for states
y(1) = y0;        % Set initial state

% Simulate the Nagumo-Sato model
for t = 1:num_steps-1
    y(t+1) = nagumo_sato(y(t), k, alpha, a);
end

% Plot the results
figure;
plot(1:num_steps, y, 'b', 'LineWidth', 1.5);
xlabel('Time Step');
ylabel('Internal State y(t)');
title('Nagumo-Sato Neuron Model');
grid on;
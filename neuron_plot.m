% Parameters
k = 0.5;          % Decay parameter
alpha = 1.0;      % Strength of refractory effect
a = 0.5;          % External input
epsilon = 0.04;    % Steepness parameter

% Initial condition
y0 = 0.11;         % Initial internal state

% Time steps
num_steps = 50; % Number of time steps
y = zeros(num_steps, 1); % Preallocate array for states
y(1) = y0;        % Set initial state

% Simulate the chaotic neuron model
for t = 1:num_steps-1
    y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
end

% Plot the results
figure;
plot(1:num_steps, y, 'b', 'LineWidth', 0.5); % Reduce line width
xlabel('Time Step');
ylabel('Internal State y(t)');
title('Chaotic Neuron Model (Aihara, Takabe, Toyoda)');
grid on;
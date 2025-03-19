% Parameters
k = 0.5;              % Decay parameter
alpha = 1.0;          % Strength of refractory effect
a_values = linspace(0, 1, 500); % Range of external input (a) for bifurcation
num_steps = 1000;      % Number of time steps
transient_steps = 800; % Number of steps to discard (transient behavior)

% Preallocate cell array to store steady-state values for each a
steady_states = cell(length(a_values), 1);

% Loop over different values of a
for i = 1:length(a_values)
    a = a_values(i);
    
    % Initial condition
    y = zeros(num_steps, 1);
    y(1) = 0.1; % Initial internal state
    
    % Simulate the Nagumo-Sato model
    for t = 1:num_steps-1
        y(t+1) = nagumo_sato(y(t), k, alpha, a);
    end
    
    % Discard transient behavior and store steady-state values
    steady_states{i} = y(transient_steps:end);
end

% Flatten the steady-state values for plotting
a_repeated = repelem(a_values, cellfun(@length, steady_states));
y_flat = cell2mat(steady_states);

% Plot the bifurcation diagram
figure;
scatter(a_repeated, y_flat, 1, 'k', 'filled'); % Use small black dots
xlabel('External Input (a)');
ylabel('Steady-State Internal State y(t)');
title('Bifurcation Diagram for Nagumo-Sato Neuron Model');
grid on;
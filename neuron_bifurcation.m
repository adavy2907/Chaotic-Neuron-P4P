% Parameters
k = 0.5;              % Decay parameter
alpha = 9;           % Strength of refractory effect
epsilon = 0.04;         % Steepness parameter
a_values = linspace(1, 3, 500); % Range of external input (a) for bifurcation
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
    
    % Simulate the chaotic neuron model
    for t = 1:num_steps-1
        y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
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
title('Bifurcation Diagram for Chaotic Neuron Model');
grid on;
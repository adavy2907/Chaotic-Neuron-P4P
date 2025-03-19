% Parameters
k = 0.5;              % Decay parameter
alpha = 1.0;          % Strength of refractory effect
epsilon = 0.04;        % Steepness parameter
a_values = linspace(0, 1, 100); % Range of external input (a) for firing rate
num_steps = 1000;      % Number of time steps
transient_steps = 200; % Number of steps to discard (transient behavior)
y_thresh = 0;          % Firing threshold

% Preallocate array to store average firing rates
firing_rates = zeros(size(a_values));

% Loop over different values of a
for i = 1:length(a_values)
    a = a_values(i);
    
    % Initial condition
    y = zeros(num_steps, 1);
    y(1) = 0.1; % Initial internal state
    
    % Simulate the chaotic neuron model
    num_firings = 0; % Counter for firing events
    for t = 1:num_steps-1
        % Update the internal state
        y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
        
        % Detect firing events (after discarding transient steps)
        if t > transient_steps && y(t+1) > y_thresh
            num_firings = num_firings + 1;
        end
    end
    
    % Calculate average firing rate
    firing_rates(i) = num_firings / (num_steps - transient_steps);
end

% Plot the average firing rate as a function of a
figure;
plot(a_values, firing_rates, 'b', 'LineWidth', 1.5);
xlabel('External Input (a)');
ylabel('Average Firing Rate');
title('Average Firing Rate for Chaotic Neuron Model');
grid on;
% Parameters
num_neurons = 10;      % Number of neurons in the network
k = 0.9;               % Decay parameter
alpha = 1.0;           % Strength of refractory effect
epsilon = 0.1;         % Steepness parameter
a = 0.5;               % External input (constant for all neurons)
num_steps = 1000;      % Number of time steps
transient_steps = 200; % Number of steps to discard (transient behavior)

% Synaptic weight matrix (randomly initialized)
W = rand(num_neurons, num_neurons) - 0.5; % Random weights between -0.5 and 0.5
W = W ./ max(abs(W(:))); % Normalize weights to prevent instability

% Initial conditions
y = zeros(num_neurons, num_steps); % Internal states of all neurons
y(:, 1) = 0.1; % Initial internal state for all neurons

% Simulate the network
for t = 1:num_steps-1
    % Compute synaptic inputs for each neuron
    synaptic_input = W * y(:, t); % Total synaptic input for each neuron
    
    % Update the internal state of each neuron
    for i = 1:num_neurons
        y(i, t+1) = chaotic_neuron(y(i, t), k, alpha, a + synaptic_input(i), epsilon);
    end
end

% Discard transient steps
y = y(:, transient_steps:end);

% Plot the activity of the neurons
figure;
plot(y', 'LineWidth', 1.5);
xlabel('Time Step');
ylabel('Internal State y(t)');
title('Activity of Chaotic Neurons in a Network');
legend(arrayfun(@(i) sprintf('Neuron %d', i), 1:num_neurons, 'UniformOutput', false));
grid on;
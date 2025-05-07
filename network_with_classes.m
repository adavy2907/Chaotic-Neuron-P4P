% Parameters
num_neurons = 3;      % Number of neurons in the network
k = 0.5;              % Decay parameter
alpha = 1.0;          % Strength of refractory effect
epsilon = 0.04;        % Steepness parameter
a = 0.5;              % External input (constant for all neurons)
num_steps = 300;      % Number of time steps
transient_steps = 200; % Number of steps to discard (transient behavior)

% Define the function fx
fx = @(y, eps) 1 ./ (1 + exp(-y / eps));

% --- Network Structure ---
% UNCOMMENT BELOW FOR CIRCULAR NETWORK
% Initialize all weights to zero
W = zeros(num_neurons, num_neurons);

% Connect each neuron to the next one in a ring
for i = 1:num_neurons
    next = mod(i, num_neurons) + 1; % Circular connection (wrap around)
    W(next, i) = rand() - 0.5; % Neuron i affects neuron next by random weight
end
W = W ./ max(abs(W(:))); % Normalize weights to prevent instability

% % UNCOMMENT BELOW FOR CONNECTED NETWORK
% W = rand(num_neurons, num_neurons) - 0.5; % Random weights between -0.5 and 0.5
% for i = 1:num_neurons
%     W(i,i) = 0; % No self-connections
% end
% W = W ./ max(abs(W(:))); % Normalize weights

% --- Initialize Chaotic Neurons ---
neurons = repmat(Chaotic_Neuron(k, alpha, a, epsilon, 0.1), 1, num_neurons);

% --- Simulation ---
y = zeros(num_neurons, num_steps);
y(:, 1) = 0.1; % Initial internal state for all neurons

for t = 1:num_steps-1
    % Compute synaptic inputs for each neuron
    synaptic_input = W * y(:, t); % Total synaptic input for each neuron
    
    % Update the internal state of each neuron using the class method
    for i = 1:num_neurons
        % Pass the current state and the function fx to chaotic_neuron
        y(i, t+1) = neurons(i).chaotic_neuron(y(i, t), fx);
        
        % Add synaptic input to the external input 'a'
        neurons(i).a = a + synaptic_input(i); % Uncomment if 'a' should vary
    end
end

% Discard transient steps
y = y(:, transient_steps:end);

% --- Plot Neuron Activity ---
figure;
plot(y', 'LineWidth', 1.5);
xlabel('Time Step');
ylabel('Internal State y(t)');
title('Activity of Chaotic Neurons in a Network');
legend(arrayfun(@(i) sprintf('Neuron %d', i), 1:num_neurons, 'UniformOutput', false));
grid on;

% --- Plot Network Structure ---
G = digraph(W);
figure;
p = plot(G, 'Layout', 'auto', 'ArrowSize', 12, 'LineWidth', 2);
p.NodeLabel = arrayfun(@(i) sprintf(int2str(i)), 1:num_neurons, 'UniformOutput', false);
LWidths = 5*abs(G.Edges.Weight);
p.LineWidth = LWidths;

edgeLabels = arrayfun(@(x) sprintf('%.2f', x), G.Edges.Weight, 'UniformOutput', false);
labeledge(p, G.Edges.EndNodes(:,1), G.Edges.EndNodes(:,2), edgeLabels);

title('Neuron Network with Weights');
p.NodeColor = 'black';
p.MarkerSize = 7;
p.EdgeColor = 'black';
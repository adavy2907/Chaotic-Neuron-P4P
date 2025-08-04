

% Parameters
num_neurons = 2;      % Number of neurons in the network
k = 0.9;               % Decay parameter
alpha = 1.0;           % Strength of refractory effect
epsilon = 0.1;         % Steepness parameter
a = 0.5;               % External input (constant for all neurons)
num_steps = 300;      % Number of time steps
transient_steps = 200; % Number of steps to discard (transient behavior)

% UNCOMMENT BELOW FOR CIRCULAR NETOWRK 

% Initialize all weights to zero
W = zeros(num_neurons, num_neurons);

% Connect each neuron to the next one in a ring
for i = 1:num_neurons
    next = mod(i, num_neurons) + 1; % Circular connection (wrap around)
    W(next, i) =  rand(); % Neuron i affects neuron next by random weight
end

W = W ./ max(abs(W(:))); % Normalize weights to prevent instability

% % UNCOMMENT BELOW FOR CONNECTED NETWORK
% 
% % Synaptic weight matrix (randomly initialized)
% W = rand(num_neurons, num_neurons) - 0.5; % Random weights between -0.5 and 0.5
% 
% for i = 1:num_neurons
%     W(i,i) = 0;
% end
% 
% W = W ./ max(abs(W(:))); % Normalize weights to prevent instability

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



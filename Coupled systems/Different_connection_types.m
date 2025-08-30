% Bifurcation diagram for network of chaotic neurons with selectable topology
clear; clc; close all;

%% Parameters
num_neurons     = 4;                 % number of neurons (4 for box topologies)
topology_type   = 'linear bidirectional'; % topology choice
% 'linear unidirectional'
% 'linear bidirectional'
% 'box unidirectional'
% 'box bidirectional'
% 'all-to-all'
k               = 0.5;               % decay parameter
alpha           = 1.0;               % refractory strength
epsilon         = 0.04;              % steepness parameter
a_values        = linspace(0.259, 0.9, 500);
num_steps       = 1000;
transient_steps = 800;
init_y          = 0.1;


metric = 'single'; % 'single' or 'mean'noise
rep_neuron = 1;  

rng(0);
W = zeros(num_neurons);

switch lower(topology_type)
    case 'linear unidirectional'
        for i = 1:num_neurons-1
            W(i+1,i) = 1;
        end
    case 'linear bidirectional'
        for i = 1:num_neurons-1
            W(i+1,i) = 1;
            W(i,i+1) = 1;
        end
    case 'box unidirectional'
        if num_neurons ~= 4, error('Box topology requires num_neurons = 4'); end
        W(2,1) = 1; W(3,2) = 1;
        W(4,3) = 1; W(1,4) = 1;
    case 'box bidirectional'
        if num_neurons ~= 4, error('Box topology requires num_neurons = 4'); end
        W(2,1) = 1; W(1,2) = 1;
        W(3,2) = 1; W(2,3) = 1;
        W(4,3) = 1; W(3,4) = 1;
        W(1,4) = 1; W(4,1) = 1;
    case 'all-to-all'
        W = ones(num_neurons);
        for i = 1:num_neurons
            W(i,i) = 0;
        end
    case 'circular'
        for i = 1:num_neurons
            next = mod(i, num_neurons) + 1;
            W(next,i) = 1;
        end
    otherwise
        error('Unknown topology type.');
end

% Normalize weights
if max(abs(W(:)))>0, W = W ./ max(abs(W(:))); end

%% Bifurcation sweep
steady_states = cell(length(a_values),1);

for ia = 1:length(a_values)
    a = a_values(ia);
    y = zeros(num_neurons, num_steps);
    y(:,1) = init_y;
    
    for t = 1:(num_steps-1)
        syn = W * y(:,t);
        for n = 1:num_neurons
            y(n,t+1) = chaotic_neuron(y(n,t), k, alpha, a + syn(n), epsilon);
        end
    end
    
    idx = (transient_steps+1):num_steps;
    if strcmpi(metric,'single')
        steady_states{ia} = y(rep_neuron, idx).';
    else
        steady_states{ia} = mean(y(:, idx), 1).';
    end
end

%% Flatten for plotting
a_repeated = repelem(a_values(:), cellfun(@length, steady_states));
y_flat     = cell2mat(steady_states);

%% Plot bifurcation diagram
figure;

scatter(a_repeated, y_flat, 1, 'k', 'filled');
xlabel('External Input (a)');
if strcmpi(metric,'single')
    ylabel(sprintf('y(t) neuron %d', rep_neuron));
    title(sprintf('Bifurcation: neuron %d (%s)', rep_neuron, topology_type), 'Interpreter','none');
else
    ylabel('Mean network activity');
    title(sprintf('Bifurcation: mean (%s)', topology_type), 'Interpreter','none');
end
grid on;
xlim([min(a_values) max(a_values)]);

%% Plot network architecture
G = digraph(W);
figure;
p = plot(G, 'Layout', 'auto', 'ArrowSize', 12, 'LineWidth', 2);
p.NodeLabel = arrayfun(@num2str, 1:num_neurons, 'UniformOutput', false);
p.LineWidth = 5 * abs(G.Edges.Weight);
edgeLabels = arrayfun(@(x) sprintf('%.2f', x), G.Edges.Weight, 'UniformOutput', false);
labeledge(p, G.Edges.EndNodes(:,1), G.Edges.EndNodes(:,2), edgeLabels);
p.NodeColor = 'black';
p.MarkerSize = 7;
p.EdgeColor = 'black';
title('Network Architecture');

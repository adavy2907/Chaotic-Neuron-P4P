% Parameters
num_neurons = 2;
k = 0.5;
alpha = 1.0;
epsilon = 0.04;
a_values = linspace(0.1, 0.9, 300);  % Bifurcation parameter
num_steps = 500;
transient_steps = 300;

% Synaptic weights (e.g., circular network)
W = zeros(num_neurons, num_neurons);
for i = 1:num_neurons
    next = mod(i, num_neurons) + 1;
    W(next, i) = rand();
end
W = W ./ max(abs(W(:)));  % Normalize

% Storage for bifurcation and Lyapunov
steady_states = cell(length(a_values), 1);
lyap_values = zeros(length(a_values), 1);

for ai = 1:length(a_values)
    a = a_values(ai);

    % Initialize states
    y = zeros(num_neurons, num_steps);
    y_pert = zeros(num_neurons, num_steps);

    y(:, 1) = 0.1;
    y_pert(:, 1) = 0.1 + 1e-8;  % Slightly perturbed

    lyap_sum = 0;

    for t = 1:num_steps - 1
        % Synaptic input
        syn_input = W * y(:, t);
        syn_input_pert = W * y_pert(:, t);

        % Update neurons
        for i = 1:num_neurons
            y(i, t+1) = chaotic_neuron(y(i, t), k, alpha, a + syn_input(i), epsilon);
            y_pert(i, t+1) = chaotic_neuron(y_pert(i, t), k, alpha, a + syn_input_pert(i), epsilon);
        end

        % Compute perturbation distance
        delta = norm(y_pert(:, t+1) - y(:, t+1));
        if delta == 0, delta = 1e-12; end

        % Accumulate Lyapunov sum after transient
        if t > transient_steps
            lyap_sum = lyap_sum + log(delta / 1e-8);
        end

        % Renormalize perturbation
        diff = y_pert(:, t+1) - y(:, t+1);
        y_pert(:, t+1) = y(:, t+1) + 1e-8 * (diff / norm(diff));
    end

    % Store steady-state y-values (for one neuron, e.g., neuron 1)
    steady_states{ai} = y(1, transient_steps:end);
    lyap_values(ai) = lyap_sum / (num_steps - transient_steps);
end

% --- Plotting ---

% Ensure all steady_states are column vectors
for i = 1:length(steady_states)
    steady_states{i} = steady_states{i}(:);
end

% Now safely build plotting data
a_repeated = repelem(a_values, cellfun(@length, steady_states));
y_flat = cell2mat(steady_states);


% Plot bifurcation diagram
figure;
subplot(2, 1, 1);
scatter(a_repeated, y_flat, 1, 'k', 'filled');
xlabel('a');
ylabel('y_1(t)');
title('Bifurcation Diagram (Neuron 1)');
grid on;

% Plot Lyapunov exponent
subplot(2, 1, 2);
plot(a_values, lyap_values, 'b', 'LineWidth', 1.5);
yline(0, 'r--');
xlabel('a');
ylabel('Lyapunov Exponent');
title('Lyapunov Exponent of Coupled Network');
grid on;

% Setup
num_neurons = 2;
num_steps = 500;
transient_steps = 300;
a_values = linspace(0, 1, 300);  % External input sweep

% Per-neuron intrinsic parameters
k_values       = [0.5, 0.5];
alpha_values   = [1.0, 0.9];
epsilon_values = [0.04, 0.04];

% Storage for each neuron's bifurcation data and Lyapunov exponents
steady_states = cell(num_neurons, length(a_values));
lyap_values   = zeros(num_neurons, length(a_values));

% Loop over neurons
for neuron = 1:num_neurons
    k = k_values(neuron);
    alpha = alpha_values(neuron);
    epsilon = epsilon_values(neuron);

    % Loop over bifurcation parameter a
    for ai = 1:length(a_values)
        a = a_values(ai);

        % Main state and perturbed state
        y = zeros(num_steps, 1);
        y_pert = zeros(num_steps, 1);

        y(1) = 0.1;
        y_pert(1) = y(1) + 1e-8;

        lyap_sum = 0;

        for t = 1:num_steps - 1
            y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
            y_pert(t+1) = chaotic_neuron(y_pert(t), k, alpha, a, epsilon);

            delta = abs(y_pert(t+1) - y(t+1));
            if delta == 0, delta = 1e-12; end

            if t > transient_steps
                lyap_sum = lyap_sum + log(delta / 1e-8);
            end

            % Renormalize perturbation
            y_pert(t+1) = y(t+1) + 1e-8 * ((y_pert(t+1) - y(t+1)) / delta);
        end

        % Store steady-state values and Lyapunov exponent
        steady_states{neuron, ai} = y(transient_steps:end);
        lyap_values(neuron, ai) = lyap_sum / (num_steps - transient_steps);
    end
end

% === Plotting ===
figure;
for neuron = 1:num_neurons
    % Bifurcation data
    bif_points = cell2mat(steady_states(neuron, :)');
    a_repeated = repelem(a_values, cellfun(@length, steady_states(neuron, :)));

    subplot(2, num_neurons, neuron);
    scatter(a_repeated, bif_points, 1, 'k', 'filled');
    xlabel('a'); ylabel(sprintf('y_%d(t)', neuron));
    title(sprintf('Bifurcation (Neuron %d)', neuron));
    axis tight;

    % Lyapunov exponent
    subplot(2, num_neurons, neuron + num_neurons);
    plot(a_values, lyap_values(neuron, :), 'b', 'LineWidth', 1.2);
    yline(0, 'r--');
    xlabel('a'); ylabel('Lyap. Exp');
    title(sprintf('\\lambda (Neuron %d)', neuron));
    axis tight;
end

sgtitle('Bifurcation Diagrams & Lyapunov Exponents (Independent Neurons)');

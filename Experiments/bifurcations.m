% Define ranges for parameters
k_values = [0.01,0.1,0.3, 0.5, 0.7,0.9, 0.99];
alpha_values = [0.8];
epsilon_values = [0.06];

a_values = linspace(0, 1, 500); % External input range
num_steps = 1000;               % Total simulation steps
transient_steps = 800;          % Discard this many steps

% Create a figure to hold all subplots
figure;
plot_idx = 1;
num_plots = length(k_values) * length(alpha_values) * length(epsilon_values);

for ki = 1:length(k_values)
    for ai = 1:length(alpha_values)
        for ei = 1:length(epsilon_values)

            k = k_values(ki);
            alpha = alpha_values(ai);
            epsilon = epsilon_values(ei);

            % Preallocate cell for steady-state values
            steady_states = cell(length(a_values), 1);

            for i = 1:length(a_values)
                a = a_values(i);
                y = zeros(num_steps, 1);
                y(1) = 0.1;

                for t = 1:num_steps-1
                    y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
                end

                steady_states{i} = y(transient_steps:end);
            end

            % Prepare for plotting
            a_repeated = repelem(a_values, cellfun(@length, steady_states));
            y_flat = cell2mat(steady_states);

            % Create subplot
            subplot(1, length(alpha_values) * length(k_values), plot_idx);
            scatter(a_repeated, y_flat, 1, 'k', 'filled');
            title(sprintf('k=%.2f, α=%.2f, ε=%.2f', k, alpha, epsilon));
            xlabel('a');
            ylabel('y');
            axis tight;
            plot_idx = plot_idx + 1;
        end
    end
end

sgtitle('Bifurcation Diagrams for Chaotic Neuron Model');

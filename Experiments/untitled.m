% Define parameter ranges
k_values = [0.5];
alpha_values = [1];
epsilon_values = [0.04, 0.05, 0.06, 0.07, 0.08];

a_values = linspace(0, 1, 500);  % External input range
num_steps = 1000;
transient_steps = 800;

% Create a figure to hold subplots (2 rows: bifurcation + Lyapunov)
figure;
plot_idx = 1;
num_cols = length(k_values) * length(alpha_values) * length(epsilon_values);

for ki = 1:length(k_values)
    for ai = 1:length(alpha_values)
        for ei = 1:length(epsilon_values)

            k = k_values(ki);
            alpha = alpha_values(ai);
            epsilon = epsilon_values(ei);

            % Allocate storage
            steady_states = cell(length(a_values), 1);
            lyap_vals = zeros(length(a_values), 1);

            for i = 1:length(a_values)
                a = a_values(i);
                y = zeros(num_steps, 1);
                y(1) = 0.1;

                % For Lyapunov exponent
                y_pert = y;
                y_pert(1) = y(1) + 1e-8;
                lyap_sum = 0;

                for t = 1:num_steps-1
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

                steady_states{i} = y(transient_steps:end);
                lyap_vals(i) = lyap_sum / (num_steps - transient_steps);
            end

            % --- Plot bifurcation diagram (top row) ---
            a_repeated = repelem(a_values, cellfun(@length, steady_states));
            y_flat = cell2mat(steady_states);

            subplot(2, num_cols, plot_idx);
            scatter(a_repeated, y_flat, 1, 'k', 'filled');
            title(sprintf('k=%.2f, α=%.2f, ε=%.2f', k, alpha, epsilon));
            xlabel('a');
            ylabel('y');
            axis tight;

            % --- Plot Lyapunov exponent (bottom row) ---
            subplot(2, num_cols, plot_idx + num_cols);
            plot(a_values, lyap_vals, 'b', 'LineWidth', 1);
            yline(0, 'r--');  % λ = 0 reference line
            xlabel('a');
            ylabel('Lyapunov Exponent');
            axis tight;

            plot_idx = plot_idx + 1;
        end
    end
end

sgtitle('Bifurcation Diagrams and Lyapunov Exponents for Chaotic Neuron Model');

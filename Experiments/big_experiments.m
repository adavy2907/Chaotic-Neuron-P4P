function big_experiments(k, epsilon, alpha_range, external_input_a, delay)

T = 2000;  
transient_steps = 1800; 

% Store all trajectories: each column corresponds to an alpha
y = zeros(T, length(alpha_range));
y(1, :) = 0.1;

for ai = 1:length(alpha_range)
    alpha = alpha_range(ai);
    for t = 1:T-1
        y(t+1, ai) = chaotic_neuron(y(t, ai), k, alpha, external_input_a, epsilon);
    end
end

%%%% BIF PLOTS %%%%%%
figure;
plot_idx = 1;
a_values = linspace(0, 1, 500);

for ai = 1:length(alpha_range)
    alpha = alpha_range(ai);

    % Preallocate cell for steady-state values
    steady_states = cell(length(a_values), 1);

    for i = 1:length(a_values)
        a = a_values(i);
        y_bif = zeros(T, 1);
        y_bif(1) = 0.1;

        for t = 1:T-1
            y_bif(t+1) = chaotic_neuron(y_bif(t), k, alpha, a, epsilon);
        end
        steady_states{i} = y_bif(transient_steps:end);
    end

    % Prepare for plotting
    a_repeated = repelem(a_values, cellfun(@length, steady_states));
    y_flat = cell2mat(steady_states);

    % Create subplot
    subplot(1, length(alpha_range), plot_idx);
    scatter(a_repeated, y_flat, 1, 'k', 'filled');
    title(sprintf('k=%.2f, α=%.2f, ε=%.2f', k, alpha, epsilon));
    xlabel('a');
    ylabel('y');
    axis tight;
    plot_idx = plot_idx + 1;
end

sgtitle('Bifurcation Diagrams for Chaotic Neuron Model');

%%%%% LYAPUNOV PLOTS %%%%%%%
lyapunov_exponents = zeros(size(alpha_range));

for ai = 1:length(alpha_range)
    alpha = alpha_range(ai);
    lyapunov_sum = 0;

    for t = 1:T-1
        df_dy = k - alpha * (exp(-y(t, ai) / epsilon) / (epsilon * (1 + exp(-y(t, ai) / epsilon))^2));
        lyapunov_sum = lyapunov_sum + log(abs(df_dy));
    end

    lyapunov_exponents(ai) = lyapunov_sum / (T-1);
end

figure;
plot(alpha_range, lyapunov_exponents, 'r', 'LineWidth', 1.5);
xlabel('Refractory Strength (\alpha)');
ylabel('Lyapunov Exponent (\lambda)');
title('Lyapunov Exponent vs \alpha');
grid on;

%%%%% PHASE SPACE PLOTS %%%%%%
tau = delay;
all_y = [];
all_y_tau = [];
all_alpha = [];

for ai = 1:length(alpha_range)
    alpha = alpha_range(ai);
    y_col = y(:, ai);

    % Build 2D time-delay embedding
    N = length(y_col) - tau;
    y_now = y_col(1:N);
    y_tau = y_col(1+tau:N+tau);

    % Store results with alpha as third axis
    all_y = [all_y; y_now];
    all_y_tau = [all_y_tau; y_tau];
    all_alpha = [all_alpha; alpha * ones(size(y_now))];
end

figure;
scatter3(all_y, all_y_tau, all_alpha, 3, all_alpha, 'filled');
xlabel('y(t)');
ylabel(['y(t+', num2str(tau), ')']);
zlabel('\alpha');
title('Phase Space Evolution with \alpha');
grid on;
view(30,30);
colorbar;
colormap turbo;

end


%%%%% Chaotic neuron function %%%%%
function y_next = chaotic_neuron(y, k, alpha, a, epsilon)
    f = 1 / (1 + exp(-y / epsilon));  
    y_next = k * y - alpha * f + a; 
end

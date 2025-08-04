% Nagumo-Sato Bifurcation & Lyapunov Exponents

% --- Parameters ---
k = 0.5;               % Decay parameter
alpha = 1.0;           % Refractory effect
a_values = linspace(0, 1, 500); % Range of external input (a)
num_steps = 1000;      % Total iterations
transient_steps = 800; % Steps to discard for transients

% --- Bifurcation setup ---
steady_states = cell(length(a_values), 1);

% --- Lyapunov setup ---
lyap_exp = zeros(length(a_values), 1);

% --- Simulation loop ---
for i = 1:length(a_values)
    a = a_values(i);

    % Initial conditions
    y = zeros(num_steps, 1);
    y(1) = 0.1;

    % Slightly perturbed trajectory for Lyapunov exponent
    y_pert = zeros(num_steps, 1);
    y_pert(1) = y(1) + 1e-8;

    d0 = abs(y_pert(1) - y(1));
    lyap_sum = 0;

    for t = 1:num_steps-1
        % Original trajectory
        y(t+1) = nagumo_sato(y(t), k, alpha, a);

        % Perturbed trajectory
        y_pert(t+1) = nagumo_sato(y_pert(t), k, alpha, a);

        % Distance and renormalization
        d = abs(y_pert(t+1) - y(t+1));
        if d == 0
            d = 1e-8;
        end
        lyap_sum = lyap_sum + log(abs(d / d0));

        % Renormalize perturbation
        y_pert(t+1) = y(t+1) + d0 * sign(y_pert(t+1) - y(t+1));
    end

    lyap_exp(i) = lyap_sum / (num_steps - 1);
    steady_states{i} = y(transient_steps:end);
end

% --- Plotting ---

% Bifurcation diagram
a_repeated = repelem(a_values, cellfun(@length, steady_states));
y_flat = cell2mat(steady_states);

% figure;
% scatter(a_repeated, y_flat, 1, 'k', 'filled');
% xlabel('External Input (a)');
% ylabel('Steady-State y(t)');
% title('Nagumo-Sato Bifurcation Diagram');
% grid on;

% Lyapunov exponent plot

plot(a_values, lyap_exp, 'b');
yline(0, '--r');
xlabel('External Input (a)');
ylabel('Lyapunov Exponent');
title('Lyapunov Exponents for Nagumo-Sato Model');
ylim([-1,1])
grid on;

% --- Model Function -

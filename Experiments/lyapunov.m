% Parameter ranges
k_values = linspace(0.3, 0.7, 10);
alpha_values = linspace(0.8, 1.2, 10);
epsilon_values = linspace(0.02, 0.06, 10);
a = 0.5;  % Fixed external input

num_steps = 1000;
transient_steps = 800;

% Allocate storage
lyap_exp = zeros(length(k_values), length(alpha_values), length(epsilon_values));

for ki = 1:length(k_values)
    for ai = 1:length(alpha_values)
        for ei = 1:length(epsilon_values)

            k = k_values(ki);
            alpha = alpha_values(ai);
            epsilon = epsilon_values(ei);

            y = zeros(num_steps, 1);
            y(1) = 0.1;
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

            lyap_exp(ki, ai, ei) = lyap_sum / (num_steps - transient_steps);
        end
    end
end

[X, Y] = meshgrid(alpha_values, k_values);
Z = lyap_exp(:,:,slice_idx);
figure;
surf(X, Y, Z);
xlabel('alpha');
ylabel('k');
zlabel('Lyapunov Exponent');
title(sprintf('Lyapunov Exponent Surface (epsilon = %.3f)', epsilon_values(slice_idx)));

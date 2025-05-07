% Fixed parameters
alpha = 1.0;
epsilon = 0.04;
num_steps = 1000;
transient_steps = 800;

% Range for a and k
a_values = linspace(0, 1, 300);       % External input
k_values = linspace(0.2, 0.8, 100);   % Decay parameter

% Preallocate result containers
results = [];

% Loop through k and a to collect steady-state values
for ki = 1:length(k_values)
    k = k_values(ki);

    for ai = 1:length(a_values)
        a = a_values(ai);

        % Initialize neuron state
        y = zeros(num_steps, 1);
        y(1) = 0.1;

        for t = 1:num_steps-1
            y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
        end

        % Get steady state part of trajectory
        y_ss = y(transient_steps:end);

        % Store: [k, a, y_ss]
        results = [results; repmat([k, a], length(y_ss), 1), y_ss];
    end
end

% Plotting the two-parameter bifurcation diagram
figure;
scatter3(results(:,1), results(:,2), results(:,3), 1, results(:,3), 'filled');
xlabel('k (Decay)');
ylabel('a (Input)');
zlabel('Steady-state y');
title('Two-Parameter Bifurcation Diagram (varying a and k)');
view(2); % Top-down 2D view
colormap(jet);
colorbar;
grid on;

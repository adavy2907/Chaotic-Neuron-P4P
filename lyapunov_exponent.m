% Parameters
k = 0.9;              % Decay parameter
alpha = 1.0;          % Strength of refractory effect
epsilon = 0.1;        % Steepness parameter
a_values = linspace(0, 2, 200); % Range of external input (a) for Lyapunov exponent
num_steps = 10000;    % Number of time steps for Lyapunov exponent calculation
transient_steps = 1000; % Number of steps to discard (transient behavior)

% Preallocate array to store Lyapunov exponents
lyapunov_exponents = zeros(size(a_values));

% Loop over different values of a
for i = 1:length(a_values)
    a = a_values(i);
    
    % Initial condition
    y = 0.1; % Initial internal state
    
    % Discard transient behavior
    for t = 1:transient_steps
        y = chaotic_neuron(y, k, alpha, a, epsilon);
    end
    
    % Compute the Lyapunov exponent
    lyapunov_sum = 0;
    for t = 1:num_steps
        % Derivative of the chaotic neuron map
        df_dy = k - alpha * (exp(-y / epsilon) / (epsilon * (1 + exp(-y / epsilon))^2));
        
        % Update the Lyapunov sum
        lyapunov_sum = lyapunov_sum + log(abs(df_dy));
        
        % Update the state
        y = chaotic_neuron(y, k, alpha, a, epsilon);
    end
    
    % Compute the Lyapunov exponent for this value of a
    lyapunov_exponents(i) = lyapunov_sum / num_steps;
end

% Plot the Lyapunov exponent as a function of a
figure;
plot(a_values, lyapunov_exponents, 'b', 'LineWidth', 1.5);
xlabel('External Input (a)');
ylabel('Lyapunov Exponent (\lambda)');
title('Lyapunov Exponent for Chaotic Neuron Model');
grid on;
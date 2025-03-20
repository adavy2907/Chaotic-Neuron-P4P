% Parameters
a_values = linspace(0, 1, 100); % Range of external input (a)
k_values = linspace(0, 1, 100); % Range of decay parameter (k)
num_steps = 1000;      % Number of time steps
transient_steps = 200; % Number of steps to discard (transient behavior)
epsilon = 0.04;        % Steepness parameter (fixed)

% Preallocate matrix to store Lyapunov exponents
lyapunov_exponents = zeros(length(k_values), length(a_values));

% Loop over different values of a and k
for i = 1:length(a_values)
    for j = 1:length(k_values)
        a = a_values(i);
        k = k_values(j);
        
        % Initial condition
        y = zeros(num_steps, 1);
        y(1) = 0.1; % Initial internal state
        
        % Discard transient behavior
        for t = 1:transient_steps
            y(t+1) = chaotic_neuron(y(t), k, 1.0, a, epsilon); % alpha = 1.0
        end
        
        % Compute the Lyapunov exponent
        lyapunov_sum = 0;
        for t = transient_steps+1:num_steps-1
            % Derivative of the chaotic neuron map
            df_dy = k - (exp(-y(t) / epsilon)) / (epsilon * (1 + exp(-y(t) / epsilon))^2);
            
            % Update the Lyapunov sum
            lyapunov_sum = lyapunov_sum + log(abs(df_dy));
            
            % Update the state
            y(t+1) = chaotic_neuron(y(t), k, 1.0, a, epsilon);
        end
        
        % Store the Lyapunov exponent
        lyapunov_exponents(j, i) = lyapunov_sum / (num_steps - transient_steps);
    end
end

% Flip the matrix vertically so k=0 is at the bottom and k=1 is at the top
lyapunov_exponents = flipud(lyapunov_exponents);

% Plot the parameter space
figure;
imagesc(a_values, k_values, lyapunov_exponents);
xlabel('External Input (a)');
ylabel('Decay Parameter (k)');
title('Solutions in Parameter Space (a vs k)');
colorbar;
colormap(jet); % Use a colormap to distinguish periodic and chaotic regions
axis xy; % Ensure the y-axis increases from bottom to top
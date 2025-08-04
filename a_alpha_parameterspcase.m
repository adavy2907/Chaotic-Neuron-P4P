% Parameters
a_values = linspace(0, 1, 100);       % Range of external input (a)
alpha_values = linspace(0, 2, 100);   % Range of gain parameter (alpha)
num_steps = 1000;                     % Number of time steps
transient_steps = 200;               % Number of steps to discard (transient behavior)
epsilon = 0.04;                       % Steepness parameter (fixed)
k = 0.5;                              % Fixed decay parameter

% Preallocate matrix to store Lyapunov exponents
lyapunov_exponents = zeros(length(alpha_values), length(a_values));

% Loop over different values of a and alpha
for i = 1:length(a_values)
    for j = 1:length(alpha_values)
        a = a_values(i);
        alpha = alpha_values(j);
        
        % Initial condition
        y = zeros(num_steps, 1);
        y(1) = 0.1; % Initial internal state
        
        % Discard transient behavior
        for t = 1:transient_steps
            y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
        end
        
        % Compute the Lyapunov exponent
        lyapunov_sum = 0;
        for t = transient_steps+1:num_steps-1
            % Derivative of the chaotic neuron map
            df_dy = k - (exp(-y(t) / epsilon)) / (epsilon * (1 + exp(-y(t) / epsilon))^2);
            
            % Update the Lyapunov sum
            lyapunov_sum = lyapunov_sum + log(abs(df_dy));
            
            % Update the state
            y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
        end
        
        % Store the Lyapunov exponent
        lyapunov_exponents(j, i) = lyapunov_sum / (num_steps - transient_steps);
    end
end

% Flip the matrix vertically so alpha = 0 is at the bottom
lyapunov_exponents = flipud(lyapunov_exponents);

% Define a sharply contrasting colormap: dark blue → white → bright red
n = 256; % Total colormap size
midpoint = round(n / 2);

% Blue shades for negative exponents
neg_colors = [linspace(0, 0, midpoint)', linspace(0, 0.5, midpoint)', linspace(1, 1, midpoint)'];
% Red shades for positive exponents
pos_colors = [linspace(1, 1, midpoint)', linspace(0.5, 0, midpoint)', linspace(0, 0, midpoint)'];
% Combine into a diverging colormap with white in the middle
cmap = [neg_colors; pos_colors];

% Set color scale: clip extreme values to avoid skew
clip_val = max(abs(lyapunov_exponents(:)));
clip_val = min(clip_val, 1);  % Optionally limit the range to [-1, 1]
clim = [-clip_val, clip_val];

% Plot
figure;
imagesc(a_values, alpha_values, lyapunov_exponents);
xlabel('External Input (a)');
ylabel('Refractory Strength (\alpha)');
title('Lyapunov Exponents (a vs \alpha)');
colorbar;
colormap(cmap);
caxis(clim); % Fix color scaling to highlight zero crossing
axis xy;

% Optional: add a black contour at λ = 0 for clarity
hold on;
contour(a_values, alpha_values, lyapunov_exponents, [0 0], 'k', 'LineWidth', 1.5);

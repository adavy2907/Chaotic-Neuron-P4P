function coupled_chaotic_aihara_2neuron_finite_memory()
    % Parameters
    M = 2;                         % Number of neurons
    T = 2000;                      % Total time steps
    k = 0.9;                       % Memory decay
    alpha = 0.5;                   % Refractory strength (reduced)
    theta = [0.0; 0.0];            % Thresholds
    epsilon = 0.04;                % Sigmoid steepness
    L = 20;                        % Finite memory length

    % Weight matrix (W_ij: influence of neuron j on i)
    W = [0.0, 1.0;
         1.0, 0.0];

    % Initialize states
    x = zeros(M, T);
    x(:,1:L) = randn(M, L) * 0.1;  % Small random initial conditions

    % Iterate over time
    for t = (L+1):T
        for i = 1:M
            recurrent_sum = 0;
            refractory_sum = 0;
            for r = 0:(L-1)
                decay = k^r;
                for j = 1:M
                    recurrent_sum = recurrent_sum + W(i,j) * decay * sigmoid(x(j, t-1-r), epsilon);
                end
                refractory_sum = refractory_sum + decay * sigmoid(x(i, t-1-r), epsilon);
            end
            x(i,t) = recurrent_sum - alpha * refractory_sum - theta(i);
        end
    end

    % Plot phase space
    figure;
    plot(x(1, L+1:end), x(2, L+1:end), 'k.', 'MarkerSize', 1);
    xlabel('Neuron 1 state (x_1)');
    ylabel('Neuron 2 state (x_2)');
    title('Phase Space: Aihara Model with 2 Coupled Chaotic Neurons');
    axis equal;
    grid on;
end

function y = sigmoid(x, epsilon)
    y = 1 ./ (1 + exp(-x / epsilon));
end

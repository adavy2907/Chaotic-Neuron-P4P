
k = 0.5;       % Decay parameter (0 < k < 1)
alpha = 1.0;    % Refractory strength
a = 0.5;        % External input (controls chaos)
T = 100;       % Number of time steps (longer for better attractor resolution)
y = zeros(T, 1);
y(1) = 0.1;     % Initial condition

for t = 1:T-1
    y(t+1) = nagumo_sato(y(t), k, alpha, a);
end


tau = 2;        % Delay (empirically chosen; adjust as needed)
m = 3;          % Embedding dimension (3D)

% Reconstruct 3D embedding: [y(t), y(t+tau), y(t+2tau)]
N = length(y) - (m-1)*tau;
embedded_3D = zeros(N, m);
for i = 1:N
    embedded_3D(i, :) = y(i:tau:i + (m-1)*tau);
end

figure;

% Time series of y(t)
subplot(1, 2, 1);
plot(y, 'b', 'LineWidth', 0.5);
title('Nagumo-Sato Neuron: Time Series');
xlabel('Time'); ylabel('y(t)');
grid on;

% Reconstructed attractor 
subplot(1, 2, 2);
plot3(embedded_3D(:,1), embedded_3D(:,2), embedded_3D(:,3), 'r', 'LineWidth', 0.5);
xlabel('x(t)'); ylabel('x(t+\tau)'); zlabel('x(t+2\tau)');
grid on; axis tight;

sgtitle('Nagumo-Sato Neuron: Chaos and Time-Delay Embedding');

% Nagumo-Sato function (provided)
function y_next = nagumo_sato(y, k, alpha, a)
    % Binary output function (step function)
    if y >= 0
        f = 1;
    else
        f = 0;
    end
    y_next = k * y - alpha * f + a;  % Update rule
end
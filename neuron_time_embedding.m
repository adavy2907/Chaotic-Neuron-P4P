k = 0.5;        
alpha = 1.0;    % Refractory strength
a = 0.1;        % External input
epsilon = 0.04;  
T = 2000;       
y = zeros(T, 1);
y(1) = 0.1;     % Initial condition

% Simulate the chaotic neuron
for t = 1:T-1
    y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
end


tau = 2;    % Delay
m = 3;      % Embedding dimension


N = length(y) - (m-1)*tau;
embedded_3D = zeros(N, m);
for i = 1:N
    embedded_3D(i, :) = y(i:tau:i + (m-1)*tau);
end


figure;

% Original time series
subplot(1, 2, 1);
plot(y, 'b', 'LineWidth', 1);
title('Chaotic Neuron: Time Series');
xlabel('Time'); ylabel('y(t)');
grid on;

% 3D embedding (y(t), y(t+tau), y(t+2tau))
subplot(1, 2, 2);
plot3(embedded_3D(:,1), embedded_3D(:,2), embedded_3D(:,3), 'g.', 'MarkerSize', 10);
title('3D Time-Delay Embedding');
xlabel('y(t)'); ylabel('y(t+\tau)'); zlabel('y(t+2\tau)');
grid on; axis tight;
view(30, 30);  % Adjust viewing angle

% Chaotic neuron function
function y_next = chaotic_neuron(y, k, alpha, a, epsilon)
    f = 1 / (1 + exp(-y / epsilon));  
    y_next = k * y - alpha * f + a; 
end
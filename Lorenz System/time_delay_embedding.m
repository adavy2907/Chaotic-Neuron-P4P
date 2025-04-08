
% Parameters for Lorenz system
sigma = 10;
rho = 28;
beta = 8/3;
dt = 0.01;  
T = 100;    
tspan = 0:dt:T;

% solve lorenz
f = @(t, y) [sigma*(y(2) - y(1)); 
             y(1)*(rho - y(3)) - y(2); 
             y(1)*y(2) - beta*y(3)];
[t, y] = ode45(f, tspan, [1; 1; 1]); % Initial condition [1, 1, 1]
x = y(:, 1); % Extract x-component for reconstruction

% Time-delay embedding parameters
tau = 10;    % Delay in steps
m = 3;       % Embedding dimension

% Reconstruct the attractor using x(t), x(t+tau), x(t+2tau)
N = length(x) - (m-1)*tau;
embedded = zeros(N, m);
for i = 1:N
    embedded(i, :) = x(i:tau:i + (m-1)*tau);
end


figure;

% Original 3D Lorenz attractor
subplot(1, 2, 1);
plot3(y(:,1), y(:,2), y(:,3), 'b', 'LineWidth', 0.5);
xlabel('x'); ylabel('y'); zlabel('z');
grid on; axis tight;

% Reconstructed attractor (from x-component)
subplot(1, 2, 2);
plot3(embedded(:,1), embedded(:,2), embedded(:,3), 'r', 'LineWidth', 0.5);
xlabel('x(t)'); ylabel('x(t+\tau)'); zlabel('x(t+2\tau)');
grid on; axis tight;

% Compare shapes
sgtitle('Lorenz System: Original vs. Time-Delay Embedding');
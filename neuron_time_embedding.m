k = 0.5;        
alpha = 1.0;    % Refractory strength
a = 0.1;        % External input
epsilon = 0.04;  
T = 5000;       
y = zeros(T, 1);
y(1) = 0.1;     % Initial condition

% Simulate the chaotic neuron
for t = 1:T-1
    y(t+1) = chaotic_neuron(y(t), k, alpha, a, epsilon);
end

tau = 20;    % Delay
m = 3;       % Embedding dimension

N = length(y) - (m-1)*tau;
embedded_3D = zeros(N, m);
for i = 1:N
    embedded_3D(i, :) = y(i:tau:i + (m-1)*tau);
end

% Make figure
fig = figure;
set(fig, 'Color', 'w');
filename = 'chaotic_neuron.gif';

for t = 2:N
    clf;
    
    % --- 2D plot ---
    subplot(1,2,1);
    plot(embedded_3D(1:t,1), embedded_3D(1:t,2), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(embedded_3D(t,1), embedded_3D(t,2), 'ro', 'MarkerFaceColor','r'); % current point
    title('2D Time-Delay Embedding');
    xlabel('y(t)'); ylabel('y(t+\tau)');
    grid on; axis tight;
    
    % --- 3D plot ---
    subplot(1,2,2);
    plot3(embedded_3D(1:t,1), embedded_3D(1:t,2), embedded_3D(1:t,3), 'g-', 'LineWidth', 1.5);
    hold on;
    plot3(embedded_3D(t,1), embedded_3D(t,2), embedded_3D(t,3), 'ro', 'MarkerFaceColor','r'); % current point
    title('3D Time-Delay Embedding');
    xlabel('y(t)'); ylabel('y(t+\tau)'); zlabel('y(t+2\tau)');
    grid on; axis tight;
    view(30,30);
    
    % --- Capture frame ---
    drawnow;
    frame = getframe(fig);
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    
    % Write to GIF
    if t == 2
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.05);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.05);
    end
end

disp('GIF saved as chaotic_neuron.gif');

% Chaotic neuron function
function y_next = chaotic_neuron(y, k, alpha, a, epsilon)
    f = 1 / (1 + exp(-y / epsilon));  
    y_next = k * y - alpha * f + a; 
end

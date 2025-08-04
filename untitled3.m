% Parameters
k = 0.5;
alpha = 1.0;
epsilon = 0.04;      % Steep sigmoid
numSteps = 1000;
transient = 300;
aVals = linspace(0, 1, 250);  % Sweep over 'a'
coupling = 0.2;

% Preallocate
bifurcation_a = [];
bifurcation_y1 = [];
lyap_exp = zeros(1, length(aVals));

% Main loop
for idx = 1:length(aVals)
    a = aVals(idx);
    
    % Initial conditions
    y1 = 0.1;
    y2 = -0.1;
    y1p = y1 + 1e-8;
    y2p = y2;
    
    delta = 1e-8;
    lyap_sum = 0;
    traj_y1 = [];

    for t = 1:numSteps
        % Original system
        y1_next = chaotic_neuron(y1, k, alpha, a, epsilon) + coupling * (y2 - y1);
        y2_next = chaotic_neuron(y2, k, alpha, a, epsilon) + coupling * (y1 - y2);

        % Perturbed system
        y1p_next = chaotic_neuron(y1p, k, alpha, a, epsilon) + coupling * (y2p - y1p);
        y2p_next = chaotic_neuron(y2p, k, alpha, a, epsilon) + coupling * (y1p - y2p);

        % Lyapunov exponent estimate
        dx = [y1p_next - y1_next, y2p_next - y2_next];
        dist = norm(dx);
        if dist ~= 0 && t > transient
            lyap_sum = lyap_sum + log(abs(dist / delta));
        end
        scale = delta / dist;
        y1p = y1_next + dx(1) * scale;
        y2p = y2_next + dx(2) * scale;

        % Update states
        y1 = y1_next;
        y2 = y2_next;

        if t > transient
            traj_y1(end+1) = y1; %#ok<SAGROW>
        end
    end

    % Store data
    bifurcation_a = [bifurcation_a, repmat(a, 1, length(traj_y1))];
    bifurcation_y1 = [bifurcation_y1, traj_y1];
    lyap_exp(idx) = lyap_sum / (numSteps - transient);
end

% Plot results
figure('Color','w');
subplot(2,1,1)
plot(bifurcation_a, bifurcation_y1, '.k', 'MarkerSize', 1);
ylabel('y_1');
title('Bifurcation Diagram (Coupled Chaotic Neurons, varying a)');
grid on;

subplot(2,1,2)
plot(aVals, lyap_exp, 'r', 'LineWidth', 1);
yline(0, '--k');
xlabel('a');
ylabel('Lyapunov Exponent');
title('Lyapunov Exponent vs a');
grid on;

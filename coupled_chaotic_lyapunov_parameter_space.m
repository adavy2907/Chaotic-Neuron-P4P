function coupled_chaotic_lyapunov_colormap()
    % Parameter ranges
    a_values = linspace(0, 1, 300); % External input
    k_values = linspace(0, 1, 300); % Decay parameter
    epsilon = 0.04;
    alpha = 1.0;
    coupling = 0.2;

    % Simulation settings
    num_steps = 1000;
    transient_steps = 200;
    delta = 1e-8; % Perturbation

    % Storage for Lyapunov exponents
    lyap_exp = zeros(length(k_values), length(a_values));
    % Set fixed decay parameter for neuron 2
    k2_fixed = 0.5;  % You can change this to any constant you like

for i = 1:length(a_values)
    for j = 1:length(k_values)
        a = a_values(i);
        k1 = k_values(j);  % Varying k for neuron 1
        k2 = k2_fixed;     % Fixed k for neuron 2

        % Initial states
        y1 = 0.1; y2 = -0.1;
        yp1 = y1 + delta; yp2 = y2;

        lyap_sum = 0;

        % Discard transients
        for t = 1:transient_steps
            y1_next = chaotic_neuron(y1, k1, alpha, a, epsilon) + coupling * (y2 - y1);
            y2_next = chaotic_neuron(y2, k2, alpha, a, epsilon) + coupling * (y1 - y2);
            y1 = y1_next;
            y2 = y2_next;
        end

        % Main loop for Lyapunov exponent
        for t = 1:(num_steps - transient_steps)
            % Original
            y1_next = chaotic_neuron(y1, k1, alpha, a, epsilon) + coupling * (y2 - y1);
            y2_next = chaotic_neuron(y2, k2, alpha, a, epsilon) + coupling * (y1 - y2);

            % Perturbed
            yp1_next = chaotic_neuron(yp1, k1, alpha, a, epsilon) + coupling * (yp2 - yp1);
            yp2_next = chaotic_neuron(yp2, k2, alpha, a, epsilon) + coupling * (yp1 - yp2);

            % Compute distance and renormalize
            d = sqrt((yp1_next - y1_next)^2 + (yp2_next - y2_next)^2);
            if d ~= 0
                lyap_sum = lyap_sum + log(abs(d / delta));
                scale = delta / d;
                yp1 = y1_next + (yp1_next - y1_next) * scale;
                yp2 = y2_next + (yp2_next - y2_next) * scale;
            end

            y1 = y1_next;
            y2 = y2_next;
        end

        lyap_exp(j, i) = lyap_sum / (num_steps - transient_steps);
    end
end


    % Flip so that k = 0 is at the bottom
    lyap_exp = flipud(lyap_exp);

    % Build diverging colormap (dark blue → white → bright red)
    n = 256;
    midpoint = round(n / 2);
    neg_colors = [linspace(0, 0, midpoint)', linspace(0, 0.5, midpoint)', linspace(1, 1, midpoint)'];
    pos_colors = [linspace(1, 1, midpoint)', linspace(0.5, 0, midpoint)', linspace(0, 0, midpoint)'];
    cmap = [neg_colors; pos_colors];

    % Set color clipping range
    clip_val = max(abs(lyap_exp(:)));
    clip_val = min(clip_val, 1);  % Cap at ±1
    clim = [-clip_val, clip_val];

    % % Plot
    % figure;
    % imagesc(a_values, k_values, lyap_exp);
    % xlabel('External Input (a)');
    % ylabel('Decay Parameter (k)');
    % title('Lyapunov Exponents (Coupled Chaotic Neurons)');
    % colorbar;
    % colormap(cmap);
    % caxis(clim);
    % axis xy;
    % 
    % % Add contour at λ = 0
    % hold on;
    % contour(a_values, k_values, lyap_exp, [0 0], 'k', 'LineWidth', 1.5);

    % plot(y1, y2); % Trajectory in y1-y2 plane
    % xlabel('y_1'); ylabel('y_2'); title('Phase Space');

    plot(time, y1 - y2); ylabel('y_1 - y_2'); title('Synchronization Difference');

end

function y_next = chaotic_neuron(y, k, alpha, a, epsilon)
    f = 1 / (1 + exp(-y / epsilon));
    y_next = k * y - alpha * f + a;
end

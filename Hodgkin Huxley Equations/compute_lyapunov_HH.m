function lambda = compute_lyapunov_HH(I0)
% Computes the largest Lyapunov exponent for the standard Hodgkin-Huxley model (no forcing)
% Input:
%   I0 - constant external current
% Output:
%   lambda - estimated largest Lyapunov exponent

    % Simulation parameters
    dt = 0.01;
    Tmax = 500;
    steps = Tmax / dt;
    tspan = [0 dt];
    I0 = 10
    
    % Initial conditions
    X = [-65; 0.317; 0.05; 0.6];     % [V, n, m, h]
    delta0 = 1e-5;
    delta = [delta0; 0; 0; 0];
    Y = X + delta;
    
    lyap_sum = 0;

    for i = 1:steps
        [~, xsol] = ode45(@(t, X) HH_ode(t, X, I0), tspan, X);
        [~, ysol] = ode45(@(t, X) HH_ode(t, X, I0), tspan, Y);
        
        X = xsol(end, :)';
        Y = ysol(end, :)';
        
        delta_vec = Y - X;
        dist = norm(delta_vec);
        
        % Avoid numerical issues
        if dist == 0
            dist = 1e-10;
        end
        
        % Renormalize
        delta_vec = delta0 * delta_vec / dist;
        Y = X + delta_vec;
        
        lyap_sum = lyap_sum + log(dist / delta0);
    end

    % Final Lyapunov exponent estimate
    lambda = lyap_sum / (steps * dt);
    fprintf('I0 = %.2f → λ = %.6f\n', I0, lambda);
end

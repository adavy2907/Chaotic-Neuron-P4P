% Parameters
dt = 0.01;
Tmax = 100;
steps = Tmax/dt;
tspan = [0 dt];

% Initial Conditions
X = [-65; 0.317; 0.05; 0.6];      % Initial state
delta0 = 1e-5;                    % Initial perturbation
delta = [delta0; 0; 0; 0];        % Perturb V only
Y = X + delta;

lyap_sum = 0;

for i = 1:steps
    % Integrate one step forward
    [~, xsol] = ode45(@(t, X) HH_with_forcing(t, X, I0, A, f), tspan, X);
    [~, ysol] = ode45(@(t, X) HH_with_forcing(t, X, I0, A, f), tspan, Y);
    
    X = xsol(end, :)';
    Y = ysol(end, :)';
    
    % Compute new separation
    delta_vec = Y - X;
    dist = norm(delta_vec);
    
    % Renormalize
    delta_vec = delta0 * delta_vec / dist;
    Y = X + delta_vec;
    
    % Accumulate Lyapunov estimate
    lyap_sum = lyap_sum + log(dist / delta0);
end

% Estimate of largest Lyapunov exponent
lambda = lyap_sum / (steps * dt);
fprintf('Largest Lyapunov Exponent: %.5f\n', lambda);

function dydt = HH_with_forcing(t, y, Cm, gNa, gK, gL, ENa, EK, EL, I0, A, f)
    V = y(1); m = y(2); h = y(3); n = y(4);

    % Periodic forcing term
    Iext = I0 + A * sin(2 * pi * f * t / 1000);  % Convert t to seconds

    % Rate constants
    alpha_m = 0.1 * (V + 40) / (1 - exp(-(V + 40)/10));
    beta_m  = 4 * exp(-(V + 65)/18);
    alpha_h = 0.07 * exp(-(V + 65)/20);
    beta_h  = 1 / (1 + exp(-(V + 35)/10));
    alpha_n = 0.01 * (V + 55) / (1 - exp(-(V + 55)/10));
    beta_n  = 0.125 * exp(-(V + 65)/80);

    % Gating dynamics
    dmdt = alpha_m * (1 - m) - beta_m * m;
    dhdt = alpha_h * (1 - h) - beta_h * h;
    dndt = alpha_n * (1 - n) - beta_n * n;

    % Ion currents
    INa = gNa * m^3 * h * (V - ENa);
    IK  = gK * n^4 * (V - EK);
    IL  = gL * (V - EL);

    % Membrane potential
    dVdt = (Iext - INa - IK - IL) / Cm;

    dydt = [dVdt; dmdt; dhdt; dndt];
end
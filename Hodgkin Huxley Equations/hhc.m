function hodgkin_huxley_chaos
    % Parameters
    Cm = 1;      gNa = 120;    gK = 36;     gL = 0.3;
    ENa = 50;    EK = -77;     EL = -54.4;
    Iext = 10;   % External current (uA/cm²)

    % Initial conditions (slightly perturbed)
    y1 = [-65; 0.05; 0.6; 0.32];       % Original
    y2 = y1 + 1e-6 * randn(4, 1);      % Perturbed

    

    % Time span (long enough to capture divergence)
    tspan = [0 10000];

    % Solve ODEs for both trajectories
    [t1, y1] = ode45(@(t, y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext), tspan, y1);
    [t2, y2] = ode45(@(t, y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext), tspan, y2);

    % Interpolate trajectories to common time points
    t_common = linspace(tspan(1), tspan(2), min(length(t1), length(t2)));
    y1_interp = interp1(t1, y1, t_common);
    y2_interp = interp1(t2, y2, t_common);

    % Calculate Euclidean distance between trajectories
    distance = sqrt(sum((y1_interp - y2_interp).^2, 2));

    % Plot divergence of trajectories
    figure;
    semilogy(t_common, distance, 'LineWidth', 1.5);
    xlabel('Time (ms)'), ylabel('Distance (log scale)');
    title('Divergence of Trajectories (Lyapunov Exponent)');
    grid on;

    % Estimate Lyapunov exponent (slope of log-distance)
    p = polyfit(t_common(t_common > 100), log(distance(t_common > 100)), 1);
    lyapunov = p(1);
    disp(['Estimated Lyapunov Exponent: ', num2str(lyapunov)]);

    Iext_values = linspace(5, 15, 100);
    for i = 1:length(Iext_values)
        [~, y1] = ode45(@(t, y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext_values(i)), tspan, y1);
        V_steady = y(end-100:end, 1); % Discard transients
        plot(Iext_values(i) * ones(size(V_steady)), V_steady, 'k.', 'MarkerSize', 1);
        hold on;
    end
    xlabel('I_{ext} (µA/cm²)'), ylabel('V (mV)');
end

function dydt = hh_ode(~, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext)
    V = y(1); m = y(2); h = y(3); n = y(4);

    % Rate constants (voltage-dependent)
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

    % Membrane potential dynamics
    dVdt = (Iext - INa - IK - IL) / Cm;

    dydt = [dVdt; dmdt; dhdt; dndt];
end
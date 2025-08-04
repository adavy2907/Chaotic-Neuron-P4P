function plot_lyapunov_vs_Iext()
    % Parameters for HH model
    Cm = 1.0;
    gNa = 120.0;
    gK = 36.0;
    gL = 0.3;
    ENa = 50.0;
    EK = -77.0;
    EL = -54.4;
    y0 = [-65; 0.05; 0.6; 0.32];

    % External current range
    Iext_values = linspace(5, 15, 100);
    lambda_vals = zeros(size(Iext_values));

    % Iterate over Iext values
    for i = 1:length(Iext_values)
        lambda_vals(i) = lyapunov_HH(Cm, gNa, gK, gL, ENa, EK, EL, y0, Iext_values(i));
    end

    % Plot
    figure;
    plot(Iext_values, lambda_vals, 'b');
    hold on;
    yline(0, '--k');
    area(Iext_values, lambda_vals .* (lambda_vals > 0), 'FaceColor', 'r', 'FaceAlpha', 0.3);
    xlabel('I_{ext}');
    ylabel('\lambda_{max}');
    title('Lyapunov Exponent vs External Current');
    grid on;
end

function lambda_max = lyapunov_HH(Cm, gNa, gK, gL, ENa, EK, EL, y0, I0)
    % Integrate base trajectory
    T = 200; dt = 0.01;
    tspan = 0:dt:T;
    y = y0;
    delta0 = 1e-8;
    delta = [delta0; zeros(3,1)];
    sum_log = 0; count = 0;

    for t = tspan(1:end-1)
        % Integrate reference
        y1 = rk4(@(y) hh_vecfield(y, Cm, gNa, gK, gL, ENa, EK, EL, I0), y, dt);

        % Perturb and integrate
        yp = y + delta;
        yp1 = rk4(@(y) hh_vecfield(y, Cm, gNa, gK, gL, ENa, EK, EL, I0), yp, dt);

        % Compute new separation
        delta = yp1 - y1;
        norm_d = norm(delta);
        if norm_d == 0
            norm_d = delta0;
        end

        % Renormalize
        delta = delta0 * delta / norm_d;

        if t > T/2
            sum_log = sum_log + log(norm_d / delta0);
            count = count + 1;
        end

        y = y1;
    end

    lambda_max = sum_log / (count * dt);
end

function dy = hh_vecfield(y, Cm, gNa, gK, gL, ENa, EK, EL, Iext)
    V = y(1); m = y(2); h = y(3); n = y(4);

    % Rate constants
    alpha_m = 0.1 * (V + 40) / (1 - exp(-(V + 40)/10));
    beta_m = 4 * exp(-(V + 65)/18);
    alpha_h = 0.07 * exp(-(V + 65)/20);
    beta_h = 1 / (1 + exp(-(V + 35)/10));
    alpha_n = 0.01 * (V + 55) / (1 - exp(-(V + 55)/10));
    beta_n = 0.125 * exp(-(V + 65)/80);

    dmdt = alpha_m * (1 - m) - beta_m * m;
    dhdt = alpha_h * (1 - h) - beta_h * h;
    dndt = alpha_n * (1 - n) - beta_n * n;

    INa = gNa * m^3 * h * (V - ENa);
    IK  = gK * n^4 * (V - EK);
    IL  = gL * (V - EL);

    dVdt = (Iext - INa - IK - IL) / Cm;

    dy = [dVdt; dmdt; dhdt; dndt];
end

function y_next = rk4(f, y, dt)
    k1 = f(y);
    k2 = f(y + 0.5 * dt * k1);
    k3 = f(y + 0.5 * dt * k2);
    k4 = f(y + dt * k3);
    y_next = y + (dt / 6) * (k1 + 2*k2 + 2*k3 + k4);
end

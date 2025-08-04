% Lyapunov Exponent Analysis for Hodgkin-Huxley and Nagumo-Sato Models

% === Hodgkin-Huxley Parameters ===
Cm = 1.0;      % μF/cm^2
gNa = 120.0;   % mS/cm^2
gK = 36.0;
gL = 0.3;
ENa = 50.0;    % mV
EK = -77.0;
EL = -54.387;

% Initial conditions
y0 = [-65, 0.05, 0.6, 0.32];

% === Lyapunov Exponent Calculation for HH Model ===
Iext_vals = linspace(5, 15, 100);
lyap_vals_HH = zeros(size(Iext_vals));

for i = 1:length(Iext_vals)
    Iext = Iext_vals(i);
    [~, lyap] = hh_lyapunov(@(t,y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext), y0);
    lyap_vals_HH(i) = lyap;
end

% === Plot HH Lyapunov Spectrum ===
figure;
plot(Iext_vals, lyap_vals_HH, 'b');
hold on;
plot(Iext_vals, zeros(size(Iext_vals)), 'k--');
fill_between = @(x, y) area(x, y.*(y>0), 'FaceColor', 'r', 'FaceAlpha', 0.3, 'EdgeAlpha', 0);
fill_between(Iext_vals, lyap_vals_HH);
xlabel('I_{ext} (External Current)'); ylabel('\lambda (Lyapunov Exponent)');
title('Lyapunov Exponent vs I_{ext} for Hodgkin-Huxley'); grid on;


% === Nagumo-Sato Model Parameters ===
a = 0.7; b = 0.8; tau = 12.5; % typical values
x0 = [0.0; 0.0];
I_vals = linspace(-1, 1, 200);
lyap_vals_NS = zeros(size(I_vals));

for i = 1:length(I_vals)
    Iext = I_vals(i);
    [~, lyap] = hh_lyapunov(@(t,y) nagumo_sato_ode(t, y, a, b, tau, Iext), x0);
    lyap_vals_NS(i) = lyap;
end

% === Plot Nagumo-Sato Lyapunov Spectrum ===
figure;
plot(I_vals, lyap_vals_NS, 'm');
hold on;
plot(I_vals, zeros(size(I_vals)), 'k--');
fill_between(I_vals, lyap_vals_NS);
xlabel('I_{ext} (External Current)'); ylabel('\lambda (Lyapunov Exponent)');
title('Lyapunov Exponent vs I_{ext} for Nagumo-Sato Model'); grid on;


% === ODE Functions ===
function dydt = hh_ode(~, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext)
    V = y(1); m = y(2); h = y(3); n = y(4);
    alpha_m = 0.1*(V+40)/(1-exp(-(V+40)/10));
    beta_m = 4*exp(-(V+65)/18);
    alpha_h = 0.07*exp(-(V+65)/20);
    beta_h = 1/(1+exp(-(V+35)/10));
    alpha_n = 0.01*(V+55)/(1-exp(-(V+55)/10));
    beta_n = 0.125*exp(-(V+65)/80);
    dmdt = alpha_m*(1-m) - beta_m*m;
    dhdt = alpha_h*(1-h) - beta_h*h;
    dndt = alpha_n*(1-n) - beta_n*n;
    INa = gNa * m^3 * h * (V - ENa);
    IK = gK * n^4 * (V - EK);
    IL = gL * (V - EL);
    dVdt = (Iext - INa - IK - IL) / Cm;
    dydt = [dVdt; dmdt; dhdt; dndt];
end

function dydt = nagumo_sato_ode(~, y, a, b, tau, Iext)
    v = y(1); w = y(2);
    dvdt = v - v^3 / 3 - w + Iext;
    dwdt = (v + a - b * w) / tau;
    dydt = [dvdt; dwdt];
end

function [T, le] = hh_lyapunov(f, y0)
    dt = 0.01; Tmax = 500; Tspan = 0:dt:Tmax;
    delta0 = 1e-8;
    y = y0(:); y2 = y + delta0 * randn(size(y));
    sumlog = 0;
    for t = Tspan
        k1 = f(t, y);      k2 = f(t, y2);
        y = y + dt * k1;   y2 = y2 + dt * k2;
        delta = norm(y2 - y);
        if delta == 0
            le = -Inf; return;
        end
        sumlog = sumlog + log(delta / delta0);
        y2 = y + delta0 * (y2 - y) / norm(y2 - y);
    end
    le = sumlog / Tmax;
    T = Tspan;
end

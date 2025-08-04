% Hodgkin-Huxley Bifurcation Diagram with Periodic Forcing

% Parameters
Cm = 1;       % Membrane capacitance (uF/cm^2)
gNa = 120;    % Sodium conductance (mS/cm^2)
gK  = 36;     % Potassium conductance (mS/cm^2)
gL  = 0.3;    % Leak conductance (mS/cm^2)
ENa = 50;     % Sodium reversal potential (mV)
EK  = -77;    % Potassium reversal potential (mV)
EL  = -54.4;  % Leak reversal potential (mV)

% Initial conditions: [V, m, h, n]
y0 = [-65, 0.05, 0.6, 0.32];

% Periodic forcing parameters
A = 5;           % Forcing amplitude
f = 3;          % Frequency (Hz)

% Preallocate for bifurcation diagram
all_Iext = [];
all_V = [];

I0_values = linspace(5, 15, 200);  % Baseline currents
tspan = [0 100];                   % Simulation time (ms)

% Loop over I0 values
for i = 1:length(I0_values)
    I0 = I0_values(i);  % Baseline component of Iext

    % Integrate ODE with periodic forcing
    [t, y] = ode45(@(t, y) hh_ode_forced(t, y, Cm, gNa, gK, gL, ENa, EK, EL, I0, A, f), tspan, y0);
    
    V_steady = y(end-100:end, 1);  % Last 100 time points
    
    all_Iext = [all_Iext; repmat(I0, length(V_steady), 1)];
    all_V = [all_V; V_steady];
end

% Plot bifurcation diagram
figure;
scatter(all_Iext, all_V, 1, 'k', 'filled');
xlabel('I_0 (baseline external current)');
ylabel('Steady-State V (mV)');
title('Bifurcation Diagram with Periodic Forcing');
grid on;

% -------------------------------
% HH model with periodic forcing
% -------------------------------
function dydt = hh_ode_forced(t, y, Cm, gNa, gK, gL, ENa, EK, EL, I0, A, f)
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

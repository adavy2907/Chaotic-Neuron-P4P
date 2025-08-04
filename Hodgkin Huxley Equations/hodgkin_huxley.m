function hodgkin_huxley
    % Parameters
    Cm = 1;         % Membrane capacitance (uF/cm^2)
    gNa = 120;      % Sodium conductance (mS/cm^2)
    gK = 36;        % Potassium conductance (mS/cm^2)
    gL = 0.3;       % Leak conductance (mS/cm^2)
    ENa = 50;       % Sodium reversal potential (mV)
    EK = -77;       % Potassium reversal potential (mV)
    EL = -54.387;   % Leak reversal potential (mV)
    Iext = 10;      % External current (uA/cm^2)

    % Initial conditions
    V0 = -65;       % Initial membrane potential (mV)
    m0 = 0.05;      % Initial m gate
    h0 = 0.6;       % Initial h gate
    n0 = 0.32;      % Initial n gate
    y0 = [V0; m0; h0; n0];

    % Time span
    tspan = [0 100]; % Simulation time (ms)

    % Solve the ODEs
    [t, y] = ode45(@(t, y) hh_ode(t, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext), tspan, y0);

    % Plot results
    figure;
    plot(t, y(:, 1), 'k', 'LineWidth', 1.5);
    xlabel('Time (ms)');
    ylabel('Membrane Potential (mV)');
    title('Hodgkin-Huxley Model');
    grid on;
end

function dydt = hh_ode(~, y, Cm, gNa, gK, gL, ENa, EK, EL, Iext)
    % Extract variables
    V = y(1);
    m = y(2);
    h = y(3);
    n = y(4);

    % Rate constants
    alpha_m = 0.1 * (V + 40) / (1 - exp(-(V + 40)/10));
    beta_m = 4 * exp(-(V + 65)/18);
    alpha_h = 0.07 * exp(-(V + 65)/20);
    beta_h = 1 / (1 + exp(-(V + 35)/10));
    alpha_n = 0.01 * (V + 55) / (1 - exp(-(V + 55)/10));
    beta_n = 0.125 * exp(-(V + 65)/80);

    % Gating variable dynamics
    dmdt = alpha_m * (1 - m) - beta_m * m;
    dhdt = alpha_h * (1 - h) - beta_h * h;
    dndt = alpha_n * (1 - n) - beta_n * n;

    % Ionic currents
    INa = gNa * m^3 * h * (V - ENa);
    IK = gK * n^4 * (V - EK);
    IL = gL * (V - EL);

    % Membrane potential dynamics
    dVdt = (Iext - INa - IK - IL) / Cm;

    % Return derivatives
    dydt = [dVdt; dmdt; dhdt; dndt];
end
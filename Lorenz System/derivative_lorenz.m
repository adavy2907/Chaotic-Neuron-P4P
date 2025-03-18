% Define the Lorenz system derivative function
function dydt = derivative_lorenz(t, y, sigma, rho, beta)
    dydt = zeros(3,1);
    dydt(1) = sigma * (y(2) - y(1));
    dydt(2) = y(1) * (rho - y(3)) - y(2);
    dydt(3) = y(1) * y(2) - beta * y(3);
end
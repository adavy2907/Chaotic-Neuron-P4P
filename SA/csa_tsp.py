"""
CSA TSP

Usage:
  csa_tsp.py TSP_FILE --nruns=N --maxiter=M [--energy] [--percent] [--length]
                      [--k=K] [--epsilon=E] [--I0=I] [--z0=Z] [--W1=W1] [--W2=W2]
                      [--alpha=A] [--beta=B]
  csa_tsp.py -h | --help
  csa_tsp.py --version

Options:
  -h --help        Show this screen.
  --version        Show version.
  --nruns=N        Number of runs.
  --maxiter=M      Maximum iterations.
  --energy         Plot energy.
  --percent        Plot percent valid.
  --length         Plot tour length.
  --k=K            Constant k.
  --epsilon=E      Constant epsilon.
  --I0=I           Constant I0.
  --z0=Z           Constant z0.
  --W1=W1          Constant W1.
  --W2=W2          Constant W2.
  --alpha=A        Constant alpha.
  --beta=B         Constant beta.
"""

from docopt import docopt

args = docopt(__doc__,version="CSA TSP 1.0")
print("Running CSA TSP with args %s" % args)

import tcnn
import tsplib
import matplotlib.pyplot as plt
import numpy as np

N_RUNS = int(args["--nruns"])
MAX_IT = int(args["--maxiter"])
plot_energy = args["--energy"]
plot_percent_valid = args["--percent"]
plot_tour_length = args["--length"]
tsp_file = args["TSP_FILE"]
constants = {
    "k": float(args["--k"]),
    "epsilon": float(args["--epsilon"]),
    "I0": float(args["--I0"]),
    "z0": float(args["--z0"]),
    "W1": float(args["--W1"]),
    "W2": float(args["--W2"]),
    "alpha": float(args["--alpha"]),
    "beta": float(args["--beta"])
}

attrs = ["iter"]
n_plots = 0
if plot_energy:
    n_plots += 1
    attrs.append("energy")
    
if plot_tour_length:
    n_plots += 1
    
if plot_percent_valid:
    n_plots += 1
    attrs.append("percent_valid")

distances = tsplib.distance_matrix(tsp_file)

tour_lengths = []
for i in range(N_RUNS):
    net = tcnn.TCNN(distances, **constants)
    results = net.run(maxiter = MAX_IT, collecting = attrs)
    I = results["iter"]
    
    if net.valid_tour():
        l = net.tour_length()
        tour_lengths.append(l)
        print("run %d converged by step %d, length = %f" % (i, I[-1],l))

        # Plot the tour
        tour = net.tour()
        n = len(tour)
        # Arrange cities in a circle if no coordinates are available
        angles = np.linspace(0, 2*np.pi, n, endpoint=False)
        city_coords = np.column_stack((np.cos(angles), np.sin(angles)))
        tour_coords = city_coords[tour + [tour[0]]]  # Close the loop

    else:
        print("run %d did not converge by step %d" % (i,I[-1]))
    
    cur_plot = 1
    if plot_percent_valid:
        plt.subplot(n_plots, 1, cur_plot)
        plt.plot(I, results["percent_valid"])
        plt.xlabel('Iteration')
        plt.ylabel('Percent valid')
        cur_plot += 1
    
    if plot_energy:
        plt.subplot(n_plots, 1, cur_plot)
        plt.plot(I[3:], results["energy"][3:])
        plt.xlabel('Iteration')
        plt.ylabel('Energy')
        cur_plot += 1

if plot_tour_length:
    # nbins = int(np.floor(N_RUNS/np.log2(N_RUNS)))
    nbins = N_RUNS
    plt.subplot(n_plots, 1, cur_plot)
    plt.boxplot(tour_lengths, orientation='horizontal')
    plt.xlabel('Tour Lengths')    
    cur_plot += 1

    plt.figure(figsize=(6,6))
    plt.plot(tour_coords[:,0], tour_coords[:,1], 'o-', label='Tour')
    for idx, (x, y) in enumerate(city_coords):
        plt.text(x, y, str(idx), fontsize=12, ha='center', va='center', color='red')
    plt.title("Completed TSP Tour (Run %d)" % i)
    plt.axis('equal')
    plt.legend()

if n_plots > 0:
    plt.show()


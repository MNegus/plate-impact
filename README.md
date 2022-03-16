Code for conducting direct numerical simulations for droplet impact onto 
spring-supported plates using [Basilisk](<http://basilisk.fr/>). Used in 
producing the results for our recent paper [Droplet impact onto a spring-supported plate: analysis and simulations](<https://link.springer.com/article/10.1007/s10665-021-10107-5/>) in the Journal of Engineering Mathematics.

Contributors: [Michael Negus](<https://www.maths.ox.ac.uk/people/michael.negus>), [Radu Cimpeanu](<https://warwick.ac.uk/fac/sci/maths/people/staff/cimpeanu/>), [Matthew Moore](<https://www.hull.ac.uk/staff-directory/matthew-moore>), [James Oliver](<https://www.maths.ox.ac.uk/people/james.oliver>)

![Program Screenshot](assets/images/dns_set_up.jpg)


# Installation
* A recent installation of [Basilisk](<http://basilisk.fr/>) is required to run 
the simulations, see [here](<http://basilisk.fr/src/INSTALL>) for installation
instructions for Basilisk. 
* The [additional packages for visualisation](<http://basilisk.fr/src/gl/INSTALL>) 
are also required if you wish to produce movies of the simulations, however this
option can be turned off if you do not wish to install the additional packages.
* An installation of [gfsview](http://gfs.sourceforge.net/wiki/index.php/Main_Page) 
is also recommended for visualising the gfs_output files.
* Most of the data analysis files are written in MATLAB, however the data 
output of the Basilisk scripts are in a general form that any data analysis
toolset can be used.


# Tutorial
Below we give a brief tutorial as to how to run a simulation. Although not strictly
required, familiarity with Basilisk (at least up until the point you can run
the [tutorial](<http://basilisk.fr/Tutorial>) is very useful. 

## Example run
As an example, the code in the `example_run` directory is immediately ready to be
run. In the command line, enter the directory `example_run/code` and run the command
```shell
./run_simulation droplet_impact_plate 
```
After a bunch of text initialising the Makefiles, you should eventually see
```shell
[droplet_impact_plate.tst]
```
which indicates the code is running! This example will run the simulation for 
a maximum refinement level of 6, with plate parameters `ALPHA = 2`, `BETA = 0` and 
`GAMMA = 500` up until `t = 0.8`. During run-time, the output will be in a directory
called `droplet_impact_plate`, and if you want to check how things are going then
open the file named `log`, which will output various quantities for `t += 1e-4`. 

Calling the above command will run the code on one core only, which is very 
slow! To run the code on `N` cores, you need to run
```shell
./run_simulation droplet_impact_plate N
```
It is recommended to make `N` a power of 2 (e.g. 2, 4, 8, 16, ...) for optimal
load balancing. The time it takes to run will depend on your computational setup,
but for 4 cores you can expect the run to take around 20 minutes. Because of this,
it is wise to make the simulation run in the background, to prevent losing your
progress if you close the terminal window. To do this, run the command
```shell
nohup ./run_simulation droplet_impact_plate N &
```
Here the command `nohup` sends what would have been outputted to the command line 
into a file called `nohup.out`, and the & sign suppresses the terminal output. This
means that the code is running in the background and you can safely close all 
terminal windows. When you run this command, you'll get a command line message 
that looks something like
```shell
[1] 22791
nohup: ignoring input and appending output to 'nohup.out'    
```
In this case, the PID of the process is 22791. It is worth noting this, as if you
wish to end the process early, you'll need to use the command
```shell
kill -s TERM 22791   
```
where of course replace the 22791 with the PID you were given.

At the end of the simulation, all of the output will be moved into a directory
called `raw_data` in the example_run directory, so the contents of example_run are
the code and the `raw_data` directories. We'll discuss what to do with this data
in the following sections. 

## Specifying your own parameters
The example code runs the code with a relatively coarse grid (with `MAXLEVEL = 6`,
while the results in the paper have `MAXLEVEL = 13`). In order to change parameters 
such as the maximum refinement level, you need to edit the values in the `parameters.h`
file found in the `utility_scripts` directory. This script contains all of the
parameters used in the code, both physical parameters like the properties of the
plate, and computational parameters like the refinement level.

In its current form, the parameters script is set up with the values that were
used to produce the results in the paper. In terms of computational options such
as the refinement level, things should be kept the same. However note that with
`MAXLEVEL = 13`, the code takes about 8 hours to run on 8 cores, so this may want
to be reduced while getting to grips with the code. 

The main parameters that you'd want to change are the plate parameters `ALPHA`, 
`BETA` and `GAMMA`, as these change the properties of the plate as seen in the figures
in the paper. As well as these, it is also important to run the control case, where
the plate is held stationary. In this case, you'd set the `CONST_ACC` flag to 1,
which will set the acceleration of the plate to the constant value given by 
`PLATE_ACC`. If `PLATE_ACC = 0` (as it is by default), then the plate will be 
stationary and this will provide the parameters for the test case.

Apart from these, feel free to look at the other parameters listed in `parameters.h`, 
and find out how they're used in the `droplet_impact_plate.c` script. 

Once you've set the parameters as desired in `parameters.h`, you'd want to run the
code! First, you'll need to copy the scripts into a different directory on your
system (preferably one with plenty of disk space). Say you want to run your
code in a folder called `myRun` inside a parent directory called `parentDir`; then 
enter the `utility_scripts` directory and run the command
```shell
./code_copy.sh ../droplet_impact_plate parentDir myRun
```
This will create a directory called `myRun` inside `parentDir`, and inside `myRun`
there will be a sub-directory called code containing the scripts: `droplet_impact_plate.c`, 
`Makefile`, `parameters.h` and `run_simulation.sh`. This is the exact setup that
was in your original `example_run/code` directory. This script is ready to be
run in the exact way you did for the example, and running 
```shell
nohup ./run_simulation droplet_impact_plate N &
```
should kick off the simulation! 

## Understanding the data output



<!-- ## The problem
* We wish to study the dynamics of droplets impacting onto deformable substrates, such as elastic sheets or cling film (see [Splashing on elastic membranes: The importance of early-time dynamics](<https://aip.scitation.org/doi/full/10.1063/1.2969755>)).
* As a first step towards this goal, we would like to conduct simulations of impact onto flat plates which are restricted to moving in the vertical direction
* This requires embedding a solid into the computational domain of the problem
* Basilisk currently only supports embedding solids in two-phase problems when only one of the phases makes contact with the solid (such as [flow over a bump](<http://basilisk.fr/src/examples/gaussian-ns.c>))
* The issue here is that both the air and the liquid phase will meet the substrate during droplet impact, so we cannot embed a solid in the same way that is currently implemented in Basilisk

## Proposed solution
* We can create artifical solids by using "Stephane's Trick", which was used to [move a cylinder through a liquid](<http://basilisk.fr/sandbox/popinet/movingcylinder.c>)
* The idea is to create another volume fraction (here we call it plate[]), which is 1 inside the plate and 0 outside of the plate
* In order for the plate to act as a solid, we need to impose the kinematic condition on the velocity (that is the vertical velocity of the fluid needs to match the plate speed)

## Goal
Conduct simulations of axisymmetric droplet impact onto a moving plate, where the displacement of the plate is determined by the forces felt on it from the droplet. In particular, we wish to model the problem of a plate being suspended by a spring and a dashpot, in order to study how elastic and dissipative effects on the movement affect the dynamics of the droplet. 

## Structure of repository
* This repository is to document the progress we are making into studying impact onto moving plates. Each sub directory documents a different task to complete in order to solve the eventual problem of impact onto a plate-spring-dashpot system -->
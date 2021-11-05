%% Setup

clear;
clc;
clf;
rng(0);

%% Simulation Parameters

f = "sample-input-3.txt";
realTime = false;

%% Run
sim = Simulation(f, realTime);
sim.run();

%% Show results
sim.showResults();

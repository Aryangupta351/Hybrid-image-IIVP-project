% Clear everything i.e. memory, console, etc. and close all opened images
clear; clc; close all;

% Input folder
inputSet = './input/';

% Input image pairs for creating a Hybrid image;
HybridImage([inputSet,'1.jpg'], [inputSet,'2.jpg']);
HybridImage([inputSet,'3.jpg'], [inputSet,'4.jpg']);
HybridImage([inputSet,'Sad.jpg'], [inputSet,'Surprise.jpg']);
HybridImage([inputSet,'5.jpg'], [inputSet,'6.jpg']);
HybridImage([inputSet,'7.jpg'], [inputSet,'8.jpg']);


% gramm examples and how-tos
% Using different input formats for x and y 


%% Standard ggplot-like input (arrays for everything)
% Note the continuous line connecting all blue data points, gramm can't know
% when to start a new line in this case

Y=[1 2 3 4 5 2 3 4 5 6 3 4 5 6 7];
X=[1 2 3 4 5 0 1 2 3 4 -1 0 1 2 3];
C=[1 1 1 1 1 2 2 2 2 2 2 2 2 2 2];
figure
g11=gramm('x',X,'y',Y,'color',C);
g11.geom_line();
g11.set_title('X, Y; and color arrays');
g11.draw();

%% Using a 'group' array to separate lines

Y=[1 2 3 4 5 2 3 4 5 6 3 4 5 6 7];
X=[1 2 3 4 5 0 1 2 3 4 -1 0 1 2 3];
C=[1 1 1 1 1 2 2 2 2 2 2 2 2 2 2];
% Adding a group variable solves the problem in a ggplot-like way
G=[1 1 1 1 1 2 2 2 2 2 3 3 3 3 3];
figure
g12=gramm('x',X,'y',Y,'color',C,'group',G);
g12.geom_line();
g12.set_title('X, Y, and color arrays + group array');
g12.draw();

%% For a more matlab-like solution, Y and X can be 2D arrays, rows will automatically be considered as groups.
% As a consequence grouping data (color, etc...) are provided for the rows !

Y=[1 2 3 4 5;2 3 4 5 6; 3 4 5 6 7];
X=[1 2 3 4 5; 0 1 2 3 4; -1 0 1 2 3];
C=[1 2 2];
figure
g13=gramm('x',X,'y',Y,'color',C);
g13.geom_line();
g13.set_title('X and Y matrices + color array');
g13.draw();

%% If all X values are the same, it's possible to provide X as a single row

X=[1 2 3 4 5];
Y=[1 2 3 4 5;2 3 4 5 6; 3 4 5 6 7];
C=[1 2 2];
figure
g14=gramm('x',X,'y',Y,'color',C);
g14.geom_line();
g14.set_title('single X row + Y matrix + color array');
g14.draw();

%% Similar results can be obtained with cells of arrays

Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]};
X={[1 2 3 4 5] [0 1 2 3 4] [-1 0 1 2 3]};
C=[1 2 2];
figure
g15=gramm('x',X,'y',Y,'color',C);
g15.geom_line();
g15.set_title('X and Y cells of arrays + color array');
g15.draw();

Y={[1 2 3 4 5] [2 3 4 5 6] [3 4 5 6 7]};
X=[1 2 3 4 5];
figure
g16=gramm('x',X,'y',Y,'color',C);
g16.geom_line();
g16.set_title('single X row + Y cell of arrays + color array');
g16.draw();


%% With cells of arrays, there is the opportunity to have different lengths for different groups

Y={[1 2 3 4 5] [3 4 5] [3 4 5 6 7]};
X={[1 2 3 4 5] [1 2 3] [-1 0 1 2 3]};
C=[1 2 2];
figure
g17=gramm('x',X,'y',Y,'color',C);
g17.geom_line();
g17.set_title('X and Y cells of arrays of different lengths + color array');
g17.draw();

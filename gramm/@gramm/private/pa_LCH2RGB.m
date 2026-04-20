function RGB = pa_LCH2RGB(LCH,adobeRGB)
% RGB = PA_LCH2RGB(LCH)
%
% Convert LCH colours to RGB colours
%
% For formulas, see:
% http://easyrgb.com/index.php?X=MATH
%
% For those with the Image Processing toolbox:
% http://www.mathworks.nl/help/images/converting-color-data-between-color-spaces.html
%
% For a superior m-file:
% http://www.mathworks.nl/matlabcentral/fileexchange/28790-colorspace-transformations
%
% Why use LCH?
% http://www.biostat.jhsph.edu/bit/compintro/bruce/RGBland.pdf
%
% Or Wikipedia
% https://en.wikipedia.org/wiki/Lab_color_space

% 2013 Marc van Wanrooij (marcvanwanrooij@neural-code.com)
% modified by Pierre Morel 2016

if nargin<1
    ncol	= 64;
    l		= linspace(0,1,ncol);
    H		= repmat(300,1,ncol);
    C		= zeros(1,ncol);
    L		= 90-l*30;
    LCH		= [L;C;H]';
    LCH = LCH(1:15,:);
    close all
end
if nargin <2
    adobeRGB=false; %We use sRGB by default
end

%% Convert CIE L*CH to CIE L*ab
L = LCH(:,1);
C = LCH(:,2);
H = LCH(:,3);
a = cos(H*pi/180).*C;
b = sin(H*pi/180).*C;

%% CIE-L*ab -> XYZ
% https://en.wikipedia.org/wiki/Lab_color_space
% Y	= (L+16)/116;
% X	= Y+a/500;
% Z	= Y-b/200;
% XYZ = [X Y Z];
% 
% sel			= XYZ>6/29;
% XYZ(sel)	= XYZ(sel).^3;
% XYZ(~sel)	= (XYZ(~sel)-4/29)*3*(6/29)^2;

%% Different L*ab -> XYZ from http://www.brucelindbloom.com/index.html?Eqn_Lab_to_XYZ.html

f_y=(L+16)/116;
f_x	= f_y+a/500;
f_z	= f_y-b/200;

epsilon=0.008856;
kappa=903.3;

X=f_x.^3;
sel=f_x.^3<=epsilon;
X(sel)=(116*f_x(sel)-16)/kappa;

Y=((L+16)/116).^3;
sel=L<=(kappa*epsilon);
Y(sel)=L(sel)/kappa;

Z=f_z.^3;
sel=f_z<=epsilon;
Z(sel)=(116*f_z(sel)-16)/kappa;

XYZ = [X Y Z];

%% Reference white point (D65)

ref	=  [95.05, 100.000, 108.90]/100;
XYZ =  bsxfun(@times,XYZ,ref);

%% XYZ -> RGB
% Conversion/transformation matrix
% https://en.wikipedia.org/wiki/CIE_1931_color_space
% http://en.wikipedia.org/wiki/SRGB

if adobeRGB
    %adobeRGB (from
    %http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html)
    T= [ 2.0413690, -0.5649464, -0.3446944;...
        -0.9692660,  1.8760108,  0.0415560;...
        0.0134474, -0.1183897,  1.0154096];
    
    RGB		= XYZ*T';
    
    % Gamma correction to convert RGB to adobe RGB
    RGB=RGB.^(1/2.2);

else
    %sRGB
    T=[3.2406, -1.5372, -0.4986;...
        -0.9689, 1.8758, 0.0415;...
        0.0557, -0.2040, 1.0570];
    
    RGB		= XYZ*T';
    
    % Gamma correction to convert RGB to sRGB
    sel			= RGB>0.0031308; % colorspace: 0.0031306684425005883
    RGB(sel)	= 1.055*(RGB(sel).^(1/2.4))-0.055;
    RGB(~sel)	= 12.92*RGB(~sel);
end


%% Final check
% [I,J]			= find(RGB>1); %#ok<*NASGU>
% RGB(I,:)		= repmat([1 1 1],numel(I),1);
% [I,J]			= find(RGB<0);
% RGB(I,:)		= repmat([1 1 1],numel(I),1);

%% Clip values
sel			= RGB>1;
RGB(sel)	= 1;
sel			= RGB<0;
RGB(sel)	= 0;



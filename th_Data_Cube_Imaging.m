clear;
close;
load('DataCube.mat');
DataCube = xrv;
nfft_r = 2^nextpow2(size(xrv,1));
nfft_d = 2^nextpow2(size(xrv,3));
fc = 77e9;
fs = 40e6;
SweepTime = 100e-6;
SweepBandwidth = 4e9;
Nt = 2;
Nr = 6;
RD_Th = -5;

[TargetNum TargetInfomation] = Data_Cube_Imaging_0906(DataCube,...
                                     nfft_r,...
                                     nfft_d,...
                                     fc,...
                                     fs,...
                                     SweepTime,...
                                     SweepBandwidth,...
                                     Nt,...
                                     Nr,...
                                     RD_Th);
TargetLocation_cart = zeros(3,TargetNum);
[TargetLocation_cart(1,:) TargetLocation_cart(2,:) TargetLocation_cart(3,:)] = sph2cart(TargetInfomation(1,:),TargetInfomation(2,:),TargetInfomation(3,:));
figure(1)
scatter3(TargetLocation_cart(1,:)',TargetLocation_cart(2,:)',TargetLocation_cart(3,:)');
xlabel('X');
ylabel('Y');
zlabel('Z');



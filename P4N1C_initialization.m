% P4N1C_initialization.m
% 2017.08.21 MPT
% A Walrus & Cake Endeavor (TM)
%
% Temporarily coded in MATLAB
%
% Intended to:
% > Load in timeseries history for a given coin (e.g. XYZ here)
% > Pick and extract a random subset to use for preview & simulation
% > Data prep: Scale to today's Exchange price
% > Data prep: Noise (optional)
% > Data prep: Scale so preview ATH = XYZcoin ATH
% > Some diagnostic plotting, much for troubleshooting not final UI.

%% I/O
load('DemoFrostingXYZ.mat')

% Extract the Exchange price values (using data from each day's close)
TimeSeries = DemoFrostingXYZ.Close;
DateStrings = DemoFrostingXYZ.Date;

% Note that I don't even bother extracting the date info, since we're just
% going to take a random subcut anyways.

%% Parameters
%
%%%%%%%%%%%%%%%%%%%%%
% USER INPUTS:
% Here are the parameters that the user will set in the UI
% I will just hardcode arbitrary defaults for now
UserParameters.nDaysPreview = 75;
UserParameters.nDaysSimulation = 50;
UserParameters.initialWalletUSD = 1000;
UserParameters.initialWalletXYZ = 1.5;
UserParameters.booleanNoise = 1;


%%%%%%%%%%%%%%%%%%%%%
% Behind The Scenes
%% STEP 1 -- Cut out a subset of the time series to use for each instance of the simulation
TimeSeriesLength = length(TimeSeries);
SubsetLength = UserParameters.nDaysPreview + UserParameters.nDaysSimulation;
SubsetStartIndex = floor((TimeSeriesLength-SubsetLength)*rand());

% Extract the data for the simulation. This includes both the preview
% period and the simulation period
TimeSeriesSubset = TimeSeries(SubsetStartIndex+[1:SubsetLength]);
TimeSeriesTimeline = ((-UserParameters.nDaysPreview+1):(UserParameters.nDaysSimulation))'; % e.g. -59 --> +30

%% STEP 2 -- Scale to resemble today's prices, regardless of historical price
% For diagnostics/testing, I've hardcoded in BTC limits however eventually
% we will want to pull from the CoinGecko API % Hardcoded for demo/testing, but will want to determin in
% realtime from coinmarketcap API http://tinyurl.com/4poyc6x
BehindTheScenes.BehindTheScenes.todayExchangeRate = 4000; % current Exchange price, from whatever source.
BehindTheScenes.CapMax = 4450; % OPTIONAL, what is ATH for XYZ? Set to 0 to disable
d0ExchangePrice = TimeSeriesSubset(UserParameters.nDaysPreview);

% Scale all of the data by ratio of d0's Exchange price to today's Exchange price.
ExchangeRatio = BehindTheScenes.BehindTheScenes.todayExchangeRate/d0ExchangePrice;
ScaledTimeSeriesSubset = TimeSeriesSubset*ExchangeRatio;

%% STEP 3 -- Possibly superimpose a noise vector
if UserParameters.booleanNoise
    % We'll probably have to tune NoiseParameter to find a good value
    NoiseParameter = 0.05; % fraction of Exchange, here +/-
    UnitNoiseVector = rand(SubsetLength,1)-1/2; % Noise on [-0.5 +0.5]
    ScaledNoiseVector = NoiseParameter*UnitNoiseVector*BehindTheScenes.BehindTheScenes.todayExchangeRate; % Scale to Exchange price
    DataAndNoise = ScaledTimeSeriesSubset + ScaledNoiseVector;
    % ^ finally, we superimpose the noise with the timeseries
    
    if BehindTheScenes.CapMax > 0
        % If this is enabled, set the highest
        % amount in the preview window to be the
        % XYZcoin ATH. e.g. at time of these simulations
        % the price (e.g. BTC) is ~4000 USD, and the ATH is ~4450
        
        ShiftSpot = max(DataAndNoise(1:UserParameters.nDaysPreview))- BehindTheScenes.CapMax;
        FinalSimData = DataAndNoise - ShiftSpot;
        StartPrice = BehindTheScenes.BehindTheScenes.todayExchangeRate - ShiftSpot;
    else
        FinalSimData = DataAndNoise;
        StartPrice = BehindTheScenes.todayExchangeRate;
    end
    
else
    % No noise
    FinalSimData = ScaledTimeSeriesSubset; % We have prepared without noise
end


%% DEVELOPMENT STEP A -- Plotting for diagnostic
% -- Just using these to test different modifying functions
% I'm not commenting this as much since not intended to be directly ported

% Easy variable names
simX = TimeSeriesTimeline;
simY = FinalSimData;
PriceRange = [min(FinalSimData), max(FinalSimData)];

% Generate the figure
f = figure('color','white');
ax1 = subplot(2,1,1);
plot(simX, TimeSeriesSubset);
title(['Non-transformed data (starting: ',DateStrings{SubsetStartIndex},')']);
xlabel('Simulation Time')
ylabel('Exchange Price')
grid on

ax2 = subplot(2,1,2);
% Note that in the actual simulation interface (as opposed to these
% diagnostic plots), we'll need to use 
% auto-scaling/updating y-axis, or else in many situations
% the limits would give away the upcoming high &/or lows
fill([-UserParameters.nDaysPreview, 0, 0, -UserParameters.nDaysPreview],[PriceRange(1), PriceRange(1), PriceRange(2), PriceRange(2)], [0,0,0])
hold on;
plot(simX, simY, 'color','red','linewidth',3);
plot([min(simX) max(simX)], StartPrice*[1,1], ':','color','blue','linewidth',2)
xlabel('Simulation tTime')
ylabel('Exchange Price')
grid on;
linkaxes([ax1,ax2],'x')
axis('tight')

%% DEVELOPMENT STEP B -- Data for C to temporarily hardbake.
OutputMatrix = [simX, simY];

%% DEVELOPMENT STEP NaL -- SAVE QUERY
keep = input('Keep? [0,1] $ ');
if keep
    savestring = ['ScaleAndCapMax_',num2str(round(rand()*1e4))];
    DoubleSave(f, [savestring,'_plot'], pwd)
    csvwrite([savestring,'_data.csv'],OutputMatrix)
end

function craneVI(block)
%MSFUNTMPL_BASIC A Template for a Level-2 MATLAB S-Function
%   The MATLAB S-function is written as a MATLAB function with the
%   same name as the S-function. Replace 'msfuntmpl_basic' with the
%   name of your S-function.
%
%   It should be noted that the MATLAB S-function is very similar
%   to Level-2 C-Mex S-functions. You should be able to get more
%   information for each of the block methods by referring to the
%   documentation for C-Mex S-functions.
%
%   Copyright 2003-2010 The MathWorks, Inc.
%   @param x0
%   @param y0
%   @param h
%   @param w
%   @param xdic
%   @param nCont
%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block);

%endfunction

%% Function: setup ===================================================
%% Abstract:
%%   Set up the basic characteristics of the S-function block such as:
%%   - Input ports
%%   - Output ports
%%   - Dialog parameters
%%   - Options
%%
%%   Required         : Yes
%%   C-Mex counterpart: mdlInitializeSizes
%%
function setup(block)

% Register number of ports
block.NumInputPorts  = 7;
block.NumOutputPorts = 0;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
% block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
% block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;
block.InputPort(1).SamplingMode      = 'Sample';
block.InputPort(1).DimensionsMode    = 'Fixed';
  
% block.InputPort(2).Dimensions        = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = true;
block.InputPort(2).SamplingMode      = 'Sample';
block.InputPort(2).DimensionsMode    = 'Fixed';

% block.InputPort(3).Dimensions        = 1;
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).DirectFeedthrough = true;
block.InputPort(3).SamplingMode      = 'Sample';
block.InputPort(3).DimensionsMode    = 'Fixed';

% block.InputPort(4).Dimensions        = 1;
block.InputPort(4).DatatypeID  = 0;  % double
block.InputPort(4).Complexity  = 'Real';
block.InputPort(4).DirectFeedthrough = true;
block.InputPort(4).SamplingMode      = 'Sample';
block.InputPort(4).DimensionsMode    = 'Fixed';

% block.InputPort(5).Dimensions        = 1;
block.InputPort(5).DatatypeID  = 0;  % double
block.InputPort(5).Complexity  = 'Real';
block.InputPort(5).DirectFeedthrough = true;
block.InputPort(5).SamplingMode      = 'Sample';
block.InputPort(5).DimensionsMode    = 'Fixed';

% block.InputPort(6).Dimensions        = 1;
block.InputPort(6).DatatypeID  = 0;  % double
block.InputPort(6).Complexity  = 'Real';
block.InputPort(6).DirectFeedthrough = true;
block.InputPort(6).SamplingMode      = 'Sample';
block.InputPort(6).DimensionsMode    = 'Fixed';

% block.InputPort(7).Dimensions        = 1;
block.InputPort(7).DatatypeID  = 8;  % boolean
% block.InputPort(7).Complexity  = 'Real';
block.InputPort(7).DirectFeedthrough = true;
block.InputPort(7).SamplingMode      = 'Sample';
block.InputPort(7).DimensionsMode    = 'Fixed';

% % Override output port properties
% block.OutputPort(1).DimensionsMode = 'Fixed';
% block.OutputPort(1).SamplingMode   = 'Sample';
% block.OutputPort(1).Dimensions       = 1;
% block.OutputPort(1).DatatypeID  = 0; % double
% block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 6;


% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
% block.SampleTimes = [-1 0];
block.SampleTimes = [0.1 0];
% Specify the block simStateCompliance. The allowed values are:
%    'UnknownSimState', < The default setting; warn and assume DefaultSimState
%    'DefaultSimState', < Same sim state as a built-in block
%    'HasNoSimState',   < No sim state
%    'CustomSimState',  < Has GetSimState and SetSimState methods
%    'DisallowSimState' < Error out when saving or restoring the model sim state
block.SimStateCompliance = 'DefaultSimState';

%% -----------------------------------------------------------------
%% The MATLAB S-function uses an internal registry for all
%% block methods. You should register all relevant methods
%% (optional and required) as illustrated below. You may choose
%% any suitable name for the methods and implement these methods
%% as local functions within the same file. See comments
%% provided for each function for more information.
%% -----------------------------------------------------------------

block.RegBlockMethod('PostPropagationSetup',    @DoPostPropSetup);
% block.RegBlockMethod('InitializeConditions', @InitializeConditions);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required
block.RegBlockMethod('SetInputPortDimensions',      @SetInputPortDims);

%end setup


% -------------------------------------------------------------------------
function SetInputDimsMode(block, port, dm)
% Set dimension mode
block.InputPort(port).DimensionsMode = dm;


function SetInputPortDims(block, idx, di)
width = prod(di);
if width ~= 1  
     DAStudio.error('Simulink:blocks:multirateInvaliDimension'); 
end
% Set compiled dimensions 
block.InputPort(idx).Dimensions = di;
% block.OutputPort(1).Dimensions =[1 15];


%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
  % Set the type of signal size to be dependent on input values, i.e.,
  % dimensions have to be updated at output
  block.SignalSizesComputeType = 'FromInputValueAndSize';
  
  block.NumDworks = 9;

  block.Dwork(1).Name            = 'xt';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
%   block.Dwork(1).UsedAsDiscState = true;
  
  
  block.Dwork(2).Name            = 'xl';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
%   block.Dwork(2).UsedAsDiscState = true;
  
  block.Dwork(3).Name            = 'yl';
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;      % double
  block.Dwork(3).Complexity      = 'Real'; % real
%   block.Dwork(3).UsedAsDiscState = true;
  
  block.Dwork(4).Name            = 'lh';
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;      % double
  block.Dwork(4).Complexity      = 'Real'; % real
%   block.Dwork(4).UsedAsDiscState = true;
  
  block.Dwork(5).Name            = 'l';
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0;      % double
  block.Dwork(5).Complexity      = 'Real'; % real
%   block.Dwork(5).UsedAsDiscState = true;
  
  block.Dwork(6).Name            = 'theta';
  block.Dwork(6).Dimensions      = 1;
  block.Dwork(6).DatatypeID      = 0;      % double
  block.Dwork(6).Complexity      = 'Real'; % real
%   block.Dwork(6).UsedAsDiscState = true;
  
  block.Dwork(7).Name            = 'nCont';
  block.Dwork(7).Dimensions      = 17;
  block.Dwork(7).DatatypeID      = 0;      % double
  block.Dwork(7).Complexity      = 'Real'; % real
  block.Dwork(7).UsedAsDiscState = true;

  block.Dwork(8).Name            = 'bFlagLoad';
  block.Dwork(8).Dimensions      = 1;
  block.Dwork(8).DatatypeID      = 8;      % bolean
  block.Dwork(8).Complexity      = 'Real'; % real

  block.Dwork(9).Name            = 'iCont'; %indice del container
  block.Dwork(9).Dimensions      = 1;
  block.Dwork(9).DatatypeID      = 0;      % double
  block.Dwork(9).Complexity      = 'Real'; % real

%end DoPostPropSetup

%%
%% InitializeConditions:
%%   Functionality    : Called at the start of simulation and if it is
%%                      present in an enabled subsystem configured to reset
%%                      states, it will be called when the enabled subsystem
%%                      restarts execution to reset the states.
%%   Required         : No
%%   C-MEX counterpart: mdlInitializeConditions
%%
% function InitializeConditions(block)

%end InitializeConditions


%%
%% Start:
%%   Functionality    : Called once at start of model execution. If you
%%                      have states that should be initialized once, this
%%                      is the place to do it.
%%   Required         : No
%%   C-MEX counterpart: mdlStart
%%
function Start(block)
% Populate the Dwork vector
    block.Dwork(1).Data = 0; %xt0
    block.Dwork(2).Data = 0; %xl0
    block.Dwork(3).Data = 0; %yl0
    block.Dwork(4).Data = 0; %lh0
    block.Dwork(5).Data = 0; %l0
    block.Dwork(6).Data = 0; %theta0
    block.Dwork(7).Data = block.DialogPrm(6).Data; %nCont
    block.Dwork(8).Data = false; % bFlagLoad
    block.Dwork(9).Data = 0; % indice del container
    %Acces to param data
    x0 = block.DialogPrm(1).Data;
    y0 = block.DialogPrm(2).Data;
    
    localFigInit(x0, y0, block);
%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)
% Output function:
% -update output values
% -update signal dimensions
% block.OutputPort(1).CurrentDimensions = [1 9];
% block.OutputPort(1).Data = block.Dwork(7).Data';
% block.OutputPort(1).Data = block.Dwork(1).Data + block.InputPort(1).Data;

%end Outputs

%%
%% Update:
%%   Functionality    : Called to update discrete states
%%                      during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlUpdate
%%
function Update(block)

block.Dwork(1).Data = block.InputPort(1).Data;
block.Dwork(2).Data = block.InputPort(2).Data;
block.Dwork(3).Data = block.InputPort(3).Data;
block.Dwork(4).Data = block.InputPort(4).Data;
block.Dwork(5).Data = block.InputPort(5).Data;
block.Dwork(6).Data = block.InputPort(6).Data;

fig = get_param(gcbh,'UserData');
if ishghandle(fig, 'figure')
    if strcmp(get(fig,'Visible'),'on')
        ud = get(fig,'UserData');
        localFigSets(ud,block);
    end
end
%end Update

%%
%% Derivatives:
%%   Functionality    : Called to update derivatives of
%%                      continuous states during simulation step
%%   Required         : No
%%   C-MEX counterpart: mdlDerivatives
%%
% function Derivatives(block)

%end Derivatives

%%
%% Terminate:
%%   Functionality    : Called at the end of simulation for cleanup
%%   Required         : Yes
%%   C-MEX counterpart: mdlTerminate
%%
function Terminate(block)

%end Terminate

%
%=============================================================================
% LocalPendInit
% Local function to initialize the pendulum animation.  If the animation
% window already exists, it is brought to the front.  Otherwise, a new
% figure window is created.
%=============================================================================
%
function localFigInit(x0, y0, block)

%
% The name of the reference is derived from the name of the
% subsystem block that owns the pendulum animation S-function block.
% This subsystem is the current system and is assumed to be the same
% layer at which the reference block resides.
%

%Data
XCart     = x0; %xt0
Theta     = 0;
yl0        = y0; %yl0


XDelta    = 2;
PDelta    = 0.2;
XPendTop  = XCart; % Will be zero
YPendTop  = 45;         % Will be 10
PDcosT    = PDelta*cos(Theta);     % Will be 0.2
PDsinT    = -PDelta*sin(Theta);    % Will be zero

% Containers
h = block.DialogPrm(3).Data; %height
w = block.DialogPrm(4).Data;   %width

xDisc = block.DialogPrm(5).Data; % Discretizacion de x para colocar containers
nCont = block.DialogPrm(6).Data; % numero de containers apilados por columna
nColor = ['r' 'g' 'm' 'y' 'c']; 
% dX = -25;
dY = 0;
Cont = gobjects(max(nCont), size(xDisc,2)); % filas son los containers,
                                             %  columnas es la posicion 
Text = gobjects(size(xDisc,2));                                             
% block.Dwork(7).Data = h * nCont + [zeros(1, find(xDisc == 0)-1),15 ,...
%                         -18 * ones(1,size(xDisc,2) - find(xDisc == 0))]; % yc0
% disp(block.Dwork(7).Data);

% Ship
Ship_ = polyshape([ 1   1  3   3  48 48 50  50],...
                  [-20 -1 -1 -18 -18 -1 -1 -20]);
%
% The animation figure handle is stored in this block's UserData.
% If it exists, initialize the reference mark, time, cart, and pendulum
% positions/strings/etc.
%
Fig = get_param(gcbh,'UserData');
if ishghandle(Fig ,'figure')
    FigUD = get(Fig,'UserData');
    set(FigUD.Cart,...
        'XData',ones(2,1)*[XCart-XDelta XCart+XDelta]);
    set(FigUD.Pend,...
        'XData',[XPendTop-PDcosT XPendTop+PDcosT; XCart-PDcosT XCart+PDcosT],...
        'YData',[YPendTop-PDsinT YPendTop+PDsinT; yl0-PDsinT PDsinT+yl0]);
    set(FigUD.Dock,...
        'XData',ones(2,1)*[-30 0],...
        'YData',[0 0; -20 -20]);
    set(FigUD.Port,...
        'XData',ones(2,1)*[-30 50],...
        'YData',[45 45; 43 43]);
    set(FigUD.Ship,...
        'Faces', [1 2 3 4; 4 5 NaN NaN; 1 4 5 8; 5 6 7 8],...
        'Vertices', [Ship_.Vertices, zeros(8,1)]);
    set(FigUD.Beam,...
        'XData',ones(2,1)*[0 1],...
        'YData',[15 15; -20 -20]);
    % Conteiners
    for i = 1:size(xDisc,2)
        for j = 1:nCont(i)
            set(FigUD.Cont(j,i),...
                'XData',    ones(2,1)*[xDisc(i)-w/2 xDisc(i)+w/2],...
                'YData',    [dY+h dY+h; dY dY]);
            dY=dY+h;
        end        
        if xDisc(i) < 0
            dY = 0;
        else
            dY = -18;
        end
        if xDisc(i)<=-5 || xDisc(i) >= 5
            set(FigUD.Text(i), 'EdgeColor', 'g');
        end
    end    
    set(FigUD.Spre,...
    'XData',    ones(2,1)*[XCart-w/2 XCart+w/2],...
    'YData',    [yl0+1 yl0+1; yl0 yl0]); %Atencion con Y hay que modificar
    %
    % bring it to the front
    %
    figure(Fig);
    return
end

%
% the animation figure doesn't exist, create a new one and store its
% handle in the animation block's UserData
%
FigureName = 'Crane Visualization';
Fig = figure(...
    'Units',           'pixel',...
    'Position',        [100 100 600 400],...
    'Name',            FigureName,...
    'NumberTitle',     'off',...
    'IntegerHandle',   'off',...
    'HandleVisibility','callback',...
    'Resize',          'off',...
    'DeleteFcn',       'pendan([],[],[],''DeleteFigure'')',...
    'CloseRequestFcn', 'pendan([],[],[],''Close'');');
AxesH = axes(...
    'Parent',  Fig,...
    'Units',   'pixel',...
    'Position',[50 50 500 300],...
    'CLim',    [1 64], ...
    'Xlim',    [-30 50],...
    'Ylim',    [-20 50],...
    'Visible', 'off');



Cart = surface(...
    'Parent',   AxesH,...
    'XData',    ones(2,1)*[XCart-XDelta XCart+XDelta],...
    'YData',    [50 50; 45 45],...
    'ZData',    zeros(2),...
    'CData',    11*ones(2));
Pend = surface(...
    'Parent',   AxesH,...
    'XData',    [XPendTop-PDsinT XPendTop+PDsinT; XCart-PDsinT XCart+PDsinT],...
    'YData',    [YPendTop-PDcosT YPendTop+PDcosT; -PDcosT PDcosT],...
    'ZData',    zeros(2),...
    'CData',    11*ones(2));
Dock = surface(...
    'Parent',   AxesH,...
    'FaceColor', 'k',...
    'XData',    ones(2,1)*[-30 0],...
    'YData',    [0 0; -20 -20],...
    'ZData',    zeros(2),...
    'CData',    11*ones(2));
%Portch
Port = surface(...
    'Parent',   AxesH,...
    'FaceColor', 'y',...
    'XData',    ones(2,1)*[-30 50],...
    'YData',    [45 45; 43 43],...
    'ZData',    zeros(2),...
    'CData',    11*ones(2));
Ship = patch(...
    'Parent',   AxesH,...
    'FaceColor', 'b',...
    'Faces', [1 2 3 4; 4 5 NaN NaN; 1 4 5 8; 5 6 7 8],...
    'Vertices', [Ship_.Vertices, zeros(8,1)]);
Beam = surface(...
    'Parent',   AxesH,...
    'FaceColor', [0.5 0.5 0.5],...
    'XData',    ones(2,1)*[0 1],...
    'YData',    [15 15; -20 -20],...
    'ZData',    zeros(2),...
    'CData',    11*ones(2));
% Container
for i = 1:size(xDisc,2)
    for j = 1:nCont(i)
        Cont(j,i) = surface(...
            'Parent',   AxesH,...
            'FaceColor', nColor(randi(5)),...
            'XData',    ones(2,1)*[xDisc(i)-w/2 xDisc(i)+w/2],...
            'YData',    [dY+h dY+h; dY dY],...
            'ZData',    zeros(2),...
            'CData',    11*ones(2));
        dY=dY+h;
    end
    if xDisc(i) < 0
        dY = 0;
    else
        dY = -18;
    end
    if xDisc(i)<=-5 || xDisc(i) >= 5
        Text(i) = text('Parent', AxesH,...
                       'String', string(i),...
                       'Position', [xDisc(i)-1 -24],...
                       'EdgeColor', 'g',...
                       'Margin', 1);
    end
end
%Spreader = Gancho
Spre = surface(...
    'Parent',   AxesH,...
    'FaceColor', 'w',...
    'XData',    ones(2,1)*[XCart-w/2 XCart+w/2],...
    'YData',    [yl0+1 yl0+1; yl0 yl0],...   %Tiene que ser Y carga mas un delta 35 35; 34 34
    'ZData',    zeros(2),...
    'CData',    11*ones(2));


%
% all the HG objects are created, store them into the Figure's UserData
%
FigUD.Cart         = Cart;
FigUD.Pend         = Pend;
FigUD.Dock         = Dock;
FigUD.Port         = Port;
FigUD.Ship         = Ship;
FigUD.Beam         = Beam;
FigUD.Cont         = Cont;
FigUD.Spre         = Spre;
FigUD.Block        = get_param(gcbh,'Handle');
FigUD.Text         = Text;
% set( Object, Name parameter, Value)
set(Fig,'UserData',FigUD);

drawnow

%
% store the figure handle in the animation block's UserData
%
set_param(gcbh,'UserData',Fig);

% end localFigInit

%
%=============================================================================
% LocalPendSets
% Local function to set the position of the graphics objects in the
% inverted pendulum animation window.
%=============================================================================
%
function localFigSets(ud,block)
% Containers
h = block.DialogPrm(3).Data;   %height
w = block.DialogPrm(4).Data;   %width

xDisc = block.DialogPrm(5).Data; % Discretizacion de x para colocar containers
nCont = block.Dwork(7).Data; % numero de containers apilados por columna

XDelta   = 2;
PDelta   = 0.1;

XPendTop = block.Dwork(1).Data;
YPendTop = 45; %ymax
PDcosT   = PDelta*cos(block.Dwork(6).Data);
PDsinT   = -PDelta*sin(block.Dwork(6).Data);
set(ud.Cart,...
    'XData',ones(2,1)*[block.Dwork(1).Data-XDelta block.Dwork(1).Data+XDelta]);
set(ud.Pend,...
    'XData',[XPendTop-PDsinT XPendTop+PDsinT;...
             block.Dwork(2).Data-PDsinT block.Dwork(2).Data+PDsinT], ...
    'YData',[YPendTop-PDcosT YPendTop+PDcosT;...
             block.Dwork(3).Data-PDcosT block.Dwork(3).Data+PDcosT]);
%Spreader = Gancho
set(ud.Spre,...
    'XData',    ones(2,1)*[block.Dwork(2).Data-w/2 block.Dwork(2).Data+w/2],...
    'YData',    [block.Dwork(3).Data+1 block.Dwork(3).Data+1;...
                 block.Dwork(3).Data block.Dwork(3).Data]);

if block.InputPort(7).Data    
    if ~block.Dwork(8).Data
        xRounded = interp1(xDisc, xDisc, block.Dwork(2).Data, 'nearest', 'extrap');
        ind = find(xDisc == xRounded);
        block.Dwork(9).Data = ind(1);
        block.Dwork(8).Data = true;
    end
    set(ud.Cont(nCont(block.Dwork(9).Data), block.Dwork(9).Data),...
    'XData',    ones(2,1)*[block.Dwork(2).Data-w/2 block.Dwork(2).Data+w/2],...
    'YData',    [block.Dwork(3).Data block.Dwork(3).Data; ...
                block.Dwork(3).Data-h block.Dwork(3).Data-h]);
end

if ~block.InputPort(7).Data && block.Dwork(8).Data
    xRounded = interp1(xDisc, xDisc, block.Dwork(2).Data, 'nearest', 'extrap');
    ind_2 = find(xDisc == xRounded);
    if xDisc(ind_2(1)) < 0
        dY = 0;
    else
        dY = -18;
    end   
    
    ud.Cont(nCont(ind_2(1))+1, ind_2(1)) = surface(...
    'Parent',   get(ud.Cont(nCont(block.Dwork(9).Data),...
                            block.Dwork(9).Data), 'Parent'),...
    'FaceColor',get(ud.Cont(nCont(block.Dwork(9).Data),...
                            block.Dwork(9).Data), 'FaceColor'),...
    'XData', ones(2,1)*[xDisc(ind_2(1))-w/2 xDisc(ind_2(1))+w/2],...
    'YData', h * [nCont(ind_2(1))+1 nCont(ind_2(1))+1; ...
                  nCont(ind_2(1)) nCont(ind_2(1))] + dY,...
    'ZData', get(ud.Cont(nCont(block.Dwork(9).Data),...
                               block.Dwork(9).Data), 'ZData'),...
    'CData', get(ud.Cont(nCont(block.Dwork(9).Data),...
                               block.Dwork(9).Data), 'CData'));
%         set( ud.Cont(k,nCont(i)+1),);

    % Despejo objeto de la posicion que estaba
    delete(ud.Cont(nCont(block.Dwork(9).Data), block.Dwork(9).Data));
%     ud.Cont(nCont(block.Dwork(9).Data), block.Dwork(9).Data) = surface(0,0,0);
    % Lo sumo a la columna actual
    block.Dwork(7).Data(block.Dwork(9).Data) = nCont(block.Dwork(9).Data)-1;
    block.Dwork(7).Data(ind_2(1)) = nCont(ind_2(1))+1;
    block.Dwork(8).Data = false;

end

% Force plot to be drawn
pause(0)
drawnow

% end LocalPendSets

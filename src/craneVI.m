function craneVI(block, x0, y0)
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

%%
%% The setup method is used to set up the basic attributes of the
%% S-function such as ports, parameters, etc. Do not add any other
%% calls to the main body of the function.
%%
setup(block, x0, y0);

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
function setup(block, x0, y0)

% Register number of ports
block.NumInputPorts  = 6;
block.NumOutputPorts = 0;

% Setup port properties to be inherited or dynamic
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

% Override input port properties
% block.InputPort(1).Dimensions        = 1;
block.InputPort(1).DatatypeID  = 0;  % double
block.InputPort(1).Complexity  = 'Real';
block.InputPort(1).DirectFeedthrough = true;

% block.InputPort(2).Dimensions        = 1;
block.InputPort(2).DatatypeID  = 0;  % double
block.InputPort(2).Complexity  = 'Real';
block.InputPort(2).DirectFeedthrough = true;

% block.InputPort(3).Dimensions        = 1;
block.InputPort(3).DatatypeID  = 0;  % double
block.InputPort(3).Complexity  = 'Real';
block.InputPort(3).DirectFeedthrough = true;

% block.InputPort(4).Dimensions        = 1;
block.InputPort(4).DatatypeID  = 0;  % double
block.InputPort(4).Complexity  = 'Real';
block.InputPort(4).DirectFeedthrough = true;

% block.InputPort(5).Dimensions        = 1;
block.InputPort(5).DatatypeID  = 0;  % double
block.InputPort(5).Complexity  = 'Real';
block.InputPort(5).DirectFeedthrough = true;

% block.InputPort(6).Dimensions        = 1;
block.InputPort(6).DatatypeID  = 0;  % double
block.InputPort(6).Complexity  = 'Real';
block.InputPort(6).DirectFeedthrough = true;

% % Override output port properties
% block.OutputPort(1).Dimensions       = 1;
% block.OutputPort(1).DatatypeID  = 0; % double
% block.OutputPort(1).Complexity  = 'Real';

% Register parameters
block.NumDialogPrms     = 0;

% Register sample times
%  [0 offset]            : Continuous sample time
%  [positive_num offset] : Discrete sample time
%
%  [-1, 0]               : Inherited sample time
%  [-2, 0]               : Variable sample time
block.SampleTimes = [-1 0];

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
block.RegBlockMethod('Start', @Start, x0, y0);
block.RegBlockMethod('Outputs', @Outputs);     % Required
block.RegBlockMethod('Update', @Update);
% block.RegBlockMethod('Derivatives', @Derivatives);
block.RegBlockMethod('Terminate', @Terminate); % Required

%end setup

%%
%% PostPropagationSetup:
%%   Functionality    : Setup work areas and state variables. Can
%%                      also register run-time methods here
%%   Required         : No
%%   C-Mex counterpart: mdlSetWorkWidths
%%
function DoPostPropSetup(block)
  block.NumDworks = 6;

  block.Dwork(1).Name            = 'xt';
  block.Dwork(1).Dimensions      = 1;
  block.Dwork(1).DatatypeID      = 0;      % double
  block.Dwork(1).Complexity      = 'Real'; % real
  block.Dwork(1).UsedAsDiscState = true;
  
  block.Dwork(2).Name            = 'xl';
  block.Dwork(2).Dimensions      = 1;
  block.Dwork(2).DatatypeID      = 0;      % double
  block.Dwork(2).Complexity      = 'Real'; % real
  block.Dwork(2).UsedAsDiscState = true;
  
  block.Dwork(3).Name            = 'yl';
  block.Dwork(3).Dimensions      = 1;
  block.Dwork(3).DatatypeID      = 0;      % double
  block.Dwork(3).Complexity      = 'Real'; % real
  block.Dwork(3).UsedAsDiscState = true;
  
  block.Dwork(4).Name            = 'lh';
  block.Dwork(4).Dimensions      = 1;
  block.Dwork(4).DatatypeID      = 0;      % double
  block.Dwork(4).Complexity      = 'Real'; % real
  block.Dwork(4).UsedAsDiscState = true;
  
  block.Dwork(5).Name            = 'l';
  block.Dwork(5).Dimensions      = 1;
  block.Dwork(5).DatatypeID      = 0;      % double
  block.Dwork(5).Complexity      = 'Real'; % real
  block.Dwork(5).UsedAsDiscState = true;
  
  block.Dwork(6).Name            = 'theta';
  block.Dwork(6).Dimensions      = 1;
  block.Dwork(6).DatatypeID      = 0;      % double
  block.Dwork(6).Complexity      = 'Real'; % real
  block.Dwork(6).UsedAsDiscState = true;
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
function Start(block, x0, y0)
% Populate the Dwork vector
    block.Dwork(1).Data = 0; %xt0
    block.Dwork(2).Data = 0; %xl0
    block.Dwork(3).Data = 0; %yl0
    block.Dwork(4).Data = 0; %lh0
    block.Dwork(5).Data = 0; %l0
    block.Dwork(6).Data = 0; %theta0
localFigInit(x0, y0);
%end Start

%%
%% Outputs:
%%   Functionality    : Called to generate block outputs in
%%                      simulation step
%%   Required         : Yes
%%   C-MEX counterpart: mdlOutputs
%%
function Outputs(block)

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
function localFigInit(x0, y0)

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
h = 2.5; %height
w = 5;   %width
nMaxContX = 9; %cantidad maxima de filas de containers
nMaxContY = 10; %cantidad maxima de containers apilados
nCont = [2 3 4 4 5 5 6 7 7]; %numero de containers apilados por fila
nColor = ['r' 'g' 'm' 'y' 'c']; 
dX = 3;
dY = -18;
Cont = gobjects(nMaxContX,nMaxContY);
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
    for i = 1:nMaxContX
        for j = 1:nCont(i)
            set(FigUD.Cont(i,j),...
                'XData',    ones(2,1)*[dX dX+w],...
                'YData',    [dY+h dY+h; dY dY]);
            dY=dY+h;
        end
        dY = -18;
        dX = dX+w;
    end    
    set(FigUD.Spre,...
    'XData',    ones(2,1)*[XCart-w/2 XCart+w/2],...
    'YData',    [yl0 yl0; yl0-1 yl0-1]); %Atencion con Y hay que modificar
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
for i = 1:nMaxContX 
    for j = 1:nCont(i)
        Cont(i,j) = surface(...
            'Parent',   AxesH,...
            'FaceColor', nColor(randi(5)),...
            'XData',    ones(2,1)*[dX dX+w],...
            'YData',    [dY+h dY+h; dY dY],...
            'ZData',    zeros(2),...
            'CData',    11*ones(2));
        dY=dY+h;
    end
    dY = -18;
    dX = dX+w;
end
%Spreader = Gancho
Spre = surface(...
    'Parent',   AxesH,...
    'FaceColor', 'w',...
    'XData',    ones(2,1)*[XCart-w/2 XCart+w/2],...
    'YData',    [35 35; 34 34],...   %Tiene que ser Y carga mas un delta
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

XDelta   = 2;
PDelta   = 0.1;
w = 5; %container width
XPendTop = block.Dwork(1).Data;
YPendTop = 45; %ymax
PDcosT   = PDelta*cos(block.Dwork(6).Data);
PDsinT   = -PDelta*sin(block.Dwork(6).Data);
set(ud.Cart,...
    'XData',ones(2,1)*[block.Dwork(1).Data-XDelta block.Dwork(1).Data+XDelta]);
set(ud.Pend,...
    'XData',[XPendTop-PDsinT XPendTop+PDsinT; block.Dwork(2).Data-PDsinT block.Dwork(2).Data+PDsinT], ...
    'YData',[YPendTop-PDcosT YPendTop+PDcosT; block.Dwork(3).Data-PDcosT block.Dwork(3).Data+PDcosT]);
%Spreader = Gancho
set(ud.Spre,...
    'XData',    ones(2,1)*[block.Dwork(2).Data-w/2 block.Dwork(2).Data+w/2],...
    'YData',    [block.Dwork(3).Data block.Dwork(3).Data; block.Dwork(3).Data-1 block.Dwork(3).Data-1]);
% Force plot to be drawn
pause(0)
drawnow

% end LocalPendSets


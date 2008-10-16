function ls = levelset2D(varargin)
%LEVELSET2D Create a levelset2D object.
%   LS = LEVELSET2D(A), where A is a numeric 2-D array, creates a
%   levelset2D object with A as the level set function (preferably a signed
%   distance function). Standard first order Euler is used for time
%   integration and first order finite differences are used in space.
%
%   LS = LEVELSET2D(A,T), where T is a string, creates a levelset2D object
%   with A as the level set function and time integration as specified in
%   T. Currently supported integration schemes are:
%
%       Euler
%
%   LS = LEVELSET2D(A,T,S), where T is a string, creates a levelset2D
%   object with A as the level set function, time integration as specified
%   in T and spatial discretization as specified in S. Currently supported
%   spatial discretization schemes are:
%
%       FirstOrder
%       WENO
%
%   LS = LEVELSET2D(A,T,S,I), where T is a string, creates a levelset2D
%   object with A as the level set function, time integration as specified
%   in T, spatial discretization as specified in S and reinitialization as
%   as specified in I. Currently supported reinitialization routines are:
%
%       PDE
%       FastMarching
%
%   Examples:
%       width = 64;
%       height = 64;
%       mask = zeros(width,height);
%       mask(width/2-width/4:width/2+width/4, height/2-height/4:height/2+height/4) = 1;
%       mask = mask==1;
%       A = zeros(size(mask));
%       dist = bwdist(mask);
%       A(~mask) = dist(~mask);
%       dist = -bwdist(~mask);
%       A(mask) = dist(mask);
%       LS = levelset2D(A);
%       plot(LS);
%
%   See also PROPAGATE, PLOT.

%   Author: Gunnar Johansson (Gunnar.Johansson@itn.liu.se)
%   $Date: 2007/10/17

ls.phi = [];
ls.band = [];
ls.bandwidth = Inf;
ls.integrate = @euler;
ls.diff_central = @diff_central_order2;
ls.diff_upwind = @diff_upwind_order1;
ls.diff2 = @diff2_order2;
ls.reinitialize = @reinitialize_PDE;

if nargin == 0
    ls = class(ls,'levelset2D');
elseif isa(varargin{1},'levelset2D')
    ls = varargin{1};
else
    if isnumeric(varargin{1}) && ndims(varargin{1}) == 2
        ls.phi = varargin{1};
        ls.band = uint32(1:numel(varargin{1}));
    else
        error('First argument is not a numeric 2 dimensional array');
    end

    if nargin >= 2
        if isnumeric(varargin{2}) && isscalar(varargin{2})
            ls.bandwidth = varargin{2};
            ls.band = uint32(find(abs(ls.phi) <= ls.bandwidth))';
        else
            error('Second argument is not a scalar');
        end
    end

    if nargin >= 3
        switch lower(varargin{3})
            case 'euler'
                % Do nothing, already set as standard
            otherwise
                error('Third argument is not a valid integrator');
        end
    end

    if nargin >= 4
        switch lower(varargin{4})
            case 'firstorder'
                % Do nothing, already set as standard
            case 'weno'
                ls.diff_upwind = @diff_upwind_WENO;
            otherwise
                error('Fourth argument is not a valid spatial discretization scheme');
        end
    end
    
    if nargin >= 5
        switch lower(varargin{5})
            case 'pde'
                % Do nothing, already set as standard
            case 'fastmarching'
                ls.reinitialize = @reinitialize_fastmarching_driver;
            case 'fastsweeping'
                ls.reinitialize = @reinitialize_fastsweeping_driver;
            otherwise
                error('Fifth argument is not a valid reinitialization routine');
        end
    end

    ls = class(ls,'levelset2D');
end

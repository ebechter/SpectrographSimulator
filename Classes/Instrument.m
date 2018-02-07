classdef Instrument
    
    properties
        Progression
        Bandpass
        PathName
        Labels
        Path
        FinalTput
        IntTrans
        Orders
        StrehlRatio
        Type
        PSF
        Pixels
        Polarization
    end
    
    methods       
        function[obj] = Optical_Path(obj)
            
            if strcmp(obj.PathName,'Fiber')==1
                obj.Path = {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.FiberCh};
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','Fiber Ch Optics'};
                obj.Bandpass = ([970 1310]);
            elseif strcmp(obj.PathName,'Image')==1
                obj.Path= {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.ImageCh};
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','Image Ch Optics'};
                obj.Bandpass = ([900 970]);
            elseif strcmp(obj.PathName,'Quad')==1
                obj.Bandpass = ([1310 1400]);
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','Quad Ch Optics'};
                obj.Path = {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.QuadCh};
            elseif strcmp(obj.PathName,'AO')==1
                obj.Bandpass = ([600 900]);
                obj.Labels = {'LBT','Ent Window','WFS'};
                obj.Path = {obj.LBT,obj.EntWindowWFS,obj.WFS};
            elseif strcmp(obj.PathName,'Spectrograph')==1
                obj.Path = {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.FiberCh,obj.FiberLink,obj.Spec};
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','Fiber Ch Optics','FiberLink','Spec Optics'};
                obj.Bandpass = ([950 1350]);
            elseif strcmp(obj.PathName,'WFC')==1
                obj.Path= {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.WFC};
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','WFC Ch Optics'};
                obj.Bandpass = ([200 1200]);
            elseif strcmp(obj.PathName,'Calibration')==1
                obj.Path= {obj.Spec};
                obj.Labels = {'Spec Optics'};
                obj.Bandpass = ([900 1350]);
            elseif strcmp(obj.PathName,'Alignment')==1
                obj.Path = {obj.LBTIAlignmentCh,obj.EntWindow,obj.LBTI,obj.CombinedFPCh};
                obj.Labels = {'LBT','Ent Window','LBTI','Combined_FP'};
                obj.Bandpass = ([600 1090]);
           elseif strcmp(obj.PathName,'FiberTol')==1
                obj.Path = {obj.Rho};
                obj.Labels = {'Coupling'};
                obj.Bandpass = ([970 1310]);
           elseif strcmp(obj.PathName,'FWR')==1
                obj.Path = {obj.LBT,obj.EntWindow,obj.LBTI,obj.CommonCh,obj.FiberCh,[obj.FiberLink(:,1),obj.FiberLink(:,3)]};
                obj.Labels = {'LBT','Ent Window','LBTI','Common Optics','Fiber Ch Optics','FiberLink'};
                obj.Bandpass = ([970 1310]); 
            end
        end
        function[obj] = Path_Multiply(obj)
            wave = obj.Path{1}(:,1);
            Tput = ones(length(obj.Path{1}(:,2)),1);
            
            for ii = 1:length(obj.Path)
                [wave,Tput]=multiply_curves(wave,Tput,obj.Path{ii}(:,1),obj.Path{ii}(:,2));
                obj.Progression{ii}(:,1) = wave;
                obj.Progression{ii}(:,2) = Tput;
            end
        end
        
        function[obj] = loadCurves(obj,coatingName,polarization)
            
            filename = coatingName; 
            file = strcat(curve_dir,filename);
            load(file)
            
            
            
            
        
        function [obj] = Trim_Throughput(obj)
            for ii = length(obj.Progression)
                [xtrim,ytrim]=select_bandpass_noplot(obj.Progression{ii}(:,1),obj.Progression{ii}(:,2),obj.Bandpass(1,:));
                obj.FinalTput(:,1) = xtrim;
                obj.FinalTput(:,2) = ytrim;
            end
        end
        function[obj] = Integrated_Transmission(obj)
            total = (max(obj.Bandpass(1,:))-min(obj.Bandpass(1,:)));
            obj.IntTrans= trapz(obj.FinalTput(:,1),obj.FinalTput(:,2))/total;
        end
        function[obj] = Include_Grating(obj)
            GratingEff = obj.Grating;
            for ii = 2:size(GratingEff-3,2) % trying to fix for 36 orders
               
                y1 = obj.FinalTput(:,2);
                x1 = obj.FinalTput(:,1);
                
                y2 = GratingEff(:,ii);
                x2 = GratingEff(:,1);
                
%                 [real,ind]=max(Ran2);
%                 xq(:,1) = Ran2(1):1:real;
%                 Ran2=Ran2(1:ind);
%                 Per2=Per2(1:ind);
                %vq(:,1)=interp1(Ran2,Per2,xq);
                %[wav_order,Tput_order]= multiply_curves(Ran1,Per1,xq,vq);
                yq = interp1(x1,y1,x2,'linear','extrap');
                [wav_order,Tput_order]= multiply_curves(x2,y2,x2,yq);
                
                % Order_eff{ii-1} = Tput_order;
                % Order_wav{ii-1} = wav_order;
                % Order_num{ii-1} = 156-ii+1;
                % total = (ru-rl)*100;
                % Order_int_trans{ii} = trapz(wav_order,Tput_order);
                clear xq vq
                
                Orders{1}(:,ii-1)=Tput_order;
                Orders{2}(:,ii-1)=wav_order;
                Orders{3}(ii-1)=156-ii-1;
                
            end
            
            %----------Assign Object properties----------%
            obj.Orders = Orders;
        end
        function[] = Progression_Plot(obj)
            handle =[];
            global colors
            
            figure(1)
            hold on
            for ii = 1:length(obj.Progression)
                h{ii} = plot(obj.Progression{ii}(:,1),obj.Progression{ii}(:,2),'.','Markersize',8,'Color',colors{ii});
                handle = [handle h{ii}];
            end
            
           %hacking the grating in 
           h{ii+1} = plot(0:1:2,zeros(length(0:1:2),1),'.','Color',colors{11},'Markersize',8);
           handle = [handle h{ii+1}];
           obj.Labels = [obj.Labels, 'R6 Grating'];
           
            for ii = 1%[1,length(obj.Progression)]
                [xtrim,ytrim]=select_bandpass(obj.Progression{ii}(:,1),obj.Progression{ii}(:,2),[970,1270]);
%                 [xtrim,ytrim]=select_bandpass(obj.Progression{ii}(:,1),obj.Progression{ii}(:,2),obj.Bandpass(2,:));
            end
            
            l=legend(handle,obj.Labels,'Location','best');
            plot_max = max(obj.Progression{length(obj.Progression)}(:,1));
            plot_min = min(obj.Progression{length(obj.Progression)}(:,1));
            title('FP Light')
            ylim([0 0.85])
            xlim([plot_min plot_max])
            ylabel('Throughput')
            xlabel('\lambda nm')
            l.FontSize = 10;
            l.Box = 'off';
            box on
            
        end
        function[] = Grating_Plot(obj)
            global colors
            figure
            hold on
            for ii = 1:size(obj.Orders{1},2)
                plot(obj.Orders{2}(:,ii),obj.Orders{1}(:,ii),'.','Color',colors{11},'Markersize',6)
            end
            title('Total Spectrograph Light')
            xlim([900 1350])
            ylim([0 1])
            ylabel('Throughput')
            xlabel('\lambda nm')
            box on
            ax = gca;
            ax.LineWidth = 1.5;
            
        end
        function[obj] = SetInstrumentSR(Star_SR,obj)
            %Interpolate Strehl Ratio to match instrument sampling
            SR = interp1(Star_SR(:,1)*1000,Star_SR(:,3),obj.FullBand);
            %Set Instrument object values obtained from target
            obj.StrehlRatio(:,1) = SR/100;
            obj.FiberLink(:,2) = obj.FiberLink(:,2).*obj.StrehlRatio(:,1);
            obj.FiberLink(:,3) = obj.FiberLink(:,3).*obj.StrehlRatio(:,1);
            obj.FiberLink(:,4) = obj.FiberLink(:,4).*obj.StrehlRatio(:,1);
        end
        function[obj] = CustomizeBandpass (obj,custom_band)
            
            %shift over current entries into bandpass
            for jj = size(obj.Bandpass,1):-1:1
                obj.Bandpass(jj+1,:) = obj.Bandpass(jj,:);
            end
            
            %identify the last curve in progression
            ii = length(obj.Progression);
            
            if nargin > 1
                lb = custom_band(1,1);
                ub = custom_band(1,2);
            else
                if isempty(ii)== 1;
                    lb = custom_band(1,1);
                    ub = custom_band(1,2);
                else
                    lb = min(obj.Progression{ii}(:,1));
                    ub = max(obj.Progression{ii}(:,1));
                end
            end
            
            obj.Bandpass(1,:) = [lb ub];
        end
        function[obj] = GeneratePSF (obj,FWHM)
        % Make a normalized function (Airy or Gaussian) with specific pixel
        % sampling
        [X,Y] = meshgrid((-10*FWHM:1:10*FWHM),(-10*FWHM:1:10*FWHM));
        F = circ_gauss(X,Y,FWHM/2.355,[0,0]);
        obj.PSF = F;
        end
    end
end

%Multiply Curves
function[x,y]= multiply_curves(x1,y1,x2,y2)

if x1(1)< x2(1)
    x = x1;
    Int = y1;
    wav2 = x2;
    Int2 = y2;
else
    wav2 = x1;
    Int2 = y1;
    x = x2;
    Int = y2;
end

[out1,~] = find(x == wav2(1),1);
x = x(out1:length(x));
Int = Int(out1:length(Int));

if x(end)> wav2(end)
else
    wav2_new = x;
    Int2_new = Int;
    
    wav_new = wav2;
    Int_new = Int2;
    x=wav_new;
    Int=Int_new;
    
    wav2=wav2_new;
    Int2=Int2_new;
end

[out1,~] = find(x == wav2(end),1,'last');

x = x(1:out1);
Int = Int(1:out1);

y = (Int).*(Int2);

end
%Select Bandpass
function[x_cut,y_cut] = select_bandpass(x,y, bounds)
            rng_l =max(bounds(:,1));
            rng_u =min(bounds(:,2));
            wavelength_limits = x<=rng_u & x>=rng_l; % Instrument band
            y_cut = y(wavelength_limits);% cut the flux value at the band
            x_cut = x(wavelength_limits);
            area(x_cut,y_cut,'Facecolor','k','Linestyle','none')
            line([x_cut(1,1) x_cut(1,1)], [0 y_cut(1,1)],'color','k')
            line([x_cut(length(x_cut)) x_cut(length(x_cut))], [0 y_cut(length(y_cut))],'color','k')
            alpha(0.15)
end
%Select Bandpass
function[x_cut,y_cut] = select_bandpass_noplot(x,y, bounds)
            rng_l =max(bounds(:,1));
            rng_u =min(bounds(:,2));
            wavelength_limits = x<=rng_u & x>=rng_l; % Instrument band
            y_cut = y(wavelength_limits);% cut the flux value at the band
            x_cut = x(wavelength_limits);
end

function F=circ_gauss(X,Y,Sigma,center)
%--------------------------------------------------------------------------
% circ_gauss function                                                General
% Description: Calculate 2D circular Gaussian in a 2-D grid.
% Input  : - Scalar, vector or matrix of X-coordinates in which to calculate
%            the 2-D Gaussian.
%          - same as the x-ccordinates, but for the y-axis.
%          - Sigma of the Gaussian or [SigmaX, SigmaY] in case sigma
%            is different for each axis.
%            By default SigmaY=SigmaX.
%            If empty matrix use default.Si
%          - Center of the Gaussian [X, Y].
%            By default Y=X.
%            Default is [0 0].
%            If empty matrix use default.
%          - Maximum radius of Gaussian behond to set it to zero.
%            Default is Inf.
%            MaxRad is measured from the center of the kernel and not
%            the center of the Gaussian.


% Example: 
%          F=circ_gauss(MatX,MatY,[1],[0 0]);
%          surface(F);
%--------------------------------------------------------------------------



SigmaX = Sigma;
SigmaY = SigmaX;

X0 = center(1);
Y0 = center(2);

F = 1./(2.*pi.*SigmaX.*SigmaY) .*exp(-1./(2.).* ((X-X0).^2./SigmaX.^2 +(Y-Y0).^2./SigmaY.^2));



% set elements outside MaxRad to zero:
% if (~isinf(cutoff)),
%    MatR = sqrt(X.^2 + Y.^2);
%    I = find(MatR>cutoff);
%    F(I) = 0;
% end
% 
% if (isnan(Norm)),
%    % do not normalize
% else
%    F = Norm.*F./sumnd(F);
% end
end



        
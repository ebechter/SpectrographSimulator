for ii = tracenum
   

    if strcmp(curve{ii}.source,'star')
        
        spectral_cell{ii} = Simulation.addStar(spectrograph.maxR,spectrograph.pixSamp,...
                                           simulation.scale,spectrograph.bandPass,star.wavelength,star.spectrum,star.rv);
        
        if curve{ii}.atmosphere == 1
            
            spectral_cell{ii}(:,2) = Simulation.addAtmosphere(spectral_cell{ii}(:,1),spectral_cell{ii}(:,2), ...
                                                           atmosphere.telluric, atmosphere.skyback);
            
        end
    
        if curve{ii}.AO == 1 
            
            % if we want ao, first check if its already been made
            
            if exist('AO_throughput','var') == 0
                    
                % if not, make it
                [AO_throughput] = combinedImagerThroughput(AO_list);
                AOFlux = Simulation.resampleToGrid(AO_throughput(:,1)*1e-3,AO_throughput(:,2),spectral_cell{ii}(:,1));
                
                WFSthing = spectral_cell{ii}(:,2).*AOFLux;
                
                
            else
                
                do stuff sort of again
                
                % spectral_cell{ii} = simulation.addAO(spectral_cell{ii},AO_throughput);
            end
        
        end                                                                                                                                                                                                                                                                                                                                                                       
        if isempty(curve{ii}.throughput) == 0  
            
            if exist('starThroughput','var') ==0 
            
              starThroughput = Simulation.combineImagerThroughput(star_components);
                
              throughputGrid = Simulation.resampleToGrid(starThroughput(:,1)*1e-3,starThroughput(:,2),spectral_cell{ii}(:,1));
                
              spectral_cell{ii}(:,2) = spectral_cell{ii}(:,2).*throughputGrid;

            end
            
        end
    
        
        
        % cross disperse spectrum into nOrders orders, trim down wavelengths  
        spectral_cell{ii} = Simulation.Xdisperse(spectral_cell{ii},nOrders,wave_coeff);
        
        if any(strcmp('spectrograph', curve{ii}.throughput)) == 1
            
            % combine throughput of spectrograph. 
            
            spectral_cell{ii} = Simulation.addSpecThroughput(spectral_cell{ii},spectrograph.finalThroughput,nOrders);
            
            
        end
        
        
%         1) always split into spectral orders - basically copy the spectrum n_order times 
%         3) trim to each spectral order 
%         
%         if we want the throughput then
%             include spectrograph throughput for each order
%         end 
        
% split into spectral orders 
%         
% if throughput is needed  
    % add it
% end        

    elseif strcmp(curve{ii}.source,'etalon')
        %
        %         if throughput
        %
        %             combine them
        %         end
        spectral_cell{ii} = spectral_cell{1};
        
        %
    elseif strcmp(curve{ii}.source,'flat')
        
        
        spectral_cell{ii} = spectral_cell{1};
        %         if throughput
        %             combine them
        %         end
        %     end
    end
    %
end
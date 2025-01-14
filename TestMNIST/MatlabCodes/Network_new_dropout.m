classdef Network_new_dropout < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (GetAccess = private)
        
        weightFile;
        
        t = 0.001;
        a = 15.0;
        b = [0.01, 0.01, 0.025];
        %b = [0.0, 0.0, 0.0];
        count_1 =0;
        count_2=0;
        image_label = 0;
    end
    
    properties (SetAccess = public)
        
        layerStruct;
        numLayers;
        totalRounds;
        ffcheck;
        ltcheck;
        fbcheck;
        iterationImages;
        
        dropouts
        feedforwardConnections;
        lateralConnections;
        feedbackConnections;
        
    end
    
    properties
        
        
    end
    
    methods (Access = private)
        function createLateral(obj)
            
%             if exist(obj.weightFile, 'file') == 2
%                 load(obj.weightFile, 'lateralConnections');
%                 obj.lateralConnections = lateralConnections;
%             else
            
                obj.lateralConnections = cell([1, obj.numLayers - 1]);
                
                for i = 1 : obj.numLayers - 1

                    %obj.lateralConnections{i} = rand(layerStruct(i + 1),layerStruct(i + 1));
                    obj.lateralConnections{i} = - normr(binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i + 1)));

                    obj.lateralConnections{i}(1 : obj.layerStruct(i + 1) + 1 : obj.layerStruct(i + 1) * obj.layerStruct(i + 1)) = 1;

                end
                
%             end
            
            obj.ltcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        function createFeedforward(obj)
            
%                         if exist(obj.weightFile, 'file') == 2
%                             load(obj.weightFile, 'feedforwardConnections');
%                             obj.feedforwardConnections = feedforwardConnections;
%                         else
            
            obj.feedforwardConnections = cell([1, obj.numLayers - 1]);
            
            for i = 1 : obj.numLayers - 1
                
                 obj.feedforwardConnections{i} = rand(obj.layerStruct(i + 1),obj.layerStruct(i))*0.001;
%                 obj.feedforwardConnections{i} = normr(binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i)));
                %                     obj.feedforwardConnections{i} = binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i));
                %                     obj.feedforwardConnections{i} = rand(obj.layerStruct(i + 1), obj.layerStruct(i));
                %                     rowsum = sum(obj.feedforwardConnections{i},2);
                %                     obj.feedforwardConnections{i} = bsxfun(@rdivide, obj.feedforwardConnections{i}, rowsum);
                %                        obj.feedforwardConnections{i} =   ones([obj.layerStruct(i+1),obj.layerStruct(i)]);
            end
            
%                         end
            
            obj.ffcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        
        function createDropouts(obj,n)
            
            obj.dropouts = cell([1, obj.numLayers]);
            
            for i = 1 : obj.numLayers
                p=1;        %probability of success
                r=rand(obj.layerStruct(i + 1),n);
                r=(r<p);
                obj.dropouts{i} = rand(obj.layerStruct(i + 1),obj.layerStruct(i))*0.001;
        end
        end
        
        function STDP_update_feedforward(obj, layers, iteration)
            weights = obj.feedforwardConnections;
            dropoutv = obj.dropouts;
            this_t = obj.t;
            this_check = obj.ffcheck;
            this_totalRounds = obj.iterationImages;
            %
            parfor r = 1 : obj.numLayers - 1
                
                temp1 = layers{r} .^2;
                
                mean_A = mean(temp1');
                mean_B = mean(layers{r+1}');
                
                [m,n] = size(layers{r});
                [g,h] = size(layers{r+1});
                [e,l] = size((mean_A')*(mean_B));
                total_product = zeros(l,e);
                %                 total_product = [];
                for k = 1 : n
                    
                    total_temp  = layers{r+1}(:,k) * (temp1(:,k))';
                    total_product = total_product + total_temp;
                    
                end
                 total_product = total_product./n;
                 temp = 0.001*(total_product -7*n*((mean_A')*(mean_B))');
                 temp
                     weights{r} = (weights{r} + temp);
                     temp_drop = sigmf(temp, [10, 0]);
                     p=1*temp_drop; 
                     'p'
                     p %probability of success
                     k=rand(g,h);
            k=(k<p);
            dropoutv{r} = k;
            %             layers{1} = input;
            
                 %                
                if any(temp <= 0)
                    this_check(r) = this_check(r) + 1;
                end
            end
            
            obj.feedforwardConnections = weights;
            obj.dropouts = dropoutv;
            obj.ffcheck = this_check;
            
        end
        
        function saveWeights(obj)
            
            feedforwardConnections = obj.feedforwardConnections;
            %              lateralConnections = obj.lateralConnections;
            %             save(obj.weightFile, 'feedforwardConnections', 'lateralConnections');
            save(obj.weightFile, 'feedforwardConnections');
            
        end
        
    end
    
    methods
        
        function obj = Network_new_dropout(layerStruct,batchSize)
            
            obj.layerStruct = layerStruct;
            [~, obj.numLayers] = size(layerStruct);
            obj.totalRounds = 0;
            
            fileName = sprintf('%d_', layerStruct);
            fileName = strcat(fileName(1 : end - 1), '.mat');
            obj.weightFile = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);
            
            obj.createFeedforward();
            obj.createDropouts(batchSize);
%             obj.createLateral();
            obj.saveWeights();
            
        end
        
        function layers = getOutput(obj, input,iteration,label)
            this_totalRounds = obj.iterationImages;
            [m,n]=size(input);
            
            layers = cell([1, obj.numLayers]);
            obj.dropouts = cell([1, obj.numLayers]);
            input(input<0) = 0;
            input(input>0) = 1;
            % %
            
            
            layers{1} = times(input,obj.dropouts{1});
            sheet =1;
         for k = 1 : obj.numLayers - 1
                layers{k + 1} = obj.feedforwardConnections{k}* layers{k};
                layers{k + 1} = times(layers{k + 1},obj.dropouts{k+1});
                layers{k + 1} = zscore(layers{k + 1});
                 if k<obj.numLayers-1
                     layers{k + 1} = tanh(layers{k + 1});
                 else
                layers{k + 1} = sigmf(layers{k + 1}, [10, 0]);
                 end
                %                 end
                %                  layers{k + 1} = 1./(1+exp(-layers{k + 1}));
                
            end
            
            if(iteration>this_totalRounds)
                disp('d');
                                      xlswrite('final_4_9.xlsx',layers{4});
               end
     
            
        end
        
        function STDP_update(obj, layers, r)
            
            obj.totalRounds = obj.totalRounds + 1;
            obj.STDP_update_feedforward(layers, r);
            %          obj.STDP_update_lateral(layers);
            
        end
        
    end
    
end


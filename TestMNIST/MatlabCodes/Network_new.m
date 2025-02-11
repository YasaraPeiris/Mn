classdef Network_new < handle
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
                
                %                  obj.feedforwardConnections{i} = rand(obj.layerStruct(i + 1),obj.layerStruct(i));
                %                 obj.feedforwardConnections{i} = normr(binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i)));
                obj.feedforwardConnections{i} = binornd(1, 0.2, obj.layerStruct(i + 1), obj.layerStruct(i));
                %                     obj.feedforwardConnections{i} = rand(obj.layerStruct(i + 1), obj.layerStruct(i));
                %                     rowsum = sum(obj.feedforwardConnections{i},2);
                %                     obj.feedforwardConnections{i} = bsxfun(@rdivide, obj.feedforwardConnections{i}, rowsum);
                %                        obj.feedforwardConnections{i} =   ones([obj.layerStruct(i+1),obj.layerStruct(i)]);
                
            end
            
            %                         end
            
            obj.ffcheck = zeros(1, obj.numLayers - 1);
            
        end
        
        
        
        
        function STDP_update_feedforward(obj, layers, iteration)
            weights = obj.feedforwardConnections;
            this_t = obj.t;
            this_check = obj.ffcheck;
            this_totalRounds = obj.iterationImages;
            %
            parfor r = 1 : obj.numLayers - 1
                
                temp1 = layers{r} .^2;
                
                mean_A = mean(temp1');
                mean_B = mean(layers{r+1}');
                
                [m,n] = size(layers{r});
                
                [e,l] = size((mean_A')*(mean_B));
                total_product = zeros(l,e);
                %                 total_product = [];
                for k = 1 : n
                    
                    total_temp  = layers{r+1}(:,k) * (temp1(:,k))';
                    total_product = total_product + total_temp;
                    
                end
                %                 if r==1 && iteration==1
                %                     xlswrite('total_product_r.xlsx',layers{r});
                %                     xlswrite('total_product_r+1.xlsx',layers{r+1});
                %                     end
                %                if r==1 & iteration==1
                %                     xlswrite('total_product_iteration_1_r1_after.xlsx',total_product);
                %                     end
                total_product = total_product./n;
                %                 if r==1 & iteration==1
                %                     xlswrite('total_product_iteration_1_r1_after_div.xlsx',total_product);
                %                     end
                temp = 0.001*(total_product -5*n*((mean_A')*(mean_B))');
                %                temp = total_product - 0.75*((mean_A')*(mean_B))';
                %               if r==1 || r==2
                
                %               end
                %temp = (temp*(exp(-0.008*iteration))/r);
                
                %                 end
                if(iteration == this_totalRounds && r==1)
                    xlswrite('temp_1_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_1_tot',weights{r}(:,1:50));
                end
                if(iteration == this_totalRounds && r==2)
                    xlswrite('temp_2_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_2_tot.xlsx',weights{r}(:,1:50));
                end
                if(iteration == this_totalRounds && r==3)
                    xlswrite('temp_3_layer_final_iteration.xlsx',temp);
                    xlswrite('weight_3_tot.xlsx',weights{r});
                end
                if(iteration == 1 && r==1)
                    xlswrite('temp_1_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_1_tot',weights{r}(:,1:50));
                end
                if(iteration == 1 && r==2)
                    xlswrite('temp_2_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_2_tot.xlsx',weights{r}(:,1:50));
                end
                if(iteration == 1 && r==3)
                    xlswrite('temp_3_layer_first_iteration.xlsx',temp);
                    xlswrite('weight_3_tot.xlsx',weights{r});
                end
                %                                   if(iteration == this_totalRounds && r==1)
                %                                     xlswrite('temp_1_tot.xlsx',temp);
                %                                     xlswrite('weight_1_tot',weights{r}(:,1:50));
                %                                 end
                %                                 if(iteration == this_totalRounds && r==2)
                %                                     xlswrite('temp_2_tot.xlsx',temp);
                %                                     xlswrite('weight_2_tot.xlsx',weights{r}(:,1:50));
                %                                 end
                %                                 if(iteration == this_totalRounds && r==3)
                %                                     xlswrite('temp_3_tot.xlsx',temp);
                %                                     xlswrite('weight_3_tot.xlsx',weights{r});
                %                                 end
                %                 %
                weights{r} = weights{r} + temp;
                if(iteration == 1 && r==1)
                    
                    xlswrite('weight_1_iteration_gap_1.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == 1 && r==2)
                    
                    xlswrite('weight_1_iteration_gap_2.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == 1 && r==3)
                    
                    xlswrite('weight_1_iteration_gap_3.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == this_totalRounds && r==1)
                    
                    xlswrite('weight_final_iteration_gap_1.xlsx',weights{r}(:,1:100));
                    
                end
                if(iteration == this_totalRounds && r==2)
                    
                    xlswrite('weight_final_iteration_gap_2.xlsx',weights{r}(:,1:100));
                end
                if(iteration == this_totalRounds && r==3)
                    
                    xlswrite('weight_final_iteration_gap_3.xlsx',weights{r}(:,1:100));
                end
                %                 if iteration ==2 && r == 1
                %
                %                     dlmwrite('analyze.txt',r,'-append');
                %                     dlmwrite('analyze.txt',' ','-append');
                %                     dlmwrite('analyze.txt',weights{r},'-append');
                %                      dlmwrite('analyze_2.txt',r,'-append');
                %                     dlmwrite('analyze_2.txt',' ','-append');
                %                     dlmwrite('analyze_2.txt',temp(:,1),'-append');
                %
                if any(temp <= 0)
                    this_check(r) = this_check(r) + 1;
                end
            end
            
            obj.feedforwardConnections = weights;
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
        
        function obj = Network_new(layerStruct)
            
            obj.layerStruct = layerStruct;
            [~, obj.numLayers] = size(layerStruct);
            obj.totalRounds = 0;
            
            fileName = sprintf('%d_', layerStruct);
            fileName = strcat(fileName(1 : end - 1), '.mat');
            obj.weightFile = fullfile(fileparts(which(mfilename)), '..\WeightDatabase\Temp', fileName);
            
            obj.createFeedforward();
            %             obj.createLateral();
            obj.saveWeights();
            
        end
        
        function layers = getOutput(obj, input,iteration,label)
            this_totalRounds = obj.iterationImages;
            
            %                     xlswrite('total_product_r+1.xlsx',layers{r+1});
            %                     end
            %             xcel_name_1 = 'weight_1_lyr_1_1_no_1.xlsx';
            %             xcel_name_2 = 'weight_1_lyr_4_1_no_1.xlsx';
            %             xcel_name_3 = 'weight_1_lyr_1_e_no_1.xlsx';
            %             xcel_name_4 = 'weight_1_lyr_4_e_no_1.xlsx';
            %             xcel_name_5 = 'weight_1_lyr_2_1_no_1.xlsx';
            %             xcel_name_6 = 'weight_1_lyr_3_1_no_1.xlsx';
            %             xcel_name_7 = 'weight_1_lyr_2_e_no_1.xlsx';
            %             xcel_name_8 = 'weight_1_lyr_3_e_no_1.xlsx';
            
            %             if(label==0)
            %                 input = input*100;
            % %                 disp('0');
            %             end
            %             if(label==1)
            %                 input = input*0.001;
            % %                 disp('1');
            %             end
            %             if(iteration==1 && obj.count_1==0)
            %
            %                 obj.count_1=obj.count_1+1;
            %                 xcel_name_1 = 'weight_1_lyr_1_1_no_2.xlsx';
            %                 xcel_name_2 = 'weight_1_lyr_4_1_no_2.xlsx';
            %                 xcel_name_5 = 'weight_1_lyr_2_1_no_2.xlsx';
            %                 xcel_name_6 = 'weight_1_lyr_3_1_no_2.xlsx';
            %             end
            %             if(iteration==this_totalRounds && obj.count_2==0)
            %
            %                 obj.count_2=obj.count_2+1;
            %                 xcel_name_3 = 'weight_1_lyr_1_e_no_2.xlsx';
            %                 xcel_name_4 = 'weight_1_lyr_4_e_no_2.xlsx';
            %                 xcel_name_7 = 'weight_1_lyr_2_e_no_2.xlsx';
            %                 xcel_name_8 = 'weight_1_lyr_3_e_no_2.xlsx';
            %
            %             end
            
            [m,n]=size(input);
            
            layers = cell([1, obj.numLayers]);
            input(input<0) = 0;
            input(input>0) = 1;
            % %
            %             layers{1} = input;
            layers{1} = input;
            %              layers{1} = normc(input);
            %       layers{1} = 1./(1+exp(-input));
            
            sheet =1;
            %             layers{ 1} = zscore(layers{1});
            %              layers{ 1} = sigmf(layers{1},[1, 0]);
            %                layers{1} = input/norm((input),1.0);
            
            %              layers{1} = layers{1};
            %              dlmwrite('analyze_layer_1.txt',iteration,'-append');
            %              dlmwrite('analyze_layer_1.txt',layers{1},'-append');
            %             layers_batch = zeros(1000, n);
            for k = 1 : obj.numLayers - 1
                
                %
                if k<obj.numLayers
                    layers{k + 1} = obj.feedforwardConnections{k}* layers{k};
                end
                %
                %                   layers{k + 1} = layers{k + 1}/norm(layers{k + 1},1.0);
                %                 if k~=obj.numLayers-1
                % %                     layers{k + 1} = (exp(layers{k + 1})-exp(-layers{k + 1}))/(exp(layers{k + 1})_+exp(-layers{k + 1})+1);
                %
                %                 else
                %{
if k==1 || k==2
    layers{k + 1} = sinh(layers{k + 1}*0.00001)./cosh(layers{k + 1}*0.00001);
else
    layers{k + 1} = layers{k + 1}./norm(layers{k + 1},1.0);
end
                %}
                
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
                
                xlswrite('final_1_5.xlsx',layers{1});
                xlswrite('final_2_5.xlsx',layers{2});
                xlswrite('final_3_5.xlsx',layers{3});
                xlswrite('final_4_9.xlsx',layers{4});
                %
                %
                %
                %
                %                                        xlswrite('finalfeed_1.xlsx',obj.feedforwardConnections{1});
                %                                       xlswrite('finalfeed_2.xlsx',obj.feedforwardConnections{2});
                %                                       xlswrite('finalfeed_3.xlsx',obj.feedforwardConnections{3});
            end
            %                         if iteration ==1
            %                         xlswrite('xcel_name_1.xlsx',layers{1},sheet);
            %                           xlswrite('xcel_name_5.xlsx',layers{2},sheet);
            %                           xlswrite('xcel_name_6.xlsx',layers{3},sheet);
            %                          xlswrite('xcel_name_2.xlsx',layers{4},sheet);
            %                         end
            %                         if iteration==this_totalRounds;
            %                         xlswrite('xcel_name_3.xlsx',layers{1},sheet);
            %                          xlswrite('xcel_name_7.xlsx',layers{2},sheet);
            %                          xlswrite('xcel_name_8.xlsx',layers{3},sheet);
            %                          xlswrite('xcel_name_4.xlsx',layers{4},sheet);
            %                         end
            %
            
        end
        
        function STDP_update(obj, layers, r)
            
            obj.totalRounds = obj.totalRounds + 1;
            obj.STDP_update_feedforward(layers, r);
            %          obj.STDP_update_lateral(layers);
            
        end
        
    end
    
end


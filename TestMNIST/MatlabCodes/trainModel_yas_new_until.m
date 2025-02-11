function trainModel_yas_new(layerset, dataSize) % Using Oja's rule

trainingRatio = 0.8;
p = 0;

images = loadTrainImages();
labels = loadTrainLabels();

selected = find(labels == 2 | labels == 1 );
labels = labels(selected);
images = images(:, selected');
[~, c] = size(images);
% images(c) = [];

selected_1 = find( labels == 1 );

labels_train_1 = labels(selected_1);
images_train_1 = images(:, selected_1');


selected_2 = find( labels == 2 );
labels_train_2 = labels(selected_2);
images_train_2 = images(:, selected_2');


[~, c_1] = size(images_train_1);
[~, c_2] = size(images_train_2);
image_batch = 10;
newDataSize = min(c_1,c_2);
newDataSize = min(newDataSize,dataSize);
newIterations = fix(newDataSize/image_batch);
testImageStartId = newIterations*image_batch;
test_image = [];
test_label = [];

for i =1:image_batch
    test_image  = [test_image mat2gray(images(:,testImageStartId+i ))];
    test_label = [test_label labels(testImageStartId+i)];
    test_label
end
% xlswrite('test.xlsx',test_image);
% xlswrite('label.xlsx',test_label);

testLabels = [];
clusters = [];

unclassified = 0;
norms = [];

updateTime = 0.0;

%{
im = vec2mat(images(:, randi(10000)), 28)';
imshow(im);
drawnow;
%}

%showFinalImage(weights{1});
%temp = weights;

net = Network_new([784, layerset, 2]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;
temp = net.feedforwardConnections;
%  xlswrite('firstfeed_1.xlsx',temp{1});
% xlswrite('firstfeed_2.xlsx',temp{2});
% xlswrite('firstfeed_3.xlsx',temp{3});
net.iterationImages = newIterations;

image_count = 0;
test_count = 0;
pow = 1;
count_labels_1=0;
count_labels_2=0;
for r= 1:newIterations/2
    images_new_1 = [];
    images_new_2 = [];
    images_new = [];
    
    
    for k=1:image_batch
        image_id = image_batch*(r-1)+k;
        images_new_1 = [images_new_1 mat2gray(images_train_1(:, image_id))];
        images_new_2 = [images_new_2 mat2gray(images_train_2(:, image_id))];
    end
    images_new = [images_new images_new_1];
    images_new = [images_new images_new_2];
    
end

for r= 1:newIterations
    results = net.getOutput(images_new,r);
    %
    %
    %     for layerLevel = 1: numLayers
    %         results{layerLevel} = (results_1{layerLevel} + results_2{layerLevel})./2;
    %     end
    
    time = tic;
    net.STDP_update(results,r);
    updateTime = updateTime + toc(time);
    for u = 1 : image_batch
        
        norms = [norms; zeros(1, numLayers - 1)];
        
        weights = net.feedforwardConnections;
        for k = 1 : numLayers - 1
            
            norms(end, k) = norm(weights{k}(:,u) - tempW{k}(:,u),'fro') / numel(weights{k}(:,u));
            tempW{k}(:,u) = weights{k}(:,u);
            
        end
        
    end
    
    
end

[~,margin] = size(test_image);

for h = 1: margin/image_batch
    disp(h);
    test_image_batch=[];
    for k=1:image_batch
        
        image_id = image_batch*(h-1)+k;

        test_image_batch = [test_image_batch test_image(:,image_id)];
        
        
    end
    
    
    results = net.getOutput(test_image_batch,newIterations+1,-1);
     xlswrite('result_1_5.xlsx',results{1});
                      xlswrite('result_2_5.xlsx',results{2});
                      xlswrite('result_3_5.xlsx',results{3});
                       xlswrite('result_4_5.xlsx',results{4});
    for u=1:image_batch
        
        %     columns = ['A1','B1','C1','D1','E1','F1','G1','H1','I1','J1'];
        %     xlswrite('weight_15.xlsx',results{1});
        %     xlswrite('weight_16.xlsx',results{4});
        
        [m, i] = max(results{numLayers}(:,u));
        m
        if(m >= p)
            %                 image_id = image_batch*(r-1)+u;
            testLabels = [testLabels; test_label(:,u)];
            %               testLabels = [testLabels; labels(r)];
            clusters = [clusters; i];
            disp(i)
        else
            %                 disp(unclassified);
            unclassified = unclassified + 1;
            
        end
    end
end



plotPerformance([1 : newIterations*image_batch]', norms, testLabels, clusters, [1, 2, 3]);

% disp(['Unclassified: ', int2str(unclassified), ' out of ', int2str(dataSize - trainingSize)]);
%
% disp(['Average STDP update time = ', num2str(updateTime / iterations/image_batch)]);

for r = 1 : numLayers - 1
    
    disp([int2str(r),': ', int2str(net.ffcheck(r))]);
    sheet=1;
    %     xlswrite('weight_2.xlsx','new layer',sheet);
    %     xlswrite('weight_2.xlsx',weights{r},sheet);
    
end

%{
for i = 1 : numLayers - 1
    
    showFinalImage(weights{i});
   
end
%}

%showFinalImage([temp{1}, max(max(weights{1}))* ones(layers(2), 5), weights{1}]);

%showFinalImage(weights{1});

showFinalImage(abs(weights{1} - temp{1}));

%clust = kmeans(images(:, trainingSize + 1 : dataSize)', 8);

%plotPerformance([1 : iterations]', norms, testLabels, clust, [2, 3]);

%disp(clusters);





function trainModel(layerset, dataSize) % Using Oja's rule

trainingRatio = 0.7;
p = 0.3;

images = loadTrainImages();
labels = loadTrainLabels();

selected = find(labels == 2 | labels == 1);
labels = labels(selected);
images = images(:, selected');

[~, c] = size(images);
dataSize = min(c, dataSize);
iterations = dataSize;

testLabels = [];
clusters = [];

trainingSize = floor(double(dataSize) * trainingRatio);
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

net = Network([784, layerset, 8]);
numLayers = net.numLayers;
tempW = net.feedforwardConnections;
%tempW = net.lateralConnections;
temp = net.feedforwardConnections;

pow = 1;

for r = 1 : iterations
    
    results = net.getOutput(mat2gray(images(:, r)));
    
    if(r > trainingSize)
        [m, i] = max(results{numLayers});
        if(m >= p)
            testLabels = [testLabels; labels(r)];
            clusters = [clusters; i];
        else
            unclassified = unclassified + 1;
        end
        
    end
    
    time = tic;
    
    net.STDP_update(results);
    
    updateTime = updateTime + toc(time);
    
    
    norms = [norms; zeros(1, numLayers - 1)];
    
    weights = net.feedforwardConnections;
%     weights = net.lateralConnections;
    
    for k = 1 : numLayers - 1
        
        norms(end, k) = norm(weights{k} - tempW{k},'fro') / numel(weights{k});
        tempW{k} = weights{k};
%         disp(norms);
    end
    
    %{
    if r == pow
        showFinalImage(abs(weights{1} - temp{1}));
        pow = pow * 10;
    end
    %}
    
end

plotPerformance([1 : iterations]', norms, testLabels, clusters, [1, 2, 3]);

disp(['Unclassified: ', int2str(unclassified), ' out of ', int2str(dataSize - trainingSize)]);

disp(['Average STDP update time = ', num2str(updateTime / iterations)]);

for r = 1 : numLayers - 1

    disp([int2str(r),': ', int2str(net.ffcheck(r))]);

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





clear all
close all
clc

%accessing all the necessary files in order to begin reading them
trainImgs = fopen('train-images-idx3-ubyte','r','b');
testImgs = fopen('t10k-images-idx3-ubyte','r','b');
trainLabels = fopen('train-labels-idx1-ubyte','r','b');
testLabels = fopen('t10k-labels-idx1-ubyte','r','b');

%preparing the metadata for the training images set to be read
trainmagicnum = fread(trainImgs,1,'int32');
trainCount = fread(trainImgs,1,'int32');
trainW = fread(trainImgs,1,'int32');
trainH = fread(trainImgs,1,'int32');

%preparing the metadata for the test images set to be read
testmagicnum = fread(testImgs,1,'int32');
testCount = fread(testImgs,1,'int32');
testW = fread(testImgs,1,'int32');
testH = fread(testImgs,1,'int32');

%preparing the metadata for the training label set to be read
trainlabelmagicnum = fread(trainLabels,1,'int32');
trainlabelcount = fread(trainLabels,1,'int32');

%preparing the metadata for the test label set to be read
testlabelmagicnum = fread(testLabels,1,'int32');
testLabelCount = fread(testLabels,1,'int32');

% arranging the set of training images in a 60000 X 784+1 size matrix(extra 1 for wD+1) and
% training labels in a 60000 X 1 size matrix
imgTrainArray = zeros(trainCount,(trainW*trainH)+1);
for i=1:1:trainCount
    imgTrainArray(i,:)=[1,fread(trainImgs,[1,trainW*trainH],'uint8')];
end
labelTrainArray=fread(trainLabels,[trainCount,1],'uint8');

% arranging the set of testing images in a 784+1 X 10000 size matrix and
% training labels in a 1 X 10000 size matrix
testLabelArray=fread(testLabels,[1,testCount],'uint8'); %label
testImgsArray=zeros((testW*testH)+1,testCount);
for i=1:1:testCount
    testImgsArray(:,i)=[1;fread(testImgs,[((testW*testH)),1],'uint8')];
end

%matrix that will store all training samples to be multiplied by -1 later
Z=zeros(trainCount,(trainW*trainH)+1);  
%matrix that will store all 10 slopes
w=zeros((trainH*trainW)+1,1,10);
%b matrix
b=ones(trainCount,1);

%lamda
lamda=100;
%number of sample imgs to be tested
toBeTested=100;
%number of times all results of wTx were negative
inaccurateCount=0;
%number of times results of wTx had more than one positive
undefinedCount=0;


%number of correct vote and label comparisons with only 1 positive result
%from wTx
correctAccurateCount=0;
%number of correct vote and label comparisons with all results negative
%from wTx, i.e. taking least negative result as label
correctInaccurateCount=0;


for number=1:1:10 %for all numbers/classes from 0 to 9
    Z=imgTrainArray.*-1; %multiplying all of the image vectors by -1
    for i=1:1:trainCount %for all training samples
        if(labelTrainArray(i,1)==number-1) %if label of row corresponds to this number (0-9) 
            Z(i,:)=Z(i,:).*-1; %make that row positive again
        end
    end
    %calculate slope of that number class
    w(:,:,number)=inv(Z'*Z+(lamda*eye(((testW*testH)+1))))*Z'*b;
end

%%Testing%%
Y=zeros(10,2,toBeTested); %matrix storing results from wTx and the class label of every w
for y=1:1:toBeTested %for all samples that will be tested
    for n=1:1:10 %for all classes from 0 to 9
        Y(n,:,y)=[(testImgsArray(:,y))'*w(:,:,n),n-1]; %store wTx in col 1 and label of w in col 2 
    end
    Y(:,:,y)=sortrows(Y(:,:,y)); %sort according to wTx
    Max1=Y(10,1,y); ind1=Y(10,2,y); %get maximum result and its index
    Max2=Y(9,1,y); ind2=Y(9,2,y); %get second maximum result and its index
    
    %if maximum of all wTx results is <0 then result is considered inaccurate (for statistical purposes)
    if (Max1<0)
        vote=ind1; %vote is taken 
        inaccurateCount=inaccurateCount+1; %increase number of inaccurate occurences
        if(vote==testLabelArray(1,y)) %check if vote is same as test label
            %increase the correct counter for inaccurate cases
            correctInaccurateCount=correctInaccurateCount+1; 
        end
    else
        %else if only one maximum is >0  then result is considered accurate
        if(Max2<0)
            vote=ind1; %vote is taken
            if(vote==testLabelArray(1,y)) %check if vote is same as test label
                %increase the correct counter for accurate cases
                correctAccurateCount=correctAccurateCount+1;
            end
        else %else if more than one maximum is >0  then result is considered undefined
            undefinedCount=undefinedCount+1; %increase number of undefined occurences
        end
    end
end


%accurate percent
accuratePercentError=((toBeTested-correctAccurateCount)/toBeTested)*100
%inaccurate percent + accurate percent
inaccuratePercentError=((toBeTested-correctAccurateCount-correctInaccurateCount)/toBeTested)*100

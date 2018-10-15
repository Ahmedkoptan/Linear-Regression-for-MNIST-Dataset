Training on 10000 training images and testing 100 testing images
- Corresponding file is Regression.m
- lamda is specified before testing and can be changed
- Compiles much faster than KNN but yields higher % error
- There are different cases for processing the output of all 10 wTx:
	- all 10 values from wTx are negative, which should mean that a new class is needed. However, we know that there are only 10 classes (10 numbers). Therefore ‘inaccurateCount’ increases by 1. However, in order to calculate the lowest possible error, this case’s vote is taken into consideration by the ‘correctInaccurateCount’

	- only 1 positive wTx and the rest is negative, therefore ‘correctAccurateCount’ increases by one.

	- more than 1 positive wTx, which  should mean that the sample is undefined (follows more than one class). Therefore, ‘undefinedCount’ increases by 1. 

- Therefore, there are different errors. The error variable that allows the most slack is ‘inaccuratePercentError’, which takes into account the number of times all of the wTx were negative and considers the least negative result as the predicted label, if the predicted label == testlabel. The error variable ‘accuratePercentError’ accounts only for the accurate cases (only 1 positive wTx from the 10 multiplications) with correct votes (i.e. result==testLabel) 
- At lamda=100 inaccuratePercentError=14%, thus the model is 86% accurate, and the accuratePercentError= 32%, thus the true accuracy of the model is 68%. 
- At lamda equals 1000000, the inaccuratePercentError= 16%, thus the model is 84% accurate, and the accuratePercentError=28%, thus the true accuracy of the model is 72%.
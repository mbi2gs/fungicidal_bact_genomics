import torch
from torch import nn
import torch.nn.functional as F
from skorch import NeuralNetClassifier, NeuralNetRegressor

class ActivityNN(nn.Module):
    def __init__(self, input_dim=34, 
                 num_hidden_units=10, 
                 output_features=1,
                 dropout_rate=0.3):
        super(ActivityNN, self).__init__()
        self.input_dim = input_dim
        self.dense1 = nn.Linear(self.input_dim, num_hidden_units)
        self.dropout = nn.Dropout(dropout_rate)
        self.dense2 = nn.Linear(num_hidden_units, num_hidden_units)
        self.output = nn.Linear(num_hidden_units, output_features)
        self.sigmoid = nn.Sigmoid()
        
    def forward(self, X, **kwargs):
        X = F.relu(self.dense1(X))
        X = self.dropout(X)
        X = F.relu(self.dense2(X))
        X = self.sigmoid(self.output(X))
        return X

class ActivityLearner():
    def __init__(self, 
                 n_features=34,
                 lr=0.02, 
                 me=10):
        self.lr = lr # learning rate
        self.max_epochs = me
        self.model = NeuralNetRegressor(ActivityNN(input_dim=n_features),
                                         max_epochs=self.max_epochs,
                                         lr=self.lr,
                                         iterator_train__shuffle=True,
                                         criterion=torch.nn.BCELoss,
                                         optimizer=torch.optim.Adam,
                                         warm_start=False,
                                         verbose=0
                                        )
        self.trained = False
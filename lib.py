
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/followers.py import BuyAndHold,FollowTrend,RegularRebalance
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/machinelearning.py import StochasticGradientDescent
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/movingaverage.py import DualMovingAverage,VolumeWeightAveragePrice,Momentum,MovingAverageCrossover
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/orderbased.py import AutoAdjustingStopLoss
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/patate.py import MarkovGenerator
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/strategies/stddev.py import StddevBased
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/managers/constant.py import Constant
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/managers/fair.py import Fair
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/managers/gmv.py import GlobalMinimumVariance
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/algorithmic/managers/optimalfrontier.py import OptimalFrontier
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/backtest/csv.py import CSVSource
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/backtest/database.py import DBPriceSource
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/backtest/quandl.py import QuandlSource
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/backtest/yahoostock.py import YahooPriceSource,YahooOHLCSource
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/live/equities.py import EquitiesLiveSource
from /home/xavier/dev/projects/ppQuanTrade/neuronquant/data/ziplinesources/live/forex.py import ForexLiveSource


algorithms = {'BuyAndHold': BuyAndHold,'FollowTrend': FollowTrend,'RegularRebalance': RegularRebalance,'StochasticGradientDescent': StochasticGradientDescent,'DualMovingAverage': DualMovingAverage,'VolumeWeightAveragePrice': VolumeWeightAveragePrice,'Momentum': Momentum,'MovingAverageCrossover': MovingAverageCrossover,'AutoAdjustingStopLoss': AutoAdjustingStopLoss,'MarkovGenerator': MarkovGenerator,'StddevBased': StddevBased,}

portfolio_managers = {'Constant': Constant,'Fair': Fair,'GlobalMinimumVariance': GlobalMinimumVariance,'OptimalFrontier': OptimalFrontier,}

data_sources = {'CSVSource': CSVSource,'DBPriceSource': DBPriceSource,'QuandlSource': QuandlSource,'YahooPriceSource': YahooPriceSource,'YahooOHLCSource': YahooOHLCSource,'EquitiesLiveSource': EquitiesLiveSource,'ForexLiveSource': ForexLiveSource,}

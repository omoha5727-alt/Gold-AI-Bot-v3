#property strict
#property version "2.00"
#property description "Gold AI Bot V2 - Demo testing"

#include <Trade/Trade.mqh>
CTrade trade;

input double LotSize = 0.01;
input int StopLossPoints = 500;
input int TakeProfitPoints = 1000;
input int FastEMA = 20;
input int SlowEMA = 50;

int fastHandle, slowHandle;
datetime lastBar = 0;

int OnInit()
{
   trade.SetExpertMagicNumber(20261118);
   fastHandle = iMA(_Symbol, PERIOD_M15, FastEMA, 0, MODE_EMA, PRICE_CLOSE);
   slowHandle = iMA(_Symbol, PERIOD_M15, SlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
      return INIT_FAILED;

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
}

void OnTick()
{
   if(_Symbol != "XAUUSD" && _Symbol != "XAUUSDm")
      return;

   datetime bar = iTime(_Symbol, PERIOD_M15, 0);
   if(bar == lastBar || bar == 0)
      return;
   lastBar = bar;

   if(PositionSelect(_Symbol))
      return;

   double fast[3], slow[3];
   ArraySetAsSeries(fast, true);
   ArraySetAsSeries(slow, true);

   if(CopyBuffer(fastHandle, 0, 0, 3, fast) != 3)
      return;
   if(CopyBuffer(slowHandle, 0, 0, 3, slow) != 3)
      return;

   bool buy = fast[2] <= slow[2] && fast[1] > slow[1];
   bool sell = fast[2] >= slow[2] && fast[1] < slow[1];

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int digits = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);

   if(buy)
   {
      trade.Buy(LotSize, _Symbol, 0,
         NormalizeDouble(ask - StopLossPoints * _Point, digits),
         NormalizeDouble(ask + TakeProfitPoints * _Point, digits),
         "Gold AI V2 Buy");
   }
   else if(sell)
   {
      trade.Sell(LotSize, _Symbol, 0,
         NormalizeDouble(bid + StopLossPoints * _Point, digits),
         NormalizeDouble(bid - TakeProfitPoints * _Point, digits),
         "Gold AI V2 Sell");
   }
}

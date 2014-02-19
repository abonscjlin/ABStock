//
//  EnginConstant.h
//  abonStock
//
//  Created by fih on 2013/12/22.
//  Copyright (c) 2013年 abons. All rights reserved.
//



enum STOCK_PERIOD{
    PERIOD_DAY=0,
    PERIOD_WEEK=1,
    PERIOD_MONTH=2
}STOCK_PERIOD;

enum WANTGOO_STOCK_IDINFO{
    STOCK_PRICE =0,
    STOCK_CHANGE=1,
    STOCK_RATIO=2,
    STOCK_LOW=3,
    STOCK_HIGH=4,
    STOCK_VOLUME=5,
    STOCK_TIME=6,
    STOCK_COLOR=8
    
}WANTGOO_STOCK_IDINFO;

enum TSE_Stock_Index{
    
    TSE_Stock_name           = 36, //stock name
    TSE_Stock_no             = 0, //stock no
    TSE_Stock_change          = 1, //漲跌價
    TSE_Stock_time           = 2, //取得時間
    TSE_Stock_max            = 3, //漲停價
    TSE_Stock_min            = 4, //跌停價
    TSE_Stock_o              = 5, //開盤價
    TSE_Stock_h              = 6, //當日最高價
    TSE_Stock_l              = 7, //當日最低價
    TSE_Stock_c              = 8, //收盤價
    TSE_Stock_volume          = 9, //累計成交量
    TSE_Stock_pvalue         = 10, //該盤成交量
    TSE_Stock_Ratio          =31,
    
    TSE_Stock_top1buy_price  = 19,
    TSE_Stock_top1buy_value  = 20,
    TSE_Stock_top2buy_price  = 17,
    TSE_Stock_top2buy_value  = 18,
    TSE_Stock_top3buy_price  = 15,
    TSE_Stock_top3buy_value  = 16,
    TSE_Stock_top4buy_price  = 13,
    TSE_Stock_top4buy_value  = 15,
    TSE_Stock_top5buy_price  = 11,
    TSE_Stock_top5buy_value  = 12,
    
    TSE_Stock_top1sell_price = 21,
    TSE_Stock_top1sell_value = 22,
    TSE_Stock_top2sell_price = 23,
    TSE_Stock_top2sell_value = 24,
    TSE_Stock_top3sell_price = 25,
    TSE_Stock_top3sell_value = 26,
    TSE_Stock_top4sell_price = 27,
    TSE_Stock_top4sell_value = 28,
    TSE_Stock_top5sell_price = 29,
    TSE_Stock_top5sell_value = 30
    
}TSE_Stock_Index;

enum TSE_StockIndex_Index
{
    TSE_StockIndex_SI           = 1,
    TSE_StockIndex_TW50         = 50,
    TSE_StockIndex_SI_BID_Value = 55,
    TSE_StockIndex_SI_ASK_Value = 56
    
    
    
} TSE_StockIndex_Index;

enum TSE_StockIndex_KEY
{
    TSE_StockIndex_Time  = 1,
    TSE_StockIndex_Value = 2,
    TSE_StockIndex_range = 3
    
}TSE_StockIndex_KEY;

enum Srting_Encoding_TAG{
    ENCODING_BIG5=3
    
}Srting_Encoding_TAG;

enum STOCK_REQUEST_TAG{
    REQUEST_STOCK=2001,
    REQUEST_TWSI=2002, //tw stock index
    
}STOCK_REQUEST_TAG;
#ifndef abonStock_EnginConstant_h
#define abonStock_EnginConstant_h

#define URL_MIS_TSC_STOCK @"http://mis.tse.com.tw/data/%@.csv"
#define URL_MIS_TSC_INDEX @"http://mis.tse.com.tw/data/TSEIndex.csv"

#define TSC_STOCK_URL(__C1__) [NSString stringWithFormat:@"http://mis.tse.com.tw/data/%@.csv", __C1__]
#define TSC_URL @"mis.tse.com.tw"

#define WANTGOO_URL @"www.wantgoo.com"
#define WANTGOO_STOCK_URL(__C1__, __C2__) [NSString stringWithFormat:@"stock/chart.aspx?StockNo=%@&m=%@", __C1__, __C2__]
#define WANTGOO_REALTIME_STOCK_URL(__C1__) [NSString stringWithFormat:@"stock/IndexRealTime.aspx?stockno=%@", __C1__]
#define WANTGOO_REALTIME_STOCK_CSV_URL(__C1__) [NSString stringWithFormat:@"GetData.asmx/StockNoData?stockno=%@", __C1__]

#define STOCKDOG_URL @"www.stockdog.com.tw"
#define STOCKDOG_STOCKSINDEX_URL @"https://www.stockdog.com.tw/stockdog/index.php"

#define GOOGLENEWS_URL @"news.google.com"
#define GOOGLENWS_STOCK_URL(__C1__) [NSString stringWithFormat:@"news?q=%@&output=rss&ned=tw&hl=zh-tw",__C1__]
#define GOOGLENWS_STOCK_longURL(__C1__) [NSString stringWithFormat:@"http://news.google.com/news?q=%@&output=rss&ned=tw&hl=zh-tw",__C1__]

#define YAHOOO_URL @"ichart.yahoo.com"
#define YAHOO_STOCK_URL(__C1__,__C2__) [NSString stringWithFormat:@"table.csv?s=%@&g=%@", __C1__, __C2__]

#define KEY_StocksIndex @"KEY_StocksIndex"

#define encBig5 CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingBig5)


#endif


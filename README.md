# capitalgains
Quick-and-dirty scripts to help compute capital gains tax incurred by trading cryptocurrency assets.


### Overview
1. Export all your trades and build a single normalized CSV.
    * All trades must be in USD base. Trades with non-USD base (e.g. ETH/BTC) must be formatted as 2 rows (sell ETH to USD, buy BTC from USD). This is very detail orientated work that may involve manually looking up historical prices in a consistent manner.
    * You must define your initial basis (via actual or simulated buy rows). I wrote this program when I first started investing in cryptocurrency so it assumes it's starting from a $0 portfolio.
2. Import that into the database using __import.rb__.
3. Run __calculate.rb__ against the database to compute capital gains in either FIFO or LIFO method.
4. Use MySQL to view/slice/export the results.


### Dependencies
- MySQL
- Ruby with mysql2 gem


### Disclaimer
Use at your own risk. Not tax advice. This program may contain bugs or flaws and is not provided with any warranty or guarantee. Provided for inspirational purposes only.
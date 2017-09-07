require 'csv'
require 'mysql2'
require 'time'

# Usage: "ruby ./calculate.rb [FIFO|LIFO]"  (defaults to FIFO)

# Scans imported trading history in chronological order.
# Buy orders are appended to the running list of @basis price/qty/date rows for a given asset
# Sell orders consume from the running list (either FIFO or LIFO)

# (bug) If ANY of the basis's used for a sell order are >1yr old, the entire
# transaction will be flagged as long term capital gains. TODO: this should 
# split the transaction into the short term + long term components.

class Thing
    def initialize
        @client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "capitalgains")
        @basis = Hash.new
        @method = ARGV[0] == 'LIFO' ? 'LIFO' : 'FIFO'
                
    end
    
    def run
        results = @client.query("SELECT * FROM trades ORDER BY created_at ASC")
        
        # Scan each trade in chronological order
        results.each do |hash|
            @basis[hash['product']] = [] if @basis[hash['product']].nil?
        
            if hash['buy'] == 1
                # If it's a buy order, calculate the basis used and add it to our current state.
                basis_per_share = hash['total'].to_f / hash['volume'].to_f
                @basis[hash['product']] << {:shares => hash['volume'].to_f, :basis => basis_per_share.to_f, :date => Time.at(hash['created_at'])}
            else
                # Otherwise, for a sell order and given accounting method, decrement the 
                # current basis state accordingly (in other words, "fill" the order using basis rows),
                # saving the results to the database.
                basis, isltg = get_basis_for_sell(hash)
                gains = (hash['total'].to_f - basis).to_f
                shares = sum_shares(hash['product'])
                
                statement = @client.prepare("UPDATE trades SET shares_balance=?, basis=?, gains=?, isltg=? WHERE id=?;");
                result = statement.execute(
                    shares,
                    basis,
                    gains,
                    isltg,
                    hash['id']
                )
            end
        end
        
        puts "2017 CAPITAL GAINS REPORT (" + @method + ")\n--------------------------------------------------"
        
        
        puts "Basis:\n-----------------------------"
        @basis.each do |k, rows|
            n = sum_shares(k)
            if n > 0
                value = 0
                rows.each do |row|
                    if row[:shares] > 0
                        value += row[:shares] * row[:basis]
                    end
                end
                puts k + ":  " + n.round(2).to_s + " shares at ~$" + (value/n).round(2).to_s + "/share"
            else
                puts k + ":  0 shares"
            end
        end
    end
    
    
    def get_basis_for_sell(hash)
        volume = hash['volume']
        basis = 0
        isltg = false
        reference = Time.at(hash['created_at'])
        
        # fill volume by FIFO or LIFO along our basis
        @basis[hash['product']].each_with_index do |row, i|
            row = @basis[hash['product']][@basis[hash['product']].length - i - 1] if @method == 'LIFO'
                
            if row[:shares] > 0
                eat = [volume, row[:shares], 0].sort[1] #clamp
                row[:shares] -= eat
                volume -= eat
                basis += eat * row[:basis]
                isltg = true if (reference - row[:date]) / 86400 / 365 > 1
                break if volume <= 0
            end
        end
        
        return [basis, isltg ? 1 : 0]
    end
    
    def sum_shares(product)
        n = 0
        @basis[product].each do |row|
            n += row[:shares]
        end
        return n.to_f
    end
end






Thing.new.run

require 'csv'
require 'mysql2'
require 'time'

# Usage: "ruby ./import.rb"

# This imports the master.csv into the database, skipping duplicates.

@client = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "capitalgains")
@data = CSV.parse(File.read('trades.csv'))

n = 0;
@data.drop(1).each do |row|
    next if row[0].nil?
    
    begin
        statement = @client.prepare("INSERT INTO trades (remote_id, marketplace, product, buy, volume, price, fee, total, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);");
        result = statement.execute(
            row[0],
            row[1],
            row[2],
            row[3],
            row[4],
            row[5],
            row[6],
            row[7],
            Time.parse(row[8])
        )
        n += 1
    rescue Exception => e
        puts e.to_s + " row=" + row.join(',')
    end
end
puts "Imported " + n.to_s + " rows successfully."
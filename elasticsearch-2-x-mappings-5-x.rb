require 'elasticsearch'
require 'json'
require 'pry'

save_like_json = true
url_from = 'http://localhost:9200'
url_to = 'http://localhost:9201'
old_name = "pokedex"
new_name = "new_pokedex"

# Connect to elasticsearch from url
client_from = Elasticsearch::Client.new url: 'http://localhost:9200'
# client_to = Elasticsearch::Client.new url: url_to
# client_to.cluster.health

# get index and information about index from client
# if there is some error it put message error
begin
  index = client_from.indices.get(index: old_name)
rescue Exception => e
  puts e.message
end

# save properties of index like json
if save_like_json
  File.open("#{old_name}.json","w") do |f|
    f.write(index[old_name].to_json)
  end
end

# save data like json
if save_like_json
  File.open("#{old_name}-data.json","w") do |f|
    i = 1
    pom_hash = {} # save data about index
    pom_hash["_index"] = old_name
    
    while(i < client_from.count["count"])
      pom_hash["_type"] = client_from.get( index: old_name, id: i)["_type"]
      pom_hash["_id"] = client_from.get( index: old_name, id: i)["_id"]
      f.puts( {"index" => pom_hash}.to_json)
      f.puts(client_from.get_source( index: old_name, id: i).to_json)
      i = i+1
    end
  end
end

binding.pry

# create new index
puts client_from.indices.create index: "#{new_name}_#{DateTime.now.strftime("%Y%m%d%H%M%S")}"

#ms = client_from.indices.get(index: "#{new_name}_")["#{new_name}_"]["settings"]["index"]["creation_date"]
#DateTime.strptime(ms,'%Q')
#{DateTime.now.strftime("%Y%m%d%H%M%S")}

require 'elasticsearch'
require 'json'

save_like_json = true
url_from = 'http://localhost:9200'
url_to = 'http://localhost:9201'
old_name = "pokedex"
new_name = "new_pokedex"
add_aliases = true

# Connect to elasticsearch from url
client_from = Elasticsearch::Client.new url: url_from
client_to = Elasticsearch::Client.new url: url_to

# get index and information about index from client
# if there is some error it put message error
# index is hash with hashes aliases, mappings, settings
old_index = client_from.indices.get(index: old_name)[old_name]

# create new index
time_stamp = DateTime.now.strftime("%Y%m%d%H%M%S")
client_to.indices.create index: "#{new_name}_#{time_stamp}"

# add alieases
if add_aliases
  old_index["aliases"].each do |name_alias|
    client_to.indices.put_alias index: "#{new_name}_#{time_stamp}", name:name_alias, body: old_index["aliases"][name_alias]
  end
end

# mapping
# string + not_analyzed -> keyword + index: true
# string + analyzed -> text + index: true

# save properties of new index like json
if save_like_json
  File.open("#{new_name}_#{time_stamp}.json","w") do |f|
    f.write(old_index.to_json)
  end
end

# save data from old index like json
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

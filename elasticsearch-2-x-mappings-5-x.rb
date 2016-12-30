require 'json'
require 'yaml'
require './dfs.rb'

# loading of parameters of script's setting
config = YAML.load_file('./config.yaml')

# add setting to variable
save_like_json = config["config"]["save_like_json"]
url_from = config["config"]["url_from"]
url_to = config["config"]["url_to"]
old_name = config["config"]["old_name"]
new_name = config["config"]["new_name"]
add_aliases = config["config"]["add_aliases"]

# Connect to elasticsearch from url
client_from = Elasticsearch::Client.new(url: url_from)
client_to = Elasticsearch::Client.new(url: url_to)


# CREATE WITH SETTING
# create new index with setting of old index
# use DateTime like time stamp with format YYYYMMDDHHMMSS
time_stamp = DateTime.now.strftime("%Y%m%d%H%M%S")
new_name_with_time = "#{new_name}_#{time_stamp}"
old_setting = client_from.indices.get_settings(index: old_name)[old_name]["settings"]
client_from.indices.create( index: new_name_with_time, body: old_setting )

# MAPPING
# change mapping from 2.x to 5.x and add to new_index
# 1. string -> text / keywords
# 2. index: no / not_analyzed / analyzed -> false / true / true (expect index belongs to string)
# it use class DFS in dfs.rb
mapping = client_from.indices.get_mapping(index: old_name)[old_name]["mappings"]
DFS.new.dfs(mapping, false)
mapping.keys.each do |type|
  client_to.indices.put_mapping(index: new_name_with_time, type: type, body: mapping[type])
end


# ALIASES
# add alieases (because there are hash use each and add name (key) and body (value))
if add_aliases
  # get aliases of old index from web
  aliases = client_from.indices.get_aliases(index: old_name)[old_name]["aliases"]
  # add aliases to new index
  aliases.each do |name_alias|
    client_to.indices.put_alias( index: new_name_with_time, name: name_alias, body: aliases[name_alias])
  end
end

# SAVE LIKE JSON
# save properties of new index like json
if save_like_json
  # get new index from web
  new_index = client_from.indices.get(index: new_name_with_time)[new_name_with_time]
  # write to file with name of new index and time stamp
  File.write("#{new_name_with_time}.json", new_index.to_json)
end

# Help class to script elasticsearch-2-x-mappings-5-x.rb. It make mapping changes in mappings 2.x -> 5.x.
# There are applied 2 changes:
#   - string (2.x) is replace by keyword/text (function: replace_type_string)
#   - index.no/not_analyzed/analyzed is replace by index.false/true/true except index that belongs to string (function: replace_index) 
class DFS

  # initialize of class
  def initialize
  end

  # Main function of class, that searchs hash of mappings of index and make change by calling
  # of other function. To search of hash is use recursive depth first search. It use keys and
  # values of hash like nodes and relation between key and value like edge. It make changes 
  # to origin mapping.
  # Enter parameters:
  #   - mapping ... Hash with mapping that have to change, at start it is mappings of index
  #   - field ... Boolean represent information if search take place in field, at stat it is false
  def dfs(mapping, field)

    # Recurse is stop if mapping is not Hash or Array if Hashes.
    # We need to have hash, because in function use keys of hash and in mapping there are only 
    # hash or array od hashes
    if (!mapping.class.equal?(Hash) & !mapping.class.equal?(Array) )
      return
    end

    # If we are in field set up field to true, to better mapping string -> text/keyword
    # In field string convert to keyword
    if (mapping.has_key?("field") | mapping.has_key?("fields"))
      field = true
    end

    # if we find hash with key "type" and value "string" it calls function replace_type_string
    # to map string to keyword or text
    #   - string + analyzer -> text
    #   - string + index.analyzed -> text
    #   - string + index.not_analyzed -> keyword
    #   - string + index.no -> text
    #   - string in field -> keyword
    #   - string not in field and without analyzer and index -> text
    #
    # if in hash is type value is not string and there are key index it calls function
    # replace_index to map values of index no/analyzed/not_analyzed to false / true / true 
    # (except index belongs to string)
    #  - no -> false
    #  - analyzed -> true
    #  - not_analyzed -> true
    if (mapping.has_key?("type"))
        if (mapping["type"] == "string")
          replace_type_string(mapping, field)
        else
          if (mapping.has_key?("index"))
            replace_index(mapping)
          end
        end
    end

    # Recurse over all keys of hash of mapping with field
    mapping.keys.each do |key|
      dfs(mapping[key], field)
    end

  end

  # function replace_index to map values of index
  # no/analyzed/not_analyzed to false / true / true (except index belongs to string)
  #  - no -> false
  #  - analyzed -> true
  #  - not_analyzed -> true
  def replace_index(mapping)
    case (mapping["index"])
      when "analyzed"
        mapping["index"] = true
      when "not_analyzed"
        mapping["index"] = true
      when "no"
        mapping["index"] = false
    end
  end


  # function to map string to keyword or text
  #   - string + analyzer -> text
  #   - string + index.analyzed -> text
  #   - string + index.not_analyzed -> keyword
  #   - string + index.no -> text
  #   - string in field -> keyword
  #   - string not in field and without analyzer and index -> text
  def replace_type_string(mapping, field)
    if (mapping.has_key?("analyzer"))   # analyzer -> text
      mapping["type"] = "text"
    else                               # no analyzer
      if (mapping.has_key?("index"))    # index
        case (mapping["index"])
          when "analyzed"              # index.analyzed -> text
            mapping["type"] = "text"
          when "not_analyzed"          # index.not_analyzed -> keyword                 
            mapping["type"] = "keyword"
          when "no"                    # index.no -> text
            mapping["type"] = "text"
        end
      else				# no alalezer and no index -> in field keyword, otherwise text
        if field
          mapping["type"] = "keyword"
        else
          mapping["type"] = "text"
        end
      end
    end
  end

end

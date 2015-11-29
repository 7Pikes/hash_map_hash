require 'deep_dup'

class HashMapHash
  attr_reader :mapping

  def initialize(mapping)
    @mapping = mapping.extend(DeepDup)
  end

  def add_nested_properties(nested_properties)
    @mapping.merge! nested_mapping(nested_properties) if nested_properties.any?
    self
  end

  # Data sample (source_data)
  #
  # {"Contractors"=>
  #   {"Contractor"=>
  #     [
  #       {
  #         "OfficialName"=>"FirstAid, Moscow",
  #         "Role"=>"Payer"
  #       },
  #       {
  #        "Id"=>"84266",
  #        "OfficialName"=>"FirstAid, Moscow (442, Glow st)",
  #        "Role"=>"Receiver"
  #       }
  #     ]
  #   },
  #   "Items"=> {
  #     "NumberOfPositions"=> 10
  #   },
  #   "Total" => 123.45
  # }
  #
  # To get data, we should pass a mapping:
  #
  # mapping = {
  #   payer:    ['Contractors', 'Contractor', %w(Role Payer), 'OfficialName'],
  #   receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Id'],
  #   amount:   ['Items', 'NumberOfPositions']
  #   summ:     'Total'
  # }
  #
  # output:
  # {
  #   payer: 'FirstAid, Moscow',
  #   receiver: '84266',
  #   amount: 10,
  #   summ: 123.45
  # }
  def map(source_data)
    mapping.deep_dup.each_with_object({}) do |(attribute_key, attribute_mapping), result|
      result[attribute_key] = filtered_deep_fetch source_data, Array(attribute_mapping)
    end
  end

  private

  # data: hash with source data, for example:
  # {"Contractors"=>
  #   {"Contractor"=>
  #     [
  #       {
  #         "OfficialName"=>"FirstAid, Moscow",
  #         "Role"=>"Payer"
  #       },
  #       {
  #        "Id"=>"84266",
  #        "OfficialName"=>"FirstAid, Moscow (442, Glow st)",
  #        "Role"=>"Receiver"
  #       }
  #     ]
  #   }
  # }
  #
  # data_mapping: mapping for single attribute
  # ['Contractors', 'Contractor', %w(Role Payer), 'Id']
  #
  # This is a recursive method, it takes one key from mapping and uses it
  # to walk through data.
  # Next iteration will receive data and mapping starting from next key.
  #
  # Arrays here are filters.
  # If there is an array in mapping, say, ['Role', 'Payer'], then data on this
  # level also must be some array.
  # It will be filtered using #filter_array_of_hashes
  #
  def filtered_deep_fetch(data, data_mapping)
    current_filter = data_mapping.shift
    return data.fetch(current_filter) if data_mapping.size == 0
    if current_filter.is_a?(Array)
      filtered_deep_fetch filter_array_of_hashes(data, current_filter), data_mapping
    else
      filtered_deep_fetch data.fetch(current_filter), data_mapping
    end
  end

  # array is an array of hashes, for example:
  # [
  #   {
  #     "OfficialName"=>"FirstAid, Moscow",
  #     "Role"=>"Payer"
  #   },
  #   {
  #    "Id"=>"84266",
  #    "OfficialName"=>"FirstAid, Moscow (442, Glow st)",
  #    "Role"=>"Receiver"
  #   }
  # ]
  #
  # keyvalue_filter: key and value for filter, for example ['Role', 'Payer']
  #
  # The output is one particular array element:
  #
  # {
  #   "OfficialName"=>"FirstAid, Moscow",
  #   "Role"=>"Payer"
  # },
  def filter_array_of_hashes(data_array, keyvalue_filter)
    filter_key, filter_value = keyvalue_filter
    data_array.detect do |element|
      element[filter_key] == filter_value
    end
  end

  # This metod translates nested_properties to mapping format.
  # It helps avoid repeating multiple keys on one level
  #
  # Sample:
  # nested_properties = {
  #   prefix: %w(Contractors Contractor),
  #   filter_key: 'Role',
  #   value_key: 'Id',
  #   keys: {
  #     payer: 'Payer',
  #     receiver: 'Receiver'
  #   }
  # }
  #
  # Output:
  #
  # payer:    ['Contractors', 'Contractor', %w(Role Payer), 'Id'],
  # receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Id'],
  #
  def nested_mapping(nested_properties)
    nested_properties[:keys].each_with_object({}) do |(key, raw_key), result|
      result[key] = nested_properties[:prefix] +
        [[nested_properties[:filter_key], raw_key], nested_properties[:value_key]]
    end
  end
end

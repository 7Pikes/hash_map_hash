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

  # Пример данных (source_data)
  #
  # {"Контрагенты"=>
  #   {"Контрагент"=>
  #     [
  #       {
  #         "ОфициальноеНаименование"=>"Аптечка г.Москва",
  #         "Роль"=>"Плательщик"
  #       },
  #       {
  #        "Ид"=>"84266",
  #        "ОфициальноеНаименование"=>"Аптечка г. Москва (442, Заревый пр-д)",
  #        "Роль"=>"Получатель"
  #       }
  #     ]
  #   },
  #   "Позиции"=> {
  #     "КоличествоПозиций"=> 10
  #   },
  #   "Сумма" => 123.45
  # }
  #
  # Чтобы получить из этих данных наименование плательщика и получателя, должен быть передан mapping:
  #
  # mapping = {
  #   payer:    ['Контрагенты', 'Контрагент', %w(Роль Плательщик), 'ОфициальноеНаименование'],
  #   receiver: ['Контрагенты', 'Контрагент', %w(Роль Получатель), 'Ид'],
  #   amount:   ['Позиции', 'КоличествоПозиций']
  #   summ:     'Сумма'
  # }
  #
  # attributes на выходе :
  # {
  #   payer: 'Аптечка г.Москва',
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

  # data: хэш c данными, например source_data
  # data_mapping: маппинг для одного аттрибута, например
  # ['Контрагенты', 'Контрагент', %w(Роль Плательщик), 'Ид']
  #
  # Данные выбираются по первому ключу, в простейшем случае - просто элемент хэша.
  # Метод рекурсивный, второму проходу передается сокращенный на один ключ маппинг и остаток данных.
  #
  # Если первый ключ - это массив (например ['Роль', 'Плательщик']), то и в данных на этом уровне должен быть
  # массив, и он фильтруется с помощью #filter_array_of_hashes
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

  # array: массив хэшей, например:
  # [
  #   {
  #     "ОфициальноеНаименование"=>"Аптечка г.Москва",
  #     "Роль"=>"Плательщик"
  #   },
  #   {
  #    "Ид"=>"84266",
  #    "ОфициальноеНаименование"=>"Аптечка г. Москва (442, Заревый пр-д)",
  #    "Роль"=>"Получатель"
  #   }
  # ]
  #
  # keyvalue_filter: ключ и значение для фильтра, например ['Роль', 'Плательщик']ъ
  #
  # На выходе получаем один элемент массива данных:
  #
  # {
  #   "ОфициальноеНаименование"=>"Аптечка г.Москва",
  #   "Роль"=>"Плательщик"
  # },
  def filter_array_of_hashes(data_array, keyvalue_filter)
    filter_key, filter_value = keyvalue_filter
    data_array.detect do |element|
      element[filter_key] == filter_value
    end
  end

  # метод переводит nested_properties в формат MAPPING.
  # сделан для того, чтобы в случае нескольких вложенных на одном уровне ключей, не повторять эти уровни
  #
  # Пример:
  # nested_properties = {
  #   prefix: %w(Контрагенты Контрагент),
  #   filter_key: 'Роль',
  #   value_key: 'Ид',
  #   keys: {
  #     payer: 'Плательщик',
  #     receiver: 'Получатель'
  #   }
  # }
  #
  # На выходе:
  #
  # payer:    ['Контрагенты', 'Контрагент', %w(Роль Плательщик), 'Ид'],
  # receiver: ['Контрагенты', 'Контрагент', %w(Роль Получатель), 'Ид'],
  #
  def nested_mapping(nested_properties)
    nested_properties[:keys].each_with_object({}) do |(key, raw_key), result|
      result[key] = nested_properties[:prefix] +
        [[nested_properties[:filter_key], raw_key], nested_properties[:value_key]]
    end
  end
end

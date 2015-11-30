require 'spec_helper'

describe HashMapHash do
  let(:mapping) do
    {
      anything: 'thirdkey',
      something: %w(fourthkey fifthkey)
    }
  end
  let(:nested_properties) do
    {
      prefix: %w(firstkey secondkey),
      filter_key: 'filterkey',
      value_key: 'filtervalue',
      keys: {
        everything: 'FirstFilter'
      }
    }
  end
  let(:data) do
    { 'firstkey' =>
      { 'secondkey' =>
        [
          {
            'filterkey' => 'FirstFilter',
            'filtervalue' => 'FirstValue'
          },
          {
            'filterkey' => 'SecondFilter',
            'filtervalue' => 'SecondValue'
          }
        ]
      },
      'thirdkey' => 'ThirdValue',
      'fourthkey' => {
        'fifthkey' => 'FifthValue'
      }
    }
  end

  subject { described_class.new mapping }

  describe '#initialize' do
    specify do
      expect(subject.instance_variable_get('@mapping')).to eq(mapping)
    end
  end

  describe '#map' do
    specify do
      expect(subject.map data).
        to eq(anything: 'ThirdValue', something: 'FifthValue')
    end
  end

  describe '#add_nested_properties' do
    let(:initial_mapping) { { a: :b } }
    let(:nested_mapping) { { c: :d } }
    let(:mapping) { { a: :b, c: :d } }
    let(:nested_properties) { double :nested_properties }
    subject { described_class.new initial_mapping }

    specify do
      expect(nested_properties).to receive(:any?).and_return(true)
      expect(subject).to receive(:nested_mapping).with(nested_properties).
        and_return(nested_mapping)
      expect(subject.add_nested_properties(nested_properties)).to eq(subject)
      expect(subject.instance_variable_get('@mapping')).to eq(mapping)
    end
  end

  describe '#filtered_deep_fetch' do
    let(:filter1) do
      ['firstkey', 'secondkey', %w(filterkey SecondFilter), 'filtervalue']
    end
    let(:filter2) { ['thirdkey'] }

    specify do
      expect(subject.send(:filtered_deep_fetch, data, filter1)).
        to eq('SecondValue')
      expect(subject.send(:filtered_deep_fetch, data, filter2)).
        to eq('ThirdValue')
    end
  end

  describe '#filter_array_of_hashes' do
    let(:array) { data['firstkey']['secondkey'] }
    let(:filter) { %w(filterkey SecondFilter) }

    specify do
      expect(subject.send(:filter_array_of_hashes, array, filter)).
        to eq('filterkey' => 'SecondFilter', 'filtervalue' => 'SecondValue')
    end
  end

  describe '#nested_mapping' do
    let(:nested_mapping) do
      {
        everything: [
          'firstkey',
          'secondkey',
          %w(filterkey FirstFilter),
          'filtervalue'
        ]
      }
    end
    specify do
      expect(subject.send(:nested_mapping, nested_properties)).
        to eq(nested_mapping)
    end
  end
end

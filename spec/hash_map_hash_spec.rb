require 'spec_helper'

describe HashMapHash do
  let(:mapping) do
    {
      payer:    ['Contractors', 'Contractor', %w(Role Payer), 'OfficialName'],
      receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Id'],
      amount:   ['Items', 'NumberOfPositions'],
      summ:     'Total'
    }
  end
  let(:nested_properties) do
    {
      prefix: %w(Contractors Contractor),
      filter_key: 'Role',
      value_key: 'Id',
      keys: {
        receiver: 'Receiver'
      }
    }
  end
  let(:data) do
    { 'Contractors' =>
      { 'Contractor' =>
        [
          {
            'OfficialName' => 'FirstAid, Moscow',
            'Role' => 'Payer'
          },
          {
            'Id' => '84266',
            'OfficialName' => 'FirstAid, Moscow (442, Glow st)',
            'Role' => 'Receiver'
          }
        ]
      },
      'Items' => {
        'NumberOfPositions' => 10
      },
      'Total' => 123.45
    }
  end

  subject { described_class.new mapping }

  describe '#initialize' do
    specify do
      expect(subject.instance_variable_get('@mapping')).to eq(mapping)
    end
  end

  describe '#map' do
    context 'plain data and map' do
      let(:data) do
        {
          'Items' => 10,
          'Total' => 123.0
        }
      end
      let(:mapping) do
        {
          amount: 'Items',
          summ: 'Total'
        }
      end

      specify do
        expect(subject.map data).to eq(
          amount: 10,
          summ: 123.0
        )
      end
    end

    context 'nested' do
      specify do
        expect(subject.map data).to eq(
          payer: 'FirstAid, Moscow',
          receiver: '84266',
          amount: 10,
          summ: 123.45
        )
      end
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
    context 'with filter' do
    let(:filter) { ['Contractors', 'Contractor', %w(Role Receiver), 'Id'] }

    specify do
      expect(subject.send(:filtered_deep_fetch, data, filter)).to eq('84266')
    end
    end

    context 'with one element' do
      let(:filter) { ['Total'] }

      specify do
        expect(subject.send(:filtered_deep_fetch, data, filter)).to eq(123.45)
      end
    end
  end

  describe '#filter_array_of_hashes' do
    let(:array) do
      [
        {
          'OfficialName' => 'FirstAid, Moscow',
          'Role' => 'Payer'
        },
        {
          'Id' => '84266',
          'OfficialName' => 'FirstAid, Moscow (442, Glow st)',
          'Role' => 'Receiver'
        }
      ]
    end
    let(:filter) { %w(Role Payer) }

    specify do
      expect(subject.send(:filter_array_of_hashes, array, filter)).
        to eq('OfficialName' => 'FirstAid, Moscow', 'Role' => 'Payer')
    end
  end

  describe '#nested_mapping' do
    let(:nested_mapping) do
      {
        receiver: ['Contractors', 'Contractor', %w(Role Receiver), 'Id']
      }
    end

    specify do
      expect(subject.send(:nested_mapping, nested_properties)).
        to eq(nested_mapping)
    end
  end
end

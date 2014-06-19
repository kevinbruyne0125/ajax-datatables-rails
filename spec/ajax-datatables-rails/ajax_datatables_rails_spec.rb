require 'spec_helper'

describe AjaxDatatablesRails::Base do
  class Column
    def matches(query)
      []
    end
  end

  class User
    def self.arel_table
      { :foo => Column.new }
    end
  end

  class UserData
    def self.arel_table
      { :bar => Column.new }
    end
  end

  params = {
    :draw => '5',
    :columns => {
      "0" => {
        :data => '0',
        :name => '',
        :searchable => true,
        :orderable => true,
        :search => { :value => '', :regex => false }
      },
      "1" => {
        :data => '1',
        :name => '',
        :searchable => true,
        :orderable => true,
        :search => { :value => '', :regex => false }
      }
    },
    :order => { "0" => { :column => '1', :dir => 'desc' } },
    :start => '0',
    :length => '10',
    :search => { :value => '', :regex => false },
    '_' => '1403141483098'
  }
  let(:view) { double('view', :params => params) }

  describe 'an instance' do
    it 'requires a view_context' do
      expect { AjaxDatatablesRails::Base.new }.to raise_error
    end

    it 'accepts an options hash' do
      datatable = AjaxDatatablesRails::Base.new(view, :foo => 'bar')
      expect(datatable.options).to eq(:foo => 'bar')
    end
  end

  describe 'helper methods' do
    describe '#offset' do
      it 'defaults to 0' do
        default_view = double('view', :params => {})
        datatable = AjaxDatatablesRails::Base.new(default_view)
        expect(datatable.send(:offset)).to eq(0)
      end

      it 'matches the value on view params[:start] minus 1' do
        paginated_view = double('view', :params => { :start => '11' })
        datatable = AjaxDatatablesRails::Base.new(paginated_view)
        expect(datatable.send(:offset)).to eq(10)
      end
    end

    describe '#page' do
      it 'calculates page number from params[:start] and #per_page' do
        paginated_view = double('view', :params => { :start => '11' })
        datatable = AjaxDatatablesRails::Base.new(paginated_view)
        expect(datatable.send(:page)).to eq(2)
      end
    end

    describe '#per_page' do
      it 'defaults to 10' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.send(:per_page)).to eq(10)
      end

      it 'matches the value on view params[:length]' do
        other_view = double('view', :params => { :length => 20 })
        datatable = AjaxDatatablesRails::Base.new(other_view)
        expect(datatable.send(:per_page)).to eq(20)
      end
    end

    describe '#sort_column' do
      it 'returns a column name from the #sorting_columns array' do
        sort_view = double(
          'view',
          :params => {
            :order => {
              '0' => { :column => '1' }
            }
          }
        )
        datatable = AjaxDatatablesRails::Base.new(sort_view)
        datatable.stub(:sortable_columns) { ['foo', 'bar', 'baz'] }

        expect(datatable.send(:sort_column)).to eq('bar')
      end
    end

    describe '#sort_direction' do
      it 'matches value of params[:sSortDir_0]' do
        sorting_view = double(
          'view',
          :params => {
            :order => {
              '0' => { :column => '1', :dir => 'desc' }
            }
          }
        )
        datatable = AjaxDatatablesRails::Base.new(sorting_view)
        expect(datatable.send(:sort_direction)).to eq('DESC')
      end

      it 'can only be one option from ASC or DESC' do
        sorting_view = double(
          'view',
          :params => {
            :order => {
              '0' => { :column => '1', :dir => 'foo' }
            }
          }
        )
        datatable = AjaxDatatablesRails::Base.new(sorting_view)
        expect(datatable.send(:sort_direction)).to eq('ASC')
      end
    end

    describe '#sortable_columns' do
      it 'returns an array representing database columns' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.sortable_columns).to eq([])
      end
    end

    describe '#searchable_columns' do
      it 'returns an array representing database columns' do
        datatable = AjaxDatatablesRails::Base.new(view)
        expect(datatable.searchable_columns).to eq([])
      end
    end
  end

  describe 'perform' do
    let(:results) { double('Collection', :offset => [], :limit => []) }
    let(:view) { double('view', :params => params) }
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    describe '#paginate_records' do
      it 'raises a MethodNotImplementedError' do
        expect { datatable.send(:paginate_records, []) }.to raise_error(
          AjaxDatatablesRails::Base::MethodNotImplementedError
        )
      end
    end

    describe '#sort_records' do
      it 'calls #order on a collection' do
        results.should_receive(:order)
        datatable.send(:sort_records, results)
      end
    end

    describe '#filter_records' do
      let(:records) { double('User', :where => []) }
      let(:search_view) { double('view', :params => params) }

      it 'applies search like functionality on a collection' do
        datatable = AjaxDatatablesRails::Base.new(search_view)
        datatable.stub(:searchable_columns) { ['users.foo'] }

        records.should_receive(:where)
        datatable.send(:filter_records, records)
      end
    end

    describe '#filter_records with multi word model' do
      let(:records) { double('UserData', :where => []) }
      let(:search_view) { double('view', :params => params) }

      it 'applies search like functionality on a collection' do
        datatable = AjaxDatatablesRails::Base.new(search_view)
        datatable.stub(:searchable_columns) { ['user_datas.bar'] }

        records.should_receive(:where)
        datatable.send(:filter_records, records)
      end
    end
  end

  describe 'hook methods' do
    let(:datatable) { AjaxDatatablesRails::Base.new(view) }

    describe '#data' do
      it 'raises a MethodNotImplementedError' do
        expect { datatable.data }.to raise_error(
          AjaxDatatablesRails::Base::MethodNotImplementedError,
          'Please implement this method in your class.'
        )
      end
    end

    describe '#get_raw_records' do
      it 'raises a MethodNotImplementedError' do
        expect { datatable.get_raw_records }.to raise_error(
          AjaxDatatablesRails::Base::MethodNotImplementedError,
          'Please implement this method in your class.'
        )
      end
    end
  end
end

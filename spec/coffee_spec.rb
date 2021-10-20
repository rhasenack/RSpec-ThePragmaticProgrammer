
class Coffee
  def initialize
    @price = 1.00
    @color = :dark
    @temperature = 200.0
  end

  def inspect
    "#{Coffee} with #{ingredients()}"
  end

  def ingredients
    @ingredients ||= []
  end

  def add(ingredient)
    ingredients << ingredient
    @price += 0.25
    if ingredient == :milk
      @color = :light
      @temperature -= 10
    end
  end

  def price
    @price
  end

  def color
    @color
  end

  def temperature
    @temperature
  end

end

RSpec.configure do |config|
  config.example_status_persistence_file_path = './spec/examples.txt'
  config.filter_run_when_matching(focus:true)
end

RSpec.describe 'A cup of coffee' do
  let(:coffee) {Coffee.new}

  it 'costs $1' do
    expect(coffee.price).to eq(1.00)
  end

  context 'with milk' do
    before {coffee.add :milk}

    it 'costs $1.25' do
      expect(coffee.price).to eq(1.25)
    end

    it 'is light in color' do
      # pending 'Color not implemented yet'
      expect(coffee.color).to be(:light)
    end
    it 'is cooler than 200 degrees Fahrenheit' do
      # pending 'Temperature not implemented yet'
      expect(coffee.temperature).to be < (200.0)
    end
  end
end

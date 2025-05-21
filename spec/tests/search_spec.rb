require_relative '../spec_helper'

describe 'Mercado Libre Search Flow' do
  before(:all) do
    @page = SearchPage.new(driver)
  end

  it 'validates search and filters' do
    @page.search('playstation 5')
    @page.click_filter_button
    @page.click_reveal_filters('Nuevo')
    @page.select_filter('Nuevo')
    @page.click_reveal_filters('CDMX')
    @page.select_filter('CDMX')
    @page.click_reveal_filters('Mayor precio')
    @page.select_filter('Mayor precio')
    @page.apply_filters
    results = @page.get_results(5)

    puts "Primeros #{results.size} productos:"
    results.each_with_index do |item, index|
    puts "#{index + 1}. #{item[:title]} - #{item[:price]}"
    end

    expect(results.size).to be >= 5
  end
end

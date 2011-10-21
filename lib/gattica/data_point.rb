require 'csv'

module Gattica
  
  # Represents a single "row" of data containing any number of dimensions, metrics
  
  class DataPoint
    
    include Convertible
    
    attr_reader :id, :updated, :title, :dimensions, :metrics, :xml
    
    # Parses the XML <entry> element
    def initialize(xml)
      @xml = xml.to_s
      @id = xml.at('id').inner_html
      @updated = DateTime.parse(xml.at('updated').inner_html)
      @title = xml.at('title').inner_html
      @dimensions = xml.search('dxp:dimension').collect do |dimension|
        { dimension.attributes['name'].split(':').last.to_sym => dimension.attributes['value'].split(':').last }
      end
      @metrics = xml.search('dxp:metric').collect do |metric|
				if metric.attributes['type'] == 'percent'
        	{ metric.attributes['name'].split(':').last.to_sym => metric.attributes['value'].split(':').last.to_f.round(2) }
				else
        	{ metric.attributes['name'].split(':').last.to_sym => metric.attributes['value'].split(':').last.to_i }
				end
      end
    end
    
    
    # Outputs in Comma Seperated Values format
    def to_csv(format = :long)
      output = ''
      columns = []
      
      # only output
      case format
      when :long
        [@id, @updated, @title].each { |c| columns << c }
      end
      
      # output all dimensions
      @dimensions.map {|d| d.value}.each { |c| columns << c }
      
      # output all metrics
      @metrics.map {|m| m.value}.each { |c| columns << c }

      output = CSV.generate_line(columns)      
      return output
    end
    
    
    def to_yaml
      { 'id' => @id,
        'updated' => @updated,
        'title' => @title,
        'dimensions' => @dimensions,
        'metrics' => @metrics }.to_yaml
    end
    
  end
  
end

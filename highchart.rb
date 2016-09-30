class HighChart
  attr_accessor :render_to, :chart_type, :title_text, :x_categories,
                :y_categories, :series_data

  def initialize(options={}, &block)
    self.render_to = options[:render_to] || 'container'
    self.chart_type = options[:chart_type] || nil
    self.title_text = options[:title_text] || nil
    self.x_categories = options[:x_categories] || []
    self.y_categories = options[:y_categories] || 'y'
    self.series_data = options[:series_data] || {}

    self.instance_eval &block
  end

end
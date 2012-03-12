class SupersizeFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    options[:input_html].nil? ? options[:input_html] = {:class => 'supersize'} : options[:input_html].merge!({:class => 'medium'})
    options[:error_html].nil? ? options[:error_html] = {:class => 'supersize'} : options[:error_html].merge!({:class => 'medium'})
    super
  end
end
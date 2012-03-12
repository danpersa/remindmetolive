class MediumFormBuilder < SimpleForm::FormBuilder
  def input(attribute_name, options = {}, &block)
    options[:input_html].nil? ? options[:input_html] = {:class => 'medium'} : options[:input_html].merge!({:class => 'medium'})
    super
  end
end
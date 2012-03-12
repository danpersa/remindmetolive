class StringInput < SimpleForm::Inputs::StringInput
  def input_html_classes
    super + [:'input-text']
  end
end

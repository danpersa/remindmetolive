class PasswordInput < SimpleForm::Inputs::PasswordInput
  def input_html_classes
    super + [:'input-text']
  end
end

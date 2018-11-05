require 'minitest/autorun'
require 'i18n'

class SubstitutesI18Backend < I18n::Backend::Simple
  def translate(locale, key, options = {})
    translation = super(locale, key, options)

    substitute_variables(translation)
  end

  private 

  def substitute_variables(translation)
    translation.scan(/\@\[\w*\]/).each do |variable|
      translation.gsub!(variable, I18n.translate(variable[2..-2]))
    end

    translation
  end
end

class Tests < Minitest::Test

  I18n.backend = SubstitutesI18Backend.new
  
  I18n.backend.store_translations('en', simple_key: 'There are no substitutions')
  I18n.backend.store_translations('en', key_with_variable: 'I have @[number] substitution')
  I18n.backend.store_translations('en', number: 'one')
  I18n.backend.store_translations('en', key_with_nested_varibles: 'He said: @[key_with_variable]')
  I18n.backend.store_translations('en', key_with_more_variables: 'You can @[action] as many @[subject] as you @[verb]')
  I18n.backend.store_translations('en', action: 'substitute')
  I18n.backend.store_translations('en', subject: 'keys')
  I18n.backend.store_translations('en', verb: 'wish')
  
  def test_translation_no_variables
    assert_equal "There are no substitutions", I18n.translate(:simple_key)
  end

  def test_translation_simple_variables
    assert_equal "I have one substitution", I18n.translate(:key_with_variable)
  end

  def test_translation_nested_variables
    assert_equal "He said: I have one substitution", I18n.translate(:key_with_nested_varibles)
  end

  def test_translation_more_variables
    assert_equal "You can substitute as many keys as you wish", I18n.translate(:key_with_more_variables)
  end
end

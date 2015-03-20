# encoding: utf-8

class String
  def as_html
    require 'redcloth'
    require 'gilenson'
    Gilenson::RedClothExtra.new(self).to_html.html_safe
  end

  def as_text
    require 'nokogiri'
    Nokogiri::HTML(self.gsub(%r{</?span.*?>}, '').gsub(/>/, '> ')).text.squish
  end

  def without_table
    self.gsub(/<table>.*<\/table>/m, '')
  end

  def truncated(length = 230, separator = ' ')
    self.truncate(length, :separator => separator, :omission => '…')
  end

  def excerpt
    self.as_html.without_table.as_text.truncated
  end

  def text_gilensize
    self.to_s.gilensize(:html => false, :raw_output => true).gsub(%r{</?.*?>}, '').gsub(/\A[[:space:]]+|[[:space:]]+\Z/, '').squish
  end

  def gilensize_with_html_safe(*args)
    args.empty? ? gilensize_without_html_safe.html_safe : gilensize_without_html_safe(*args)
  end

  def replace_special_html_chars
    self.gsub("&ndash;", "-").gsub("&mdash;", "-").gsub("&nbsp;", " ").gsub("&#160;", " ")
  end

  def from_russian_to_param
    Russian.translit(self).underscore.gsub(/\s+|\//, "_")
  end

  def capitalized
    mb_chars.capitalize.to_s
  end

  def is_json?
    begin
      !!JSON.parse(self)
    rescue
      false
    end
  end

  alias_method_chain :gilensize, :html_safe

end

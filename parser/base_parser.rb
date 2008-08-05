module BaseParser
  def parse_page_of_type(type, content)
    send(('parse_'+type).to_sym, content)
  end
end

class Hash
  def to_params
    params = ''
    stack = []

    each{|k, v| v.is_a?(Hash) ? stack << [k,v] : params << "#{k}=#{v}&"}
    stack.each{|parent, hash| hash.each{|k, v| v.is_a?(Hash) ? stack << ["#{parent}[#{k}]", v] : params << "#{parent}[#{k}]=#{v}&"}}

    params.chop! # trailing &
  end
end

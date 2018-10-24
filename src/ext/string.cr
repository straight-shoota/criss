class String
  def slugify(preserve_case = false) : String
    result = gsub(/[^[:alnum:]]+/, '-').lchop('-').rchop('-')
    preserve_case ? result : result.downcase
  end
end

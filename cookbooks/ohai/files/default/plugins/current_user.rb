provides 'current_user'

require 'etc'

def fix_encoding(str)
  str.force_encoding(Encoding.default_external) if str.respond_to?(:force_encoding)
  str
end

unless current_user
  current_user fix_encoding(Etc.getlogin)
end

define :php_fpm_pool do
  node.default[:php][:fpm][:pools][params[:name].to_sym] = params
  include_recipe "php::fpm"
end

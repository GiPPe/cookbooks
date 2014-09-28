default[:nginx][:use_flags] = []

default[:nginx][:worker_processes] = node[:cpu][:total]
default[:nginx][:worker_connections] = "1024"

default[:nginx][:tcp_nopush] = "on"
default[:nginx][:tcp_nodelay] = "on"

default[:nginx][:client_body_timeout] = 60
default[:nginx][:client_header_timeout] = 60
default[:nginx][:client_max_body_size] = "10M"
default[:nginx][:keepalive_timeout] = 75
default[:nginx][:send_timeout] = 60

default[:nginx][:fastcgi_buffers] = 256

default[:nginx][:php][:max_children] = "4"

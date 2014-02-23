# add vendor lib directory to path
from nepal import generate_vendor_paths
generate_vendor_paths('/usr/lib/nepal')

# import default settings
from nepal.settings import *

# main IP address
MAIN_IPADDRESS = '<%= node[:ipaddress] %>'
FQDN = '<%= node[:fqdn] %>'

# database configuration
DATABASE_NAME = 'nepal'
DATABASE_USER = 'nepal'
DATABASE_PASSWORD = '<%= @database_password %>'

ADMINS = (('hostmaster', '<%= node[:contacts][:hostmaster] %>'),)
MANAGERS = ADMINS
DEFAULT_FROM_EMAIL = '<%= node[:contacts][:hostmaster] %>'

# local time zone for this installation
TIME_ZONE = '<%= node[:timezone] %>'

# language code for this installation
LANGUAGE_CODE = '<%= node[:nepal][:language_code] %>'

# Make this unique, and don't share it with anybody.
SECRET_KEY = '<%= @secret_key %>'

# install time paths
NEPAL_ROOTDIR = '/srv'
NEPAL_SYSTEMDIR = '/srv/system'
MEDIA_ROOT = '/usr/share/nepal/media/'
LOCALE_PATHS = ('/usr/share/nepal/locale/',)
TEMPLATE_DIRS = ('/usr/share/nepal/templates/',)
NEPALD_LOGFILE = '/srv/system/logs/nepald.log'

<% if node[:nepal][:debug] %>
# enable debugging
DEBUG = True
TEMPLATE_DEBUG = True
<% end %>

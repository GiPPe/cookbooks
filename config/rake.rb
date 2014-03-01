# Configure the Rakefile's tasks.

# The company name - used for SSL certificates, and in srvious other places
COMPANY_NAME = "Example Com"

# The Country Name to use for SSL Certificates
SSL_COUNTRY_NAME = "DE"

# The State Name to use for SSL Certificates
SSL_STATE_NAME = "Berlin"

# The Locality Name for SSL - typically, the city
SSL_LOCALITY_NAME = "Berlin"

# What department?
SSL_ORGANIZATIONAL_UNIT_NAME = "Operations"

# The SSL contact email address
SSL_EMAIL_ADDRESS = "hostmaster@example.com"

# make rake more silent
RakeFileUtils.verbose_flag = false
Chef::Log.level = :error

# The top of the repository checkout
TOPDIR = File.expand_path(File.join(File.dirname(__FILE__), ".."))
CONFIG_FILE = File.expand_path(File.join(TOPDIR, ".chef", "config.rb"))

# directories for entities
BAGS_DIR = File.expand_path(File.join(TOPDIR, "data_bags"))
COOKBOOKS_DIR = File.expand_path(File.join(TOPDIR, "cookbooks"))
ENVIRONMENTS_DIR = File.expand_path(File.join(TOPDIR, "environments"))
SITE_COOKBOOKS_DIR = File.expand_path(File.join(TOPDIR, "site-cookbooks"))
TEMPLATES_DIR = File.expand_path(File.join(TOPDIR, "tasks", "templates"))

# Directories needed by the SSL tasks
SSL_CA_DIR = File.expand_path(File.join(TOPDIR, "ca"))
SSL_CERT_DIR = File.expand_path(File.join(TOPDIR, "site-cookbooks/certificates/files/default/certificates"))

# OpenSSL config file
SSL_CONFIG_FILE = File.expand_path(File.join(TOPDIR, "config", "openssl.cnf"))

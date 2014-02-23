require "highline/import"

namespace :user do

  desc "Create a new user data bag"
  task :create, :login, :name, :email, :tags, :key do |t, args|
    login = args.login || ask('Login: ') do |q|
      q.validate = /^\w+$/
    end

    name = args.name || ask('Name: ')
    email = args.email || ask('E-Mail: ')
    tags = (args.tags || ask('Tags (space-seperated): ')).split(' ')
    key = args.key || ask('SSH Public Key: ')

    args = Rake::TaskArguments.new([:cn], [login])
    Rake::Task["ssl:do_cert"].execute(args)

    random = %x(pwgen -s 10 1).chomp

    puts
    puts ">>> Creating new user #{login} with password #{random} <<<"
    puts

    salt = SecureRandom.hex(8)
    password1 = random.crypt("$1$#{salt}$")
    salt = SecureRandom.hex(4)
    password = random.crypt("$6$#{salt}$")

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'user_databag.json')))

    path = File.join(BAGS_DIR, "users")
    FileUtils.mkdir_p(path)

    File.open(File.join(path, "#{login}.json"), "w") do |f|
      f.puts(erb.result(b))
    end
  end

  desc "Suspend a user account"
  task :suspend do
    login = ask('Login: ') do |q|
      q.validate = /^\w+$/
    end

    user = Chef::DataBagItem.new
    user.from_file(File.join(BAGS_DIR, 'users', "#{login}.json"))
    puts user.inspect

    name = user[:comment]
    email = user[:email]
    tags = user[:tags]
    random = "user account is disabled"
    password = password1 = '!'
    key = nil

    b = binding()
    erb = Erubis::Eruby.new(File.read(File.join(TEMPLATES_DIR, 'user_databag.json')))

    path = File.join(BAGS_DIR, "users")
    FileUtils.mkdir_p(path)

    File.open(File.join(path, "#{login}.json"), "w") do |f|
      f.puts(erb.result(b))
    end
  end

end

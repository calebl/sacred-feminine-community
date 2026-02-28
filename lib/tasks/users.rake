namespace :users do
  desc "Create a new user account. Usage: rake users:create [-- --email=EMAIL --name=NAME --password=PASS --role=ROLE --city=CITY --country=COUNTRY]"
  task create: :environment do
    args = parse_cli_args

    email    = args["email"]    || prompt("Email")
    name     = args["name"]     || prompt("Name")
    password = args["password"] || prompt_secret("Password (min 6 chars)")
    role     = args["role"]     || prompt("Role (attendee/admin)", default: "attendee")
    city     = args["city"]     || prompt("City", optional: true)
    country  = args["country"]  || prompt("Country", optional: true)

    user = User.new(
      email: email,
      name: name,
      password: password,
      password_confirmation: password,
      role: role,
      city: city.presence,
      country: country.presence
    )

    if user.save
      puts "\n\e[32m✓ User created successfully!\e[0m"
      print_user(user)
    else
      puts "\n\e[31m✗ Failed to create user:\e[0m"
      user.errors.full_messages.each { |msg| puts "  - #{msg}" }
      exit 1
    end
  end

  desc "List all user accounts"
  task list: :environment do
    users = User.order(:created_at)

    if users.empty?
      puts "No users found."
      next
    end

    puts format("%-4s %-30s %-35s %-10s %-20s %s", "ID", "Name", "Email", "Role", "City", "Created")
    puts "-" * 130

    users.find_each do |user|
      puts format(
        "%-4d %-30s %-35s %-10s %-20s %s",
        user.id,
        user.name.truncate(28),
        user.email.truncate(33),
        user.role,
        (user.city || "-").truncate(18),
        user.created_at.strftime("%Y-%m-%d %H:%M")
      )
    end

    puts "\nTotal: #{users.count} user(s)"
  end

  private

  def parse_cli_args
    args = {}
    ARGV.drop_while { |a| a != "--" }.drop(1).each do |arg|
      if arg =~ /\A--(\w+)=(.*)\z/
        args[$1] = $2
      end
    end
    args
  end

  def prompt(label, default: nil, optional: false)
    suffix = if default
               " [#{default}]"
             elsif optional
               " (optional)"
             else
               ""
             end

    print "#{label}#{suffix}: "
    value = $stdin.gets&.strip

    if value.nil? || value.empty?
      return default if default
      return "" if optional
      puts "\e[31m#{label} is required.\e[0m"
      exit 1
    end

    value
  end

  def prompt_secret(label)
    print "#{label}: "

    begin
      system("stty -echo", exception: true)
      value = $stdin.gets&.strip
      puts
    ensure
      system("stty echo", exception: true)
    end

    if value.nil? || value.empty?
      puts "\e[31mPassword is required.\e[0m"
      exit 1
    end

    value
  end

  def print_user(user)
    puts "  ID:      #{user.id}"
    puts "  Name:    #{user.name}"
    puts "  Email:   #{user.email}"
    puts "  Role:    #{user.role}"
    puts "  City:    #{user.city}" if user.city.present?
    puts "  Country: #{user.country}" if user.country.present?
  end
end

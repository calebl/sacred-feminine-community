if Rails.env.development?
  admin = User.find_or_create_by!(email: "admin@sacredfeminine.com") do |u|
    u.name = "Admin"
    u.password = "password123"
    u.password_confirmation = "password123"
    u.role = :admin
    u.invitation_accepted_at = Time.current
  end

  puts "Seeded admin user: #{admin.email}"
end

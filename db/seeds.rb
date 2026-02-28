if Rails.env.development?
  password = "password123"

  admin = User.find_or_create_by!(email: "admin@sacredfeminine.com") do |u|
    u.name = "Admin"
    u.password = password
    u.password_confirmation = password
    u.role = :admin
    u.invitation_accepted_at = Time.current
  end

  puts "Seeded admin user: #{admin.email}"

  # --- Attendees ---
  attendees_data = [
    { name: "Luna Morales", email: "luna@example.com", city: "Bozeman", country: "United States", bio: "Yoga teacher and herbalist.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Sage Whitfield", email: "sage@example.com", city: "Missoula", country: "United States", bio: "Writer and wilderness guide.", latitude: 46.8721, longitude: -113.9940, show_on_map: true },
    { name: "Aria Chen", email: "aria@example.com", city: "Portland", country: "United States", bio: "Acupuncturist and meditation teacher.", latitude: 45.5152, longitude: -122.6784, show_on_map: true },
    { name: "Willow Hart", email: "willow@example.com", city: "Ashland", country: "United States", bio: "Dance therapist and ceremonialist.", latitude: 42.1946, longitude: -122.7095, show_on_map: true },
    { name: "Maya Johansson", email: "maya@example.com", city: "Seattle", country: "United States", bio: "Breathwork facilitator.", latitude: 47.6062, longitude: -122.3321, show_on_map: true },
    { name: "Freya Dubois", email: "freya@example.com", city: "Bozeman", country: "United States", bio: "Midwife and plant medicine advocate.", latitude: 45.6836, longitude: -111.0507, show_on_map: true },
    { name: "Iris Nakamura", email: "iris@example.com", city: "Whitefish", country: "United States", bio: "Sound healer and singer.", latitude: 48.4106, longitude: -114.3529, show_on_map: true },
    { name: "Juniper Ross", email: "juniper@example.com", city: "Livingston", country: "United States", bio: "Astrologer and tarot reader.", latitude: 45.6627, longitude: -110.5612, show_on_map: true },
    { name: "Dahlia Fernandez", email: "dahlia@example.com", city: "Santa Fe", country: "United States", bio: "Ceramicist and earth keeper.", latitude: 35.6870, longitude: -105.9378, show_on_map: true },
    { name: "Celeste Okafor", email: "celeste@example.com", city: "Denver", country: "United States", bio: "Reiki practitioner and poet.", latitude: 39.7392, longitude: -104.9903, show_on_map: true },
    { name: "Rowan Mitchell", email: "rowan@example.com", city: "Bozeman", country: "United States", bio: "Herbalist and forager.", latitude: 45.6700, longitude: -111.0350, show_on_map: true },
    { name: "Hazel Bergström", email: "hazel@example.com", city: "Helena", country: "United States", bio: "Doula and womb keeper.", latitude: 46.5958, longitude: -112.0270, show_on_map: true },
    { name: "Ember Solano", email: "ember@example.com", city: "Sedona", country: "United States", bio: "Fire ceremony guide.", latitude: 34.8697, longitude: -111.7610, show_on_map: true },
    { name: "Clover Bennett", email: "clover@example.com", city: "Boise", country: "United States", bio: "Herbalist and homesteader.", latitude: 43.6150, longitude: -116.2023, show_on_map: true },
    { name: "Wren Abadi", email: "wren@example.com", city: "Bozeman", country: "United States", bio: "Bodyworker and trauma-informed coach.", latitude: 45.6890, longitude: -111.0280, show_on_map: true },
    { name: "Fern Delacroix", email: "fern@example.com", city: "Taos", country: "United States", bio: "Painter and vision quest guide.", latitude: 36.4072, longitude: -105.5731, show_on_map: true },
    { name: "Soleil Prasad", email: "soleil@example.com", city: "Bend", country: "United States", bio: "Kundalini yoga teacher.", latitude: 44.0582, longitude: -121.3153, show_on_map: true },
    { name: "Ivy Thornton", email: "ivy@example.com", city: "Big Sky", country: "United States", bio: "Mountain guide and storyteller.", latitude: 45.2833, longitude: -111.4014, show_on_map: false },
    { name: "Aurora Reyes", email: "aurora@example.com", city: "Bozeman", country: "United States", bio: "Community organizer and healer.", latitude: 45.6750, longitude: -111.0460, show_on_map: true },
    { name: "Meadow Kim", email: "meadow@example.com", city: "Jackson", country: "United States", bio: "Nutritionist and fermenter.", latitude: 43.4799, longitude: -110.7624, show_on_map: true },
    { name: "Elara Lindqvist", email: "elara@example.com", city: "Stockholm", country: "Sweden", bio: "Foraging guide and Nordic folk healer.", latitude: 59.3293, longitude: 18.0686, show_on_map: true },
    { name: "Maeve Byrne", email: "maeve@example.com", city: "Galway", country: "Ireland", bio: "Herbalist and Celtic ceremonialist.", latitude: 53.2707, longitude: -9.0568, show_on_map: true },
    { name: "Noor Haddad", email: "noor@example.com", city: "Barcelona", country: "Spain", bio: "Flamenco dancer and somatic therapist.", latitude: 41.3874, longitude: 2.1686, show_on_map: true },
    { name: "Lina Vogel", email: "lina@example.com", city: "Berlin", country: "Germany", bio: "Breathwork facilitator and artist.", latitude: 52.5200, longitude: 13.4050, show_on_map: true },
    { name: "Cosima Rossi", email: "cosima@example.com", city: "Florence", country: "Italy", bio: "Herbalist and temple arts teacher.", latitude: 43.7696, longitude: 11.2558, show_on_map: true }
  ]

  attendees = attendees_data.map do |data|
    User.find_or_create_by!(email: data[:email]) do |u|
      u.name = data[:name]
      u.password = password
      u.password_confirmation = password
      u.role = :attendee
      u.city = data[:city]
      u.country = data[:country]
      u.bio = data[:bio]
      u.latitude = data[:latitude]
      u.longitude = data[:longitude]
      u.show_on_map = data[:show_on_map]
      u.invitation_accepted_at = Time.current
    end
  end

  puts "Seeded #{attendees.size} attendee accounts"

  # --- Cohorts ---
  cohorts_data = [
    {
      name: "Bozeman Spring Retreat 2025",
      description: "A weekend of reconnection, ceremony, and sisterhood in the Gallatin Valley.",
      retreat_location: "Bozeman, Montana",
      retreat_date: Date.new(2025, 4, 18),
      member_indices: [0, 1, 5, 10, 14, 18]
    },
    {
      name: "Solstice Gathering",
      description: "Celebrating the summer solstice with fire ceremony, song, and movement.",
      retreat_location: "Livingston, Montana",
      retreat_date: Date.new(2025, 6, 21),
      member_indices: [2, 3, 7, 8, 12, 15, 19]
    },
    {
      name: "Mountain Women's Circle",
      description: "Monthly circle for women rooted in the Northern Rockies.",
      retreat_location: "Whitefish, Montana",
      retreat_date: Date.new(2025, 9, 5),
      member_indices: [1, 4, 6, 9, 11, 13, 17]
    },
    {
      name: "Desert Rose Retreat",
      description: "A deep dive into plant medicine, ceremony, and desert stillness.",
      retreat_location: "Sedona, Arizona",
      retreat_date: Date.new(2025, 10, 10),
      member_indices: [3, 8, 12, 15, 16]
    },
    {
      name: "Winter Womb Retreat 2026",
      description: "Honoring the dark season with rest, reflection, and nourishment.",
      retreat_location: "Big Sky, Montana",
      retreat_date: Date.new(2026, 1, 24),
      member_indices: [0, 2, 5, 9, 10, 14, 17, 18, 19, 20, 22]
    },
    {
      name: "European Sisters Circle",
      description: "Connecting women across Europe through seasonal ceremony and shared practice.",
      retreat_location: "Florence, Italy",
      retreat_date: Date.new(2026, 5, 15),
      member_indices: [20, 21, 22, 23, 24]
    }
  ]

  cohorts_data.each do |data|
    cohort = Cohort.find_or_create_by!(name: data[:name]) do |c|
      c.description = data[:description]
      c.retreat_location = data[:retreat_location]
      c.retreat_date = data[:retreat_date]
      c.creator = admin
    end

    data[:member_indices].each do |i|
      CohortMembership.find_or_create_by!(cohort: cohort, user: attendees[i])
    end

    puts "Seeded cohort: #{cohort.name} (#{data[:member_indices].size} members)"
  end
end

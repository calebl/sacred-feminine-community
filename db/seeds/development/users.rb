dm_privacy_options = User.dm_privacies.keys

admin = users.create :admin,
  name: "Admin",
  email: "admin@sacredfeminine.com",
  role: :admin

puts "Seeded admin user: #{admin.email}"

attendees_data = [
  { label: :luna,     name: "Luna Morales",      email: "luna@example.com",     city: "Bozeman",    state: "Montana",     country: "United States", bio: "Yoga teacher and herbalist.",                    latitude: 45.6770, longitude: -111.0429, show_on_map: true },
  { label: :sage,     name: "Sage Whitfield",    email: "sage@example.com",     city: "Missoula",   state: "Montana",     country: "United States", bio: "Writer and wilderness guide.",                   latitude: 46.8721, longitude: -113.9940, show_on_map: true },
  { label: :aria,     name: "Aria Chen",         email: "aria@example.com",     city: "Portland",   state: "Oregon",      country: "United States", bio: "Acupuncturist and meditation teacher.",          latitude: 45.5152, longitude: -122.6784, show_on_map: true },
  { label: :willow,   name: "Willow Hart",       email: "willow@example.com",   city: "Ashland",    state: "Oregon",      country: "United States", bio: "Dance therapist and ceremonialist.",             latitude: 42.1946, longitude: -122.7095, show_on_map: true },
  { label: :maya,     name: "Maya Johansson",    email: "maya@example.com",     city: "Seattle",    state: "Washington",  country: "United States", bio: "Breathwork facilitator.",                       latitude: 47.6062, longitude: -122.3321, show_on_map: true },
  { label: :freya,    name: "Freya Dubois",      email: "freya@example.com",    city: "Bozeman",    state: "Montana",     country: "United States", bio: "Midwife and plant medicine advocate.",           latitude: 45.6770, longitude: -111.0429, show_on_map: true },
  { label: :iris,     name: "Iris Nakamura",     email: "iris@example.com",     city: "Whitefish",  state: "Montana",     country: "United States", bio: "Sound healer and singer.",                      latitude: 48.4106, longitude: -114.3529, show_on_map: true },
  { label: :juniper,  name: "Juniper Ross",      email: "juniper@example.com",  city: "Livingston", state: "Montana",     country: "United States", bio: "Astrologer and tarot reader.",                  latitude: 45.6627, longitude: -110.5612, show_on_map: true },
  { label: :dahlia,   name: "Dahlia Fernandez",  email: "dahlia@example.com",   city: "Santa Fe",   state: "New Mexico",  country: "United States", bio: "Ceramicist and earth keeper.",                  latitude: 35.6870, longitude: -105.9378, show_on_map: true },
  { label: :celeste,  name: "Celeste Okafor",    email: "celeste@example.com",  city: "Denver",     state: "Colorado",    country: "United States", bio: "Reiki practitioner and poet.",                  latitude: 39.7392, longitude: -104.9903, show_on_map: true },
  { label: :rowan,    name: "Rowan Mitchell",    email: "rowan@example.com",    city: "Bozeman",    state: "Montana",     country: "United States", bio: "Herbalist and forager.",                        latitude: 45.6770, longitude: -111.0429, show_on_map: true },
  { label: :hazel,    name: "Hazel Bergström",   email: "hazel@example.com",    city: "Helena",     state: "Montana",     country: "United States", bio: "Doula and womb keeper.",                        latitude: 46.5958, longitude: -112.0270, show_on_map: true },
  { label: :ember,    name: "Ember Solano",      email: "ember@example.com",    city: "Sedona",     state: "Arizona",     country: "United States", bio: "Fire ceremony guide.",                          latitude: 34.8697, longitude: -111.7610, show_on_map: true },
  { label: :clover,   name: "Clover Bennett",    email: "clover@example.com",   city: "Boise",      state: "Idaho",       country: "United States", bio: "Herbalist and homesteader.",                    latitude: 43.6150, longitude: -116.2023, show_on_map: true },
  { label: :wren,     name: "Wren Abadi",        email: "wren@example.com",     city: "Bozeman",    state: "Montana",     country: "United States", bio: "Bodyworker and trauma-informed coach.",          latitude: 45.6770, longitude: -111.0429, show_on_map: true },
  { label: :fern,     name: "Fern Delacroix",    email: "fern@example.com",     city: "Taos",       state: "New Mexico",  country: "United States", bio: "Painter and vision quest guide.",                latitude: 36.4072, longitude: -105.5731, show_on_map: true },
  { label: :soleil,   name: "Soleil Prasad",     email: "soleil@example.com",   city: "Portland",   state: "Oregon",      country: "United States", bio: "Kundalini yoga teacher.",                       latitude: 45.5152, longitude: -122.6784, show_on_map: true },
  { label: :ivy,      name: "Ivy Thornton",      email: "ivy@example.com",      city: "Big Sky",    state: "Montana",     country: "United States", bio: "Mountain guide and storyteller.",                latitude: 45.2833, longitude: -111.4014, show_on_map: false },
  { label: :aurora,   name: "Aurora Reyes",      email: "aurora@example.com",   city: "Bozeman",    state: "Montana",     country: "United States", bio: "Community organizer and healer.",                latitude: 45.6770, longitude: -111.0429, show_on_map: true },
  { label: :meadow,   name: "Meadow Kim",        email: "meadow@example.com",   city: "Jackson",    state: "Wyoming",     country: "United States", bio: "Nutritionist and fermenter.",                   latitude: 43.4799, longitude: -110.7624, show_on_map: true },
  { label: :elara,    name: "Elara Lindqvist",   email: "elara@example.com",    city: "Stockholm",                        country: "Sweden",        bio: "Foraging guide and Nordic folk healer.",        latitude: 59.3293, longitude: 18.0686,   show_on_map: true },
  { label: :maeve,    name: "Maeve Byrne",       email: "maeve@example.com",    city: "Galway",                           country: "Ireland",       bio: "Herbalist and Celtic ceremonialist.",           latitude: 53.2707, longitude: -9.0568,   show_on_map: true },
  { label: :noor,     name: "Noor Haddad",       email: "noor@example.com",     city: "Barcelona",                        country: "Spain",         bio: "Flamenco dancer and somatic therapist.",        latitude: 41.3874, longitude: 2.1686,    show_on_map: true },
  { label: :lina,     name: "Lina Vogel",        email: "lina@example.com",     city: "Berlin",                           country: "Germany",       bio: "Breathwork facilitator and artist.",            latitude: 52.5200, longitude: 13.4050,   show_on_map: true },
  { label: :cosima,   name: "Cosima Rossi",      email: "cosima@example.com",   city: "Florence",                         country: "Italy",         bio: "Herbalist and temple arts teacher.",            latitude: 43.7696, longitude: 11.2558,   show_on_map: true },
  { label: :paloma,   name: "Paloma Vega",       email: "paloma@example.com",   city: "Portland",   state: "Oregon",      country: "United States", bio: "Herbalist and birth worker.",                   latitude: 45.5152, longitude: -122.6784, show_on_map: true },
  { label: :seren,    name: "Seren Watts",       email: "seren@example.com",    city: "Denver",     state: "Colorado",    country: "United States", bio: "Crystal healer and astrologer.",                latitude: 39.7392, longitude: -104.9903, show_on_map: true },
  { label: :thea,     name: "Thea Moreau",       email: "thea@example.com",     city: "Denver",     state: "Colorado",    country: "United States", bio: "Yoga therapist and retreat leader.",             latitude: 39.7392, longitude: -104.9903, show_on_map: true },
  { label: :opal,     name: "Opal Sinclair",     email: "opal@example.com",     city: "Seattle",    state: "Washington",  country: "United States", bio: "Aromatherapist and moon circle host.",          latitude: 47.6062, longitude: -122.3321, show_on_map: true },
  { label: :briar,    name: "Briar Kowalski",    email: "briar@example.com",    city: "Seattle",    state: "Washington",  country: "United States", bio: "Herbalist and women's health advocate.",        latitude: 47.6062, longitude: -122.3321, show_on_map: true },
  { label: :saskia,   name: "Saskia de Vries",   email: "saskia@example.com",   city: "Berlin",                           country: "Germany",       bio: "Sound bath facilitator and bodyworker.",        latitude: 52.5200, longitude: 13.4050,   show_on_map: true },
  { label: :anja,     name: "Anja Müller",       email: "anja@example.com",     city: "Berlin",                           country: "Germany",       bio: "Dance therapist and women's circle keeper.",    latitude: 52.5200, longitude: 13.4050,   show_on_map: true }
]

attendees_data.each_with_index do |data, i|
  label = data.delete(:label)
  users.create label,
    role: :attendee,
    dm_privacy: dm_privacy_options[i % dm_privacy_options.size],
    **data
end

puts "Seeded #{attendees_data.size} attendee accounts"

groups.create :herbal_medicine,
  name: "Herbal Medicine Circle",
  description: "A space for sharing plant wisdom, recipes, and seasonal herbal practices.",
  creator: users.admin

[ users.luna, users.freya, users.rowan, users.clover ].each do |user|
  group_memberships.create group: groups.herbal_medicine, user: user
end

groups.create :breathwork,
  name: "Morning Breathwork",
  description: "Daily breathwork practice and accountability. Share your practice, ask questions, and grow together.",
  creator: users.admin

[ users.aria, users.maya, users.soleil ].each do |user|
  group_memberships.create group: groups.breathwork, user: user
end

groups.create :creative_arts,
  name: "Creative Arts & Expression",
  description: "For those called to express through art, dance, music, and craft. Share your creations and inspire each other.",
  creator: users.admin

[ users.willow, users.dahlia, users.fern ].each do |user|
  group_memberships.create group: groups.creative_arts, user: user
end

groups.create :book_club,
  name: "Book Club: Women Who Run With the Wolves",
  description: "Reading and discussing Clarissa Pinkola Estés' classic together, one chapter at a time.",
  creator: users.admin

[ users.sage, users.celeste, users.hazel, users.wren ].each do |user|
  group_memberships.create group: groups.book_club, user: user
end

groups.create :european_traditions,
  name: "European Traditions Exchange",
  description: "Connecting across borders to share folk healing, seasonal rituals, and ancestral practices from European traditions.",
  creator: users.admin

[ users.elara, users.maeve ].each do |user|
  group_memberships.create group: groups.european_traditions, user: user
end

# Groups created by attendees (not the admin dev login), so they appear as
# available to join on the groups index when signed in as admin.
joinable_groups = [
  { label: :moon_circle,      name: "New Moon Circle",
    description: "Gathering each new moon to set intentions, share, and hold space for one another.",
    creator: :luna,    members: [ :iris, :juniper, :celeste ] },
  { label: :womb_wisdom,      name: "Womb Wisdom",
    description: "Exploring menstrual cycle awareness, fertility, and the wisdom of the womb together.",
    creator: :hazel,   members: [ :paloma, :briar ] },
  { label: :sound_healing,    name: "Sound Healing Collective",
    description: "Sharing sound baths, voice work, and vibrational healing practices.",
    creator: :iris,    members: [ :opal, :saskia ] },
  { label: :tarot_divination, name: "Tarot & Divination",
    description: "Pulling cards, reading the stars, and developing our intuitive practices.",
    creator: :juniper, members: [ :seren, :celeste, :cosima ] },
  { label: :earth_stewards,   name: "Earth Stewards",
    description: "Tending the land, seasonal living, and reconnecting with the cycles of nature.",
    creator: :meadow,  members: [ :clover, :rowan, :dahlia ] },
  { label: :movement_yoga,    name: "Movement & Yoga",
    description: "Daily practice, asana, and embodied movement for all levels.",
    creator: :soleil,  members: [ :thea, :aria, :maya ] },
  { label: :grief_tending,    name: "Grief Tending Circle",
    description: "A gentle, held space for moving through loss and honoring our grief together.",
    creator: :wren,    members: [ :celeste, :hazel ] },
  { label: :sacred_writing,   name: "Sacred Writing & Poetry",
    description: "Writing prompts, shared poems, and finding our voice on the page.",
    creator: :sage,    members: [ :fern, :celeste ] },
  { label: :crystal_energy,   name: "Crystal & Energy Work",
    description: "Working with crystals, reiki, and subtle energy for healing and balance.",
    creator: :seren,   members: [ :celeste, :opal ] },
  { label: :dance_ecstatic,   name: "Ecstatic Dance",
    description: "Free-form movement and ecstatic dance to release, express, and celebrate.",
    creator: :noor,    members: [ :willow, :lina, :anja ] }
]

joinable_groups.each do |data|
  group = groups.create data[:label],
    name: data[:name],
    description: data[:description],
    creator: users.send(data[:creator])

  data[:members].each do |member|
    group_memberships.create group: group, user: users.send(member)
  end
end

puts "Seeded #{Group.count} groups with memberships"

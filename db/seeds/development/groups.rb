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

puts "Seeded #{Group.count} groups with memberships"

cohorts.create :bozeman_spring,
  name: "Bozeman Spring Retreat 2025",
  description: "A weekend of reconnection, ceremony, and sisterhood in the Gallatin Valley.",
  retreat_location: "Bozeman, Montana",
  retreat_start_date: Date.new(2025, 4, 18),
  retreat_end_date: Date.new(2025, 4, 21),
  creator: users.admin

[users.luna, users.sage, users.freya, users.rowan, users.wren, users.aurora].each do |user|
  cohort_memberships.create cohort: cohorts.bozeman_spring, user: user
end

cohorts.create :solstice,
  name: "Solstice Gathering",
  description: "Celebrating the summer solstice with fire ceremony, song, and movement.",
  retreat_location: "Livingston, Montana",
  retreat_start_date: Date.new(2025, 6, 21),
  retreat_end_date: Date.new(2025, 6, 24),
  creator: users.admin

[users.aria, users.willow, users.juniper, users.dahlia, users.ember, users.fern, users.meadow].each do |user|
  cohort_memberships.create cohort: cohorts.solstice, user: user
end

cohorts.create :mountain_circle,
  name: "Mountain Women's Circle",
  description: "Monthly circle for women rooted in the Northern Rockies.",
  retreat_location: "Whitefish, Montana",
  retreat_start_date: Date.new(2025, 9, 5),
  retreat_end_date: Date.new(2025, 9, 8),
  creator: users.admin

[users.sage, users.maya, users.iris, users.celeste, users.hazel, users.clover, users.ivy].each do |user|
  cohort_memberships.create cohort: cohorts.mountain_circle, user: user
end

cohorts.create :desert_rose,
  name: "Desert Rose Retreat",
  description: "A deep dive into plant medicine, ceremony, and desert stillness.",
  retreat_location: "Sedona, Arizona",
  retreat_start_date: Date.new(2025, 10, 10),
  retreat_end_date: Date.new(2025, 10, 13),
  creator: users.admin

[users.willow, users.dahlia, users.ember, users.fern, users.soleil].each do |user|
  cohort_memberships.create cohort: cohorts.desert_rose, user: user
end

cohorts.create :winter_womb,
  name: "Winter Womb Retreat 2026",
  description: "Honoring the dark season with rest, reflection, and nourishment.",
  retreat_location: "Big Sky, Montana",
  retreat_start_date: Date.new(2026, 1, 24),
  retreat_end_date: Date.new(2026, 1, 27),
  creator: users.admin

[users.luna, users.aria, users.freya, users.celeste, users.rowan, users.wren, users.ivy, users.aurora, users.meadow, users.elara, users.noor].each do |user|
  cohort_memberships.create cohort: cohorts.winter_womb, user: user
end

cohorts.create :european_sisters,
  name: "European Sisters Circle",
  description: "Connecting women across Europe through seasonal ceremony and shared practice.",
  retreat_location: "Florence, Italy",
  retreat_start_date: Date.new(2026, 5, 15),
  retreat_end_date: Date.new(2026, 5, 18),
  creator: users.admin

[users.elara, users.maeve, users.noor, users.lina, users.cosima].each do |user|
  cohort_memberships.create cohort: cohorts.european_sisters, user: user
end

puts "Seeded #{Cohort.count} cohorts with memberships"

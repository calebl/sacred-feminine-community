cohorts.create :kabul_retreat,
  name: "Kabul Retreat 2025",
  description: "Sacred Feminine retreat in Kabul, Morocco",
  retreat_location: "Kabul, Morocco",
  retreat_start_date: Date.new(2025, 9, 15),
  retreat_end_date: Date.new(2025, 9, 18),
  creator: users.admin

cohorts.create :bali_retreat,
  name: "Bali Retreat 2024",
  description: "Sacred Feminine retreat in Bali",
  retreat_location: "Ubud, Bali",
  retreat_start_date: Date.new(2024, 3, 1),
  retreat_end_date: Date.new(2024, 3, 4),
  creator: users.admin

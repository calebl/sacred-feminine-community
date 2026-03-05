if Rails.env.development?
  # Coordinates are provided inline, so skip geocoding API calls.
  User.skip_callback(:commit, :after, :enqueue_geocode)

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
    { name: "Luna Morales", email: "luna@example.com", city: "Bozeman", state: "Montana", country: "United States", bio: "Yoga teacher and herbalist.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Sage Whitfield", email: "sage@example.com", city: "Missoula", state: "Montana", country: "United States", bio: "Writer and wilderness guide.", latitude: 46.8721, longitude: -113.9940, show_on_map: true },
    { name: "Aria Chen", email: "aria@example.com", city: "Portland", state: "Oregon", country: "United States", bio: "Acupuncturist and meditation teacher.", latitude: 45.5152, longitude: -122.6784, show_on_map: true },
    { name: "Willow Hart", email: "willow@example.com", city: "Ashland", state: "Oregon", country: "United States", bio: "Dance therapist and ceremonialist.", latitude: 42.1946, longitude: -122.7095, show_on_map: true },
    { name: "Maya Johansson", email: "maya@example.com", city: "Seattle", state: "Washington", country: "United States", bio: "Breathwork facilitator.", latitude: 47.6062, longitude: -122.3321, show_on_map: true },
    { name: "Freya Dubois", email: "freya@example.com", city: "Bozeman", state: "Montana", country: "United States", bio: "Midwife and plant medicine advocate.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Iris Nakamura", email: "iris@example.com", city: "Whitefish", state: "Montana", country: "United States", bio: "Sound healer and singer.", latitude: 48.4106, longitude: -114.3529, show_on_map: true },
    { name: "Juniper Ross", email: "juniper@example.com", city: "Livingston", state: "Montana", country: "United States", bio: "Astrologer and tarot reader.", latitude: 45.6627, longitude: -110.5612, show_on_map: true },
    { name: "Dahlia Fernandez", email: "dahlia@example.com", city: "Santa Fe", state: "New Mexico", country: "United States", bio: "Ceramicist and earth keeper.", latitude: 35.6870, longitude: -105.9378, show_on_map: true },
    { name: "Celeste Okafor", email: "celeste@example.com", city: "Denver", state: "Colorado", country: "United States", bio: "Reiki practitioner and poet.", latitude: 39.7392, longitude: -104.9903, show_on_map: true },
    { name: "Rowan Mitchell", email: "rowan@example.com", city: "Bozeman", state: "Montana", country: "United States", bio: "Herbalist and forager.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Hazel Bergström", email: "hazel@example.com", city: "Helena", state: "Montana", country: "United States", bio: "Doula and womb keeper.", latitude: 46.5958, longitude: -112.0270, show_on_map: true },
    { name: "Ember Solano", email: "ember@example.com", city: "Sedona", state: "Arizona", country: "United States", bio: "Fire ceremony guide.", latitude: 34.8697, longitude: -111.7610, show_on_map: true },
    { name: "Clover Bennett", email: "clover@example.com", city: "Boise", state: "Idaho", country: "United States", bio: "Herbalist and homesteader.", latitude: 43.6150, longitude: -116.2023, show_on_map: true },
    { name: "Wren Abadi", email: "wren@example.com", city: "Bozeman", state: "Montana", country: "United States", bio: "Bodyworker and trauma-informed coach.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Fern Delacroix", email: "fern@example.com", city: "Taos", state: "New Mexico", country: "United States", bio: "Painter and vision quest guide.", latitude: 36.4072, longitude: -105.5731, show_on_map: true },
    { name: "Soleil Prasad", email: "soleil@example.com", city: "Portland", state: "Oregon", country: "United States", bio: "Kundalini yoga teacher.", latitude: 45.5152, longitude: -122.6784, show_on_map: true },
    { name: "Ivy Thornton", email: "ivy@example.com", city: "Big Sky", state: "Montana", country: "United States", bio: "Mountain guide and storyteller.", latitude: 45.2833, longitude: -111.4014, show_on_map: false },
    { name: "Aurora Reyes", email: "aurora@example.com", city: "Bozeman", state: "Montana", country: "United States", bio: "Community organizer and healer.", latitude: 45.6770, longitude: -111.0429, show_on_map: true },
    { name: "Meadow Kim", email: "meadow@example.com", city: "Jackson", state: "Wyoming", country: "United States", bio: "Nutritionist and fermenter.", latitude: 43.4799, longitude: -110.7624, show_on_map: true },
    { name: "Elara Lindqvist", email: "elara@example.com", city: "Stockholm", country: "Sweden", bio: "Foraging guide and Nordic folk healer.", latitude: 59.3293, longitude: 18.0686, show_on_map: true },
    { name: "Maeve Byrne", email: "maeve@example.com", city: "Galway", country: "Ireland", bio: "Herbalist and Celtic ceremonialist.", latitude: 53.2707, longitude: -9.0568, show_on_map: true },
    { name: "Noor Haddad", email: "noor@example.com", city: "Barcelona", country: "Spain", bio: "Flamenco dancer and somatic therapist.", latitude: 41.3874, longitude: 2.1686, show_on_map: true },
    { name: "Lina Vogel", email: "lina@example.com", city: "Berlin", country: "Germany", bio: "Breathwork facilitator and artist.", latitude: 52.5200, longitude: 13.4050, show_on_map: true },
    { name: "Cosima Rossi", email: "cosima@example.com", city: "Florence", country: "Italy", bio: "Herbalist and temple arts teacher.", latitude: 43.7696, longitude: 11.2558, show_on_map: true },
    { name: "Paloma Vega", email: "paloma@example.com", city: "Portland", state: "Oregon", country: "United States", bio: "Herbalist and birth worker.", latitude: 45.5152, longitude: -122.6784, show_on_map: true },
    { name: "Seren Watts", email: "seren@example.com", city: "Denver", state: "Colorado", country: "United States", bio: "Crystal healer and astrologer.", latitude: 39.7392, longitude: -104.9903, show_on_map: true },
    { name: "Thea Moreau", email: "thea@example.com", city: "Denver", state: "Colorado", country: "United States", bio: "Yoga therapist and retreat leader.", latitude: 39.7392, longitude: -104.9903, show_on_map: true },
    { name: "Opal Sinclair", email: "opal@example.com", city: "Seattle", state: "Washington", country: "United States", bio: "Aromatherapist and moon circle host.", latitude: 47.6062, longitude: -122.3321, show_on_map: true },
    { name: "Briar Kowalski", email: "briar@example.com", city: "Seattle", state: "Washington", country: "United States", bio: "Herbalist and women's health advocate.", latitude: 47.6062, longitude: -122.3321, show_on_map: true },
    { name: "Saskia de Vries", email: "saskia@example.com", city: "Berlin", country: "Germany", bio: "Sound bath facilitator and bodyworker.", latitude: 52.5200, longitude: 13.4050, show_on_map: true },
    { name: "Anja Müller", email: "anja@example.com", city: "Berlin", country: "Germany", bio: "Dance therapist and women's circle keeper.", latitude: 52.5200, longitude: 13.4050, show_on_map: true }
  ]

  dm_privacy_options = User.dm_privacies.keys

  attendees = attendees_data.each_with_index.map do |data, i|
    User.find_or_create_by!(email: data[:email]) do |u|
      u.name = data[:name]
      u.password = password
      u.password_confirmation = password
      u.role = :attendee
      u.city = data[:city]
      u.state = data[:state]
      u.country = data[:country]
      u.bio = data[:bio]
      u.latitude = data[:latitude]
      u.longitude = data[:longitude]
      u.show_on_map = data[:show_on_map]
      u.dm_privacy = dm_privacy_options[i % dm_privacy_options.size]
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
      retreat_start_date: Date.new(2025, 4, 18),
      retreat_end_date: Date.new(2025, 4, 21),
      member_indices: [ 0, 1, 5, 10, 14, 18 ]
    },
    {
      name: "Solstice Gathering",
      description: "Celebrating the summer solstice with fire ceremony, song, and movement.",
      retreat_location: "Livingston, Montana",
      retreat_start_date: Date.new(2025, 6, 21),
      retreat_end_date: Date.new(2025, 6, 24),
      member_indices: [ 2, 3, 7, 8, 12, 15, 19 ]
    },
    {
      name: "Mountain Women's Circle",
      description: "Monthly circle for women rooted in the Northern Rockies.",
      retreat_location: "Whitefish, Montana",
      retreat_start_date: Date.new(2025, 9, 5),
      retreat_end_date: Date.new(2025, 9, 8),
      member_indices: [ 1, 4, 6, 9, 11, 13, 17 ]
    },
    {
      name: "Desert Rose Retreat",
      description: "A deep dive into plant medicine, ceremony, and desert stillness.",
      retreat_location: "Sedona, Arizona",
      retreat_start_date: Date.new(2025, 10, 10),
      retreat_end_date: Date.new(2025, 10, 13),
      member_indices: [ 3, 8, 12, 15, 16 ]
    },
    {
      name: "Winter Womb Retreat 2026",
      description: "Honoring the dark season with rest, reflection, and nourishment.",
      retreat_location: "Big Sky, Montana",
      retreat_start_date: Date.new(2026, 1, 24),
      retreat_end_date: Date.new(2026, 1, 27),
      member_indices: [ 0, 2, 5, 9, 10, 14, 17, 18, 19, 20, 22 ]
    },
    {
      name: "European Sisters Circle",
      description: "Connecting women across Europe through seasonal ceremony and shared practice.",
      retreat_location: "Florence, Italy",
      retreat_start_date: Date.new(2026, 5, 15),
      retreat_end_date: Date.new(2026, 5, 18),
      member_indices: [ 20, 21, 22, 23, 24 ]
    }
  ]

  cohorts_data.each do |data|
    cohort = Cohort.find_or_create_by!(name: data[:name]) do |c|
      c.description = data[:description]
      c.retreat_location = data[:retreat_location]
      c.retreat_start_date = data[:retreat_start_date]
      c.retreat_end_date = data[:retreat_end_date]
      c.creator = admin
    end

    data[:member_indices].each do |i|
      CohortMembership.find_or_create_by!(cohort: cohort, user: attendees[i])
    end

    puts "Seeded cohort: #{cohort.name} (#{data[:member_indices].size} members)"
  end

  # --- Group Chat Messages ---
  cohorts = Cohort.all.index_by(&:name)
  base_time = 2.days.ago

  group_chats = {
    "Bozeman Spring Retreat 2025" => [
      { user: attendees[0],  body: "Hey everyone! So excited for the retreat. Is anyone arriving Thursday evening?" },
      { user: attendees[5],  body: "I'll be there Thursday! Planning to set up the altar space early Friday morning." },
      { user: attendees[1],  body: "I won't get in until Friday around noon. Save me a spot in the opening circle?" },
      { user: attendees[0],  body: "Of course, Sage. We'll hold space for you." },
      { user: attendees[10], body: "I'm bringing dried lavender and rosemary from my garden if anyone wants some for their rooms." },
      { user: attendees[14], body: "Yes please! That sounds heavenly." },
      { user: attendees[18], body: "I can bring extra blankets and cushions for the ceremony space." },
      { user: attendees[5],  body: "Perfect. I think we're going to have a really beautiful weekend together." },
      { user: attendees[0],  body: "Does anyone have dietary restrictions I should know about? I'm coordinating meals." },
      { user: attendees[1],  body: "I'm gluten-free. Thank you for checking, Luna!" }
    ],
    "Solstice Gathering" => [
      { user: attendees[7],  body: "The stars are aligning beautifully for the solstice this year. Jupiter in Cancer!" },
      { user: attendees[2],  body: "That's wonderful to hear. I've been feeling such strong energy shifts lately." },
      { user: attendees[3],  body: "Should we plan a sunrise dance? I could lead a movement session at dawn." },
      { user: attendees[8],  body: "I love that idea, Willow. I'll bring my hand drum." },
      { user: attendees[12], body: "Count me in for the sunrise. I'll prepare a fire blessing beforehand." },
      { user: attendees[15], body: "I've been painting a large canvas inspired by the solstice light. Would love to display it." },
      { user: attendees[19], body: "This is going to be magical. What time should we gather?" },
      { user: attendees[3],  body: "How about 5:15am? Sunrise is at 5:42 that day." },
      { user: attendees[2],  body: "I'll bring tea and honey for everyone before we start." }
    ],
    "Winter Womb Retreat 2026" => [
      { user: attendees[0],  body: "The cabin is confirmed! It has a huge fireplace and space for all of us." },
      { user: attendees[2],  body: "That sounds so cozy. I've been craving deep rest." },
      { user: attendees[9],  body: "I'm writing a poem for our opening ceremony. Would anyone like to share readings too?" },
      { user: attendees[5],  body: "I have a beautiful passage about winter as a season of gestation." },
      { user: attendees[17], body: "I can share a story about the mountain in winter. The land has so much to teach us." },
      { user: attendees[14], body: "Has anyone done a cacao ceremony before? I'd love to facilitate one." },
      { user: attendees[10], body: "I did one last year and it was transformative. Yes please!" },
      { user: attendees[18], body: "I've never tried cacao ceremony but I'm very open to it." },
      { user: attendees[0],  body: "Let's plan it for Saturday evening by the fire. Wren, can you do bodywork sessions too?" },
      { user: attendees[14], body: "Absolutely. I'll set up a little station in the side room." },
      { user: attendees[22], body: "Sending love from Barcelona! Can't wait to meet everyone in person." },
      { user: attendees[20], body: "Same here from Stockholm! This will be my first retreat with this group." },
      { user: attendees[19], body: "You're both going to love it. This community is so special." }
    ],
    "European Sisters Circle" => [
      { user: attendees[24], body: "Welcome sisters! I'm so happy we're creating this European circle." },
      { user: attendees[20], body: "Thank you for organizing this, Cosima. Florence is the perfect location." },
      { user: attendees[21], body: "I'll be coming from Galway. Anyone want to travel together from a hub city?" },
      { user: attendees[23], body: "I could meet in Munich and we could take the train down through the Alps." },
      { user: attendees[22], body: "Oh that sounds lovely! I'll take the train from Barcelona too." },
      { user: attendees[24], body: "I'll arrange a welcome dinner the evening before we officially begin." },
      { user: attendees[20], body: "Is there anything specific I should bring? I have dried Nordic herbs." },
      { user: attendees[24], body: "Bring whatever medicine feels right. We're weaving our traditions together." }
    ]
  }

  group_chats.each do |cohort_name, messages|
    cohort = cohorts[cohort_name]
    next unless cohort

    messages.each_with_index do |msg, i|
      ChatMessage.find_or_create_by!(
        cohort: cohort,
        user: msg[:user],
        body: msg[:body]
      ) do |m|
        m.created_at = base_time + (i * 8).minutes
        m.updated_at = base_time + (i * 8).minutes
      end
    end

    puts "Seeded #{messages.size} chat messages in: #{cohort_name}"
  end

  # --- Direct Message Conversations ---
  # --- Posts & Comments ---
  posts_data = {
    "Bozeman Spring Retreat 2025" => [
      {
        author: attendees[0],
        pinned: true,
        body: "Hey beautiful souls! Here's a suggested packing list for the spring retreat:\n\n- Comfortable layers (mornings are still cool in April)\n- Journal and pen\n- A sacred object for the altar\n- Reusable water bottle\n- Yoga mat or blanket for floor work\n\nPlease also bring any medicines, herbs, or offerings you'd like to share with the group. We'll have a community table set up.\n\nRemember: this is a tech-free retreat. Please plan to leave devices in your room.",
        comments: [
          { user: attendees[5], body: "Great list! I'll also bring extra sage bundles for anyone who wants one." },
          { user: attendees[10], body: "Should we bring our own towels or are they provided?" },
          { user: attendees[0], body: "Towels are provided! But bring a warm blanket if you like to cocoon during rest time." },
          { user: attendees[14], body: "Can I bring my guitar? Would love to play some songs by the fire." },
          { user: attendees[1], body: "Yes please! Music around the fire is the best part." }
        ]
      },
      {
        author: attendees[1],
        pinned: false,
        body: "I just wanted to take a moment to say how grateful I am for each of you. This circle has changed my life in ways I couldn't have imagined when I first joined.\n\nThe wilderness has always been my teacher, but learning alongside all of you has deepened that relationship in beautiful ways. Looking forward to our time together in April.\n\nWith love,\nSage",
        comments: [
          { user: attendees[0], body: "This made me tear up. We're so lucky to have you in this circle, Sage." },
          { user: attendees[18], body: "The feeling is so mutual. This group is home." },
          { user: attendees[5], body: "Love you all so much. Can't wait to be together again." }
        ]
      },
      {
        author: attendees[10],
        pinned: false,
        body: "Spring is the perfect time for liver-supporting herbs. I've been making a daily infusion of:\n\n1. Dandelion root\n2. Burdock root\n3. Nettle leaf\n4. A squeeze of lemon\n\nLet it steep overnight in a mason jar and drink it throughout the morning. Your body will thank you after winter.\n\nI'll bring some dried blends to share at the retreat!",
        comments: [
          { user: attendees[5], body: "This is exactly what I needed. My body has been craving greens and bitters." },
          { user: attendees[14], body: "Would this work well combined with a morning breathwork practice?" },
          { user: attendees[10], body: "Absolutely! Drink the infusion about 30 minutes before breathwork for best results." }
        ]
      },
      {
        author: attendees[5],
        pinned: false,
        body: "I wanted to share something that's been on my heart. Last month I attended a home birth where the mother used only herbal support and breathwork through labor. It was one of the most powerful things I've witnessed.\n\nIt reminded me why this community matters so much. We're keeping these practices alive for the next generation.\n\nI'd love to lead a conversation about traditional birth practices at the retreat if anyone is interested.",
        comments: [
          { user: attendees[0], body: "Yes, absolutely. This is so important. I'd love to hear more." },
          { user: attendees[1], body: "As a doula-in-training, I would be so grateful for this conversation." },
          { user: attendees[18], body: "Count me in. My grandmother was a traditional midwife in Mexico and I carry her stories." }
        ]
      },
      {
        author: attendees[14],
        pinned: false,
        body: "Quick question for the group: would anyone be interested in a song circle on Saturday evening? I've been learning some beautiful chants from different traditions and I think it could be a really grounding way to close the day.\n\nNo experience needed. Just your voice and willingness to be present.",
        comments: [
          { user: attendees[5], body: "I love this idea, Wren! Singing together always shifts something deep." },
          { user: attendees[10], body: "Absolutely. I know a few Appalachian folk songs that would fit perfectly." }
        ]
      },
      {
        author: attendees[18],
        pinned: false,
        body: "Sharing a morning practice that's been really supportive for me this season:\n\nBefore getting out of bed, I place both hands on my belly and take three slow breaths. Then I whisper one word that I want to carry through the day. Today's word was \"trust.\"\n\nIt takes less than a minute but it has completely changed how I move through my mornings.",
        comments: [
          { user: attendees[0], body: "This is beautiful, Aurora. I'm going to try it tomorrow morning." },
          { user: attendees[1], body: "I've been doing something similar. My word today was 'spaciousness.'" },
          { user: attendees[14], body: "I started doing this after you mentioned it last week and it's already shifting things for me." }
        ]
      }
    ],
    "Solstice Gathering" => [
      {
        author: attendees[3],
        pinned: true,
        body: "Here's what I'm envisioning for our solstice ceremony:\n\nDawn (5:15 AM) - Gather in silence. Sunrise movement meditation led by me, with Dahlia on drums.\n\nMorning (8 AM) - Breakfast together, then a sharing circle.\n\nAfternoon - Free time for rest, art, or nature walks.\n\nEvening - Fire ceremony led by Ember, followed by singing and stargazing.\n\nPlease feel free to suggest additions or changes!",
        comments: [
          { user: attendees[12], body: "This is beautiful, Willow. I'll prepare the fire space the evening before." },
          { user: attendees[7], body: "Could I do a brief star reading during the stargazing portion?" },
          { user: attendees[3], body: "That would be perfect, Juniper! Let's plan on that." },
          { user: attendees[2], body: "I can offer acupressure sessions during the free afternoon time." }
        ]
      },
      {
        author: attendees[15],
        pinned: false,
        body: "I've been working on a collaborative art piece for our gathering. The idea is a large sun mandala that we each contribute to during the retreat.\n\nI'll bring:\n- A 4-foot canvas with the base design\n- Acrylic paints in warm tones\n- Brushes for everyone\n\nEach person paints a ray of the sun with whatever colors and symbols feel right. By the end of the retreat, we'll have created something together.",
        comments: [
          { user: attendees[19], body: "I love this idea! Can we add dried flowers to the canvas too?" },
          { user: attendees[15], body: "Yes! Pressed flowers would be gorgeous. Bring whatever natural materials inspire you." },
          { user: attendees[8], body: "This is going to be so beautiful. I'll bring some gold leaf." }
        ]
      },
      {
        author: attendees[7],
        pinned: false,
        body: "I've been tracking the planetary alignments for the week of our gathering and the energy is remarkable. Mars and Venus are in a beautiful trine, which supports both action and receptivity.\n\nI'd recommend everyone spend some time under the night sky in the days leading up to the solstice. The stars are inviting us to release old patterns and step into new ones.\n\nI'll have personal mini-readings available for anyone who wants one during the retreat.",
        comments: [
          { user: attendees[3], body: "I've been feeling this shift so strongly. Thank you for naming it, Juniper." },
          { user: attendees[19], body: "I'd love a reading! The stars have been speaking to me loudly this month." },
          { user: attendees[12], body: "This is going to add such a beautiful layer to our fire ceremony." }
        ]
      },
      {
        author: attendees[8],
        pinned: false,
        body: "I've been making ceremonial drums from ethically sourced deer hide and I just finished one specifically for our gathering. The sound is deep and resonant, perfect for outdoor ceremony.\n\nWould anyone else like to bring instruments? I think a spontaneous sound journey by the fire could be really powerful.",
        comments: [
          { user: attendees[2], body: "I have a set of Tibetan singing bowls I could bring." },
          { user: attendees[3], body: "I'll bring my rain stick and some rattles." },
          { user: attendees[15], body: "I don't play anything but I'd love to add my voice. Overtone singing has been calling me." }
        ]
      },
      {
        author: attendees[12],
        pinned: false,
        body: "For the fire ceremony, I'll need some help gathering wood the afternoon before. The best firewood is already seasoned and dry. I know a spot on the property where there's a good supply of juniper and pinon.\n\nAlso, if anyone has sacred items they'd like to burn as an offering or release, please bring them. The solstice fire is a powerful time for letting go.",
        comments: [
          { user: attendees[8], body: "I'll help with wood gathering. I love that kind of physical, grounding work before ceremony." },
          { user: attendees[7], body: "I have some old journals I've been wanting to release. This feels like the right fire." },
          { user: attendees[19], body: "I wrote letters to my younger self that I'd like to burn. Thank you for holding this space, Ember." }
        ]
      },
      {
        author: attendees[2],
        pinned: false,
        body: "Offering free acupressure sessions during the afternoon free time. I'll set up in the shade with mats and blankets. Each session is about 20 minutes.\n\nAcupressure works with the same meridian system as acupuncture but uses finger pressure instead of needles. It's wonderful for releasing tension, improving circulation, and supporting emotional balance.\n\nNo sign-up needed, just come find me!",
        comments: [
          { user: attendees[3], body: "Aria, your hands are magic. Everyone should take advantage of this!" },
          { user: attendees[15], body: "I'll definitely be stopping by. My shoulders have been holding so much tension." }
        ]
      },
      {
        author: attendees[19],
        pinned: false,
        body: "I've been foraging for wildflowers to make flower crowns for everyone at the gathering. So far I have dried lavender, yarrow, and wild rose.\n\nIf anyone sees any beautiful blooms on their walks, please pick a few and bring them! I'll have wire and ribbon so we can make them together.",
        comments: [
          { user: attendees[3], body: "This makes my heart so happy. I'll look for some on my hikes this week." },
          { user: attendees[8], body: "I have a huge patch of chamomile in my garden that would be perfect for this." }
        ]
      }
    ],
    "Mountain Women's Circle" => [
      {
        author: attendees[6],
        pinned: true,
        body: "Welcome to the Mountain Women's Circle! Our September gathering in Whitefish is going to be so special.\n\nThe lodge sits right on the edge of the forest with views of Glacier National Park. We'll have access to hiking trails, a creek for water ceremony, and a beautiful meadow for our circle work.\n\nPlease arrive by Friday evening so we can have a slow dinner together before the weekend begins.",
        comments: [
          { user: attendees[1], body: "This sounds incredible, Iris. I've been longing for mountain time." },
          { user: attendees[9], body: "I'm so excited to be near Glacier. The energy there is unlike anywhere else." },
          { user: attendees[4], body: "Can't wait! I'll bring my breathwork playlist for the morning sessions." }
        ]
      },
      {
        author: attendees[1],
        pinned: false,
        body: "I want to lead a wilderness awareness walk on Saturday morning. We'll practice what my teacher calls 'fox walking,' moving slowly through the forest and tuning into all our senses.\n\nThe goal isn't to cover distance but to truly arrive in the landscape. We'll stop to observe, listen, touch, and smell. I've found that this practice is one of the fastest ways to drop into presence.\n\nWear shoes you can walk quietly in. We'll be out for about two hours.",
        comments: [
          { user: attendees[11], body: "I love this practice. It completely changes how I experience the forest." },
          { user: attendees[6], body: "This is perfect for our first morning. Thank you, Sage." },
          { user: attendees[17], body: "I learned something similar from an elder years ago. Beautiful to see it here." }
        ]
      },
      {
        author: attendees[4],
        pinned: false,
        body: "Offering a breathwork session on Saturday afternoon. We'll do a connected breathing pattern for about 45 minutes followed by integration time.\n\nThis particular practice can bring up strong emotions, memories, and physical sensations. It's all welcome and all part of the process. I'll be there to guide and support.\n\nPlease eat lightly beforehand and bring a blanket and eye mask if you have one.",
        comments: [
          { user: attendees[13], body: "I've been wanting to try this for months. Thank you for offering it, Maya." },
          { user: attendees[9], body: "Maya's breathwork sessions are incredible. Be ready to go deep." },
          { user: attendees[1], body: "I'll bring extra blankets for anyone who needs them." }
        ]
      },
      {
        author: attendees[11],
        pinned: false,
        body: "Something I've been sitting with: the womb as a center of creativity, not just reproduction. In my doula practice I work with women across the full spectrum of life stages, and I've learned that womb wisdom doesn't require a physical womb.\n\nI'd love to facilitate a gentle exploration of this at the gathering. We'd use visualization, gentle movement, and sharing.\n\nAnyone interested?",
        comments: [
          { user: attendees[4], body: "So much yes to this, Hazel. This is the kind of conversation we need more of." },
          { user: attendees[6], body: "Beautifully said. I'm in." },
          { user: attendees[13], body: "Thank you for holding space for this. It's something I've been wanting to explore." }
        ]
      },
      {
        author: attendees[9],
        pinned: false,
        body: "I wrote this haiku on my morning walk today and wanted to share it with you all:\n\nCold creek, mossy stone,\nthe mountain holds what we lose,\nroots remember us.\n\nSee you all in Whitefish soon.",
        comments: [
          { user: attendees[1], body: "Oh Celeste, this is so beautiful. You always find the exact right words." },
          { user: attendees[17], body: "I can feel the mountain in these words. Thank you for sharing." }
        ]
      },
      {
        author: attendees[13],
        pinned: false,
        body: "I'll be bringing a big batch of my homestead elderberry syrup for everyone. It's made with elderberries from my garden, raw honey from my bees, ginger, and cinnamon.\n\nPerfect for immune support as we head into fall. Take a tablespoon each morning during the retreat and I'll send you home with a small jar.\n\nAlso bringing my sourdough starter for fresh bread at the gathering!",
        comments: [
          { user: attendees[11], body: "Clover, your elderberry syrup is the best I've ever had. So generous of you." },
          { user: attendees[4], body: "Fresh sourdough and elderberry syrup? We're going to be so nourished." },
          { user: attendees[6], body: "This is exactly why I love this circle. Everyone brings their gifts." }
        ]
      },
      {
        author: attendees[17],
        pinned: false,
        body: "For anyone arriving early on Friday, I'd love to take a small group up to a viewpoint I know about 30 minutes from the lodge. It's an easy trail and the views of the valley are stunning at sunset.\n\nWe could do a simple opening prayer together up there before heading back down for dinner. Just a quiet way to mark the beginning of our time together.\n\nLet me know if you're interested and I'll plan for it.",
        comments: [
          { user: attendees[1], body: "I'll be there early. Count me in, Ivy." },
          { user: attendees[9], body: "A sunset prayer on the mountain sounds like the perfect way to begin." }
        ]
      }
    ],
    "Desert Rose Retreat" => [
      {
        author: attendees[12],
        pinned: true,
        body: "Welcome to the Desert Rose Retreat! Sedona is one of the most energetically powerful places on earth and I'm so honored to host us there.\n\nWe'll be staying at a retreat center near Bell Rock. The property has an outdoor ceremony space, a labyrinth, and views of the red rocks from every room.\n\nImportant: October in Sedona is warm during the day (70s-80s) but can drop to the 40s at night. Bring layers!\n\nI'll share a detailed schedule next week.",
        comments: [
          { user: attendees[3], body: "I've wanted to visit Sedona for years. This feels like divine timing." },
          { user: attendees[8], body: "The energy near Bell Rock is extraordinary. We're in for something special." },
          { user: attendees[15], body: "So excited! Will there be time for a vortex hike?" },
          { user: attendees[12], body: "Absolutely! I'm planning a sunrise vortex hike on Saturday morning." }
        ]
      },
      {
        author: attendees[3],
        pinned: false,
        body: "I'd like to lead an earth-based movement practice on the red rocks if the group is open to it. It's a blend of dance therapy and somatic awareness, designed to help us connect with the energy of the land.\n\nWe'll work barefoot on the earth (weather permitting), using slow, intuitive movement to listen to what the body and the land are communicating. No dance experience needed.\n\nI find that the desert strips away everything unnecessary and leaves us with only what's true.",
        comments: [
          { user: attendees[12], body: "Willow, your movement work is always so profound. I can't think of a better setting for it." },
          { user: attendees[16], body: "I'm new to somatic work but really curious. This sounds like a gentle entry point." },
          { user: attendees[8], body: "Dancing on red rock earth. I can already feel it calling." }
        ]
      },
      {
        author: attendees[8],
        pinned: false,
        body: "I'll be bringing my ceramics supplies to the retreat and would love to lead a hand-building session. We'll work with locally sourced red clay, shaping vessels by hand without a wheel.\n\nThere's something deeply meditative about working with earth from the place you're sitting on. The pieces will need to air dry, so they won't be fired, but they make beautiful altar pieces.\n\nI'll bring enough clay for everyone.",
        comments: [
          { user: attendees[15], body: "Working with Sedona clay? That's such a special idea, Dahlia." },
          { user: attendees[3], body: "I love the idea of creating something from the earth of this sacred place." },
          { user: attendees[16], body: "I've never worked with clay before but I'm drawn to try. Thank you for offering this." }
        ]
      },
      {
        author: attendees[16],
        pinned: false,
        body: "Hello everyone! This is my first retreat with this group and I'm feeling a mix of excitement and nervousness. I've been practicing Kundalini yoga on my own for two years but haven't had a community to share it with.\n\nI'm so grateful to have been invited into this circle. I'm coming with an open heart and a willingness to be changed by whatever unfolds.\n\nIs there anything I should know or prepare for my first gathering?",
        comments: [
          { user: attendees[12], body: "Welcome, Soleil! Just bring yourself exactly as you are. That's always enough." },
          { user: attendees[3], body: "You're going to love it. The only preparation needed is openness, and it sounds like you already have that." },
          { user: attendees[8], body: "We're so happy you're joining us. First retreats are always transformative." },
          { user: attendees[15], body: "I remember my first retreat with this group. It changed everything. Welcome home." }
        ]
      },
      {
        author: attendees[15],
        pinned: false,
        body: "I'm planning to paint during the retreat and would love company. I'll set up an outdoor painting station where anyone can join me during free time. I'll have extra canvases, watercolors, and brushes.\n\nThe desert light in Sedona is unlike anything I've ever painted in. The reds and golds shift constantly throughout the day. Even if you don't consider yourself a painter, come sit with me and play with color.\n\nSometimes the most powerful art comes from people who aren't trying to make art.",
        comments: [
          { user: attendees[16], body: "I haven't painted since I was a child but something about this invitation feels important. I'll be there." },
          { user: attendees[12], body: "Fern's painting sessions are one of my favorite parts of retreat. So healing." }
        ]
      }
    ],
    "Winter Womb Retreat 2026" => [
      {
        author: admin,
        pinned: true,
        body: "Welcome to the Winter Womb Retreat! Here are the logistics:\n\nLocation: Mountain Spirit Lodge, Big Sky, MT\nCheck-in: Friday, January 24th, 3:00 PM\nCheck-out: Monday, January 27th, 11:00 AM\n\nThe cabin has 6 bedrooms (shared), a large gathering room with fireplace, a fully equipped kitchen, and a covered hot tub.\n\nDriving conditions: The road to the cabin is plowed but can be icy. 4WD or chains recommended. I'll send GPS coordinates closer to the date.\n\nReach out if you need help with transportation!",
        comments: [
          { user: attendees[0], body: "This looks amazing! I can offer rides from Bozeman for anyone who needs them." },
          { user: attendees[9], body: "Is there a place to do outdoor meditation? Even in the cold, I love sitting outside." },
          { user: attendees[17], body: "There's a beautiful clearing behind the lodge. I've been there before, it's magical in snow." },
          { user: attendees[20], body: "I'll be flying into Bozeman. Luna, I would love a ride if that's ok!" },
          { user: attendees[0], body: "Of course, Elara! I'll pick you up at the airport. Just send me your flight details." }
        ]
      },
      {
        author: attendees[14],
        pinned: false,
        body: "For those who haven't experienced a cacao ceremony before, here's a little about what to expect:\n\nCeremonial cacao is different from regular chocolate. It's minimally processed and contains theobromine, which gently opens the heart and enhances introspection.\n\nTo prepare:\n- Eat lightly the day of the ceremony\n- Hydrate well\n- Set an intention for what you'd like to release or invite in\n\nI'll be using organic Guatemalan ceremonial-grade cacao. The ceremony will last about 90 minutes.",
        comments: [
          { user: attendees[18], body: "Thank you for explaining this, Wren. I've been curious and a little nervous. This helps!" },
          { user: attendees[14], body: "No need to be nervous at all. It's very gentle. You'll feel supported the whole time." },
          { user: attendees[10], body: "Wren's cacao ceremonies are incredible. You're all in for a treat." },
          { user: attendees[22], body: "I've done cacao ceremonies in Spain and they're transformative. So excited for this!" }
        ]
      },
      {
        author: attendees[9],
        pinned: false,
        body: "I've been working on a piece for our opening ceremony. Here's a preview:\n\n\"In the hush of winter's hold,\nwe gather close, we gather bold.\nRoot to root beneath the snow,\nthe seeds of spring already know.\"\n\nWould anyone else like to share a reading or poem? I think it would be powerful to have multiple voices in our opening.",
        comments: [
          { user: attendees[5], body: "This is gorgeous, Celeste. I have a passage from a Mary Oliver poem I'd love to share." },
          { user: attendees[2], body: "I'd like to share a short meditation verse. Can I go after you?" },
          { user: attendees[9], body: "Yes to both! Let's create a beautiful flow of voices." }
        ]
      },
      {
        author: attendees[2],
        pinned: false,
        body: "I've been preparing a yin yoga sequence specifically designed for winter. It focuses on the kidney and bladder meridians, which correspond to the water element and are most active in the cold months.\n\nWe'll hold poses for 3-5 minutes each, giving the connective tissue time to release. I'll guide a meditation alongside the physical practice.\n\nWould Sunday morning work for everyone? I find the body is most receptive to deep stretching early in the day.",
        comments: [
          { user: attendees[0], body: "Sunday morning is perfect. I love how yin yoga makes me feel so spacious inside." },
          { user: attendees[17], body: "I've been needing this kind of slow, deep practice. Thank you, Aria." },
          { user: attendees[22], body: "I do yin regularly at home but never with meridian guidance. Really looking forward to this." }
        ]
      },
      {
        author: attendees[17],
        pinned: false,
        body: "I scouted the property last weekend and wanted to share some photos (coming soon). The snow is absolutely beautiful right now. The clearing behind the lodge has about two feet of fresh powder and the trees are crystallized with ice.\n\nFor those who want to do outdoor meditation, I found a sheltered spot under a stand of old-growth pines where the wind doesn't reach. We could set up cushions there and it would be surprisingly comfortable even in the cold.\n\nAlso, the hot tub is working great. Perfect for stargazing after ceremony.",
        comments: [
          { user: attendees[0], body: "This sounds magical, Ivy. Outdoor meditation in the snow is one of my favorite practices." },
          { user: attendees[14], body: "Hot tub under the stars after cacao ceremony? Yes please." },
          { user: attendees[20], body: "Coming from Stockholm, I'm very used to the cold. Can't wait to sit in the snow with you all!" }
        ]
      },
      {
        author: attendees[18],
        pinned: false,
        body: "I've been organizing a community meal plan so we can nourish ourselves well without anyone spending the whole retreat in the kitchen.\n\nHere's what I'm thinking:\n- Friday dinner: I'll prepare a big pot of pozole (my grandmother's recipe)\n- Saturday breakfast/lunch: Potluck style, everyone contributes one dish\n- Saturday dinner: Wren and Luna are cooking together\n- Sunday brunch: Simple and easy, eggs and sourdough\n\nPlease let me know about any allergies or dietary needs!",
        comments: [
          { user: attendees[5], body: "Your grandmother's pozole is legendary, Aurora. I'll bring fresh tortillas." },
          { user: attendees[10], body: "I'll make a big batch of bone broth for anyone who wants it throughout the weekend." },
          { user: attendees[14], body: "Luna and I will handle Saturday dinner! Planning a warming curry." },
          { user: attendees[9], body: "This is so well organized. Thank you for taking this on, Aurora." }
        ]
      },
      {
        author: attendees[20],
        pinned: false,
        body: "Hello from Sweden! I'm Elara and this will be my first retreat with this group. Cosima from the European circle encouraged me to join and I'm so glad I did.\n\nA little about me: I'm a foraging guide and I study Nordic folk healing traditions. I'll be bringing some dried cloudberries and lingonberries from my summer harvest, along with a birch bark tea blend that's been a staple in Scandinavian women's medicine for centuries.\n\nSo excited to meet you all in person!",
        comments: [
          { user: attendees[0], body: "Welcome, Elara! We've heard so much about you from Cosima. So happy you're joining us." },
          { user: attendees[10], body: "Nordic herb traditions! I'd love to learn more about the birch bark tea. Welcome!" },
          { user: attendees[5], body: "Cloudberries! I've only read about them. Can't wait to try them. Welcome to the circle." }
        ]
      }
    ],
    "European Sisters Circle" => [
      {
        author: attendees[24],
        pinned: true,
        body: "I've secured a beautiful villa just outside the city center for our Florence gathering. It has:\n\n- A garden with olive trees perfect for outdoor ceremony\n- A large open room with natural light for our circle\n- A kitchen where we can cook together\n- Views of the Tuscan hills\n\nThe villa is a 20-minute bus ride from Santa Maria Novella train station. I'll share the exact address and directions soon.\n\nI'm planning to source food from the local market for our meals. If anyone has dietary needs, please let me know!",
        comments: [
          { user: attendees[20], body: "This sounds absolutely dreamy, Cosima! I can help with cooking." },
          { user: attendees[21], body: "I'm vegetarian but very flexible. I can bring Irish soda bread recipe to share!" },
          { user: attendees[23], body: "I'd love to help in the kitchen too. I make a great German apple cake." },
          { user: attendees[22], body: "And I'll bring Spanish olive oil and manchego. We're going to eat so well!" }
        ]
      },
      {
        author: attendees[20],
        pinned: false,
        body: "One thing I love about this circle is that we each carry different folk traditions. I'd love for us to each share a practice from our heritage:\n\nMy offering: I'll lead a Nordic herb walk and teach about Scandinavian plant folk wisdom. In Sweden, we believe the forest has its own intelligence, and I'd love to share how my grandmother taught me to listen to it.\n\nWhat traditions would each of you like to share?",
        comments: [
          { user: attendees[21], body: "I'd love to lead a Celtic blessing ceremony. The Brigid traditions are so relevant for women's circles." },
          { user: attendees[24], body: "I can share Italian herbal remedies passed down in my family. My nonna was a village healer." },
          { user: attendees[23], body: "I'll share a breathwork practice rooted in Germanic wellness traditions." },
          { user: attendees[22], body: "Flamenco has deep roots in feminine expression. I could teach a short movement piece." },
          { user: attendees[20], body: "This is going to be so beautiful. What a rich tapestry we're weaving together." }
        ]
      },
      {
        author: attendees[21],
        pinned: false,
        body: "I wanted to share a practice I do every Imbolc that I think we could adapt for our Florence gathering. In the Celtic tradition, Brigid is the goddess of the hearth, of poetry, and of healing.\n\nOn the eve of Imbolc, we make Brigid's crosses from rushes and hang them over doorways for protection. I'll bring materials so we can each make one.\n\nThe cross has four arms spiraling outward, representing the turning of the seasons. Even though we'll be gathering in May, Brigid's energy of creative fire feels so right for our circle.",
        comments: [
          { user: attendees[24], body: "I love how you carry these traditions, Maeve. In Italy we have similar protective symbols woven from wheat." },
          { user: attendees[22], body: "Brigid's fire and creative energy is exactly what I feel in this group." },
          { user: attendees[20], body: "This is going to be such a meaningful craft to take home." }
        ]
      },
      {
        author: attendees[22],
        pinned: false,
        body: "I've been thinking about our gathering and I want to offer a flamenco workshop. Not the performance kind, but the roots of it. The duende, the deep song.\n\nFlamenco originated with women in kitchens and courtyards, stomping their grief and joy into the earth. It was never meant for stages. It was a language of the body when words weren't enough.\n\nI'll teach basic footwork and hand movements. We'll work with rhythm and breath. No experience needed, just willingness to feel.\n\nBring shoes with a hard sole if you have them.",
        comments: [
          { user: attendees[23], body: "Noor, I've always been drawn to flamenco but intimidated. The way you describe it makes it feel so accessible." },
          { user: attendees[21], body: "Stomping grief into the earth. What a beautiful and necessary practice." },
          { user: attendees[24], body: "We can do this in the garden! The stone patio would be perfect for footwork." }
        ]
      },
      {
        author: attendees[23],
        pinned: false,
        body: "Question for the group: how are we handling travel to Florence? I was thinking of taking the train from Berlin and could coordinate with anyone coming from central or northern Europe.\n\nThe route through the Alps is stunning and I'd love travel companions. We could make the journey part of the experience, maybe share a cabin on the overnight train.\n\nAlso, I found a wonderful organic market near the villa that's open Saturday mornings. Could be a lovely outing for anyone who arrives early.",
        comments: [
          { user: attendees[20], body: "I could fly to Berlin and we take the train together! That sounds wonderful." },
          { user: attendees[24], body: "The Saturday market is one of my favorites. I'll take anyone who wants to go." },
          { user: attendees[22], body: "I'm taking the train from Barcelona through the south of France. It's a beautiful ride along the coast." }
        ]
      },
      {
        author: attendees[24],
        pinned: false,
        body: "I spent yesterday in my nonna's garden collecting herbs and thinking about all of you. She passed three years ago but her rosemary, sage, and thyme bushes are still thriving.\n\nShe used to say that every herb has a spirit and if you listen, they'll tell you how they want to be used. I learned everything I know about plant medicine from watching her hands.\n\nI'm drying bundles of her herbs to bring to Florence. It feels like the right way to honor her and to share her medicine with this circle.",
        comments: [
          { user: attendees[21], body: "What a beautiful tribute, Cosima. Your nonna's medicine will be with us in the circle." },
          { user: attendees[20], body: "Ancestral plant wisdom passed through women's hands. This is exactly why we gather." },
          { user: attendees[23], body: "I got chills reading this. Thank you for sharing her legacy with us." },
          { user: attendees[22], body: "My abuela had the same relationship with her garden. These grandmothers are still teaching us." }
        ]
      }
    ]
  }

  post_base_time = 5.days.ago

  posts_data.each do |cohort_name, posts|
    cohort = cohorts[cohort_name]
    next unless cohort

    posts.each_with_index do |post_data, i|
      post = cohort.posts.find_or_create_by!(body: post_data[:body]) do |p|
        p.user = post_data[:author]
        p.pinned = post_data[:pinned]
        p.created_at = post_base_time + (i * 12).hours
        p.updated_at = post_base_time + (i * 12).hours
      end

      post_data[:comments].each_with_index do |comment_data, j|
        post.post_comments.find_or_create_by!(user: comment_data[:user], body: comment_data[:body]) do |c|
          c.created_at = post.created_at + ((j + 1) * 2).hours
          c.updated_at = post.created_at + ((j + 1) * 2).hours
        end
      end
    end

    puts "Seeded #{posts.size} posts with comments in: #{cohort_name}"
  end

  dm_threads = [
    {
      between: [ attendees[0], attendees[5] ],
      messages: [
        { sender: attendees[0],  body: "Freya, do you have that recipe for the postpartum tea blend?" },
        { sender: attendees[5],  body: "Yes! It's red raspberry leaf, nettle, oat straw, and a little rose petal." },
        { sender: attendees[0],  body: "Thank you so much. My neighbor just had her baby and I want to make her a batch." },
        { sender: attendees[5],  body: "That's so sweet. Add a pinch of chamomile too if she's having trouble sleeping." },
        { sender: attendees[0],  body: "Will do. You're the best." },
        { sender: attendees[5],  body: "Anytime, sister. Let me know how she likes it!" }
      ]
    },
    {
      between: [ attendees[2], attendees[3] ],
      messages: [
        { sender: attendees[2],  body: "Willow, I loved your movement piece at the last gathering." },
        { sender: attendees[3],  body: "Thank you, Aria! Your meditation at the end was so grounding." },
        { sender: attendees[2],  body: "I was thinking we could collaborate on something. Movement and acupressure combined." },
        { sender: attendees[3],  body: "I would LOVE that. When can we meet to plan?" },
        { sender: attendees[2],  body: "How about next Tuesday afternoon? I could come to Ashland." },
        { sender: attendees[3],  body: "Perfect. I'll make us lunch and we can brainstorm after." },
        { sender: attendees[2],  body: "See you then!" }
      ]
    },
    {
      between: [ attendees[20], attendees[24] ],
      messages: [
        { sender: attendees[20], body: "Cosima, I'm so looking forward to the Florence gathering." },
        { sender: attendees[24], body: "Me too, Elara! I've been scouting locations around the city." },
        { sender: attendees[20], body: "Is there anything I can help with from here?" },
        { sender: attendees[24], body: "Actually, could you connect me with Maeve? I'd love to include some Celtic elements." },
        { sender: attendees[20], body: "Of course! I'll introduce you two." },
        { sender: attendees[24], body: "Wonderful. This is going to be such a rich weaving of traditions." }
      ]
    },
    {
      between: [ admin, attendees[0] ],
      messages: [
        { sender: admin,         body: "Luna, just wanted to check in on the Spring Retreat logistics." },
        { sender: attendees[0],  body: "Everything's on track! Venue is confirmed, meal plan is set." },
        { sender: admin,         body: "Great. Do you need me to send out any reminders to the group?" },
        { sender: attendees[0],  body: "That would be helpful. Maybe a reminder about arrival times and what to bring?" },
        { sender: admin,         body: "I'll draft something tonight and send it out tomorrow." },
        { sender: attendees[0],  body: "Thank you for all your support with this." }
      ]
    }
  ]

  dm_threads.each do |thread|
    conversation = Conversation.between(thread[:between][0], thread[:between][1])

    next if conversation.direct_messages.any?

    thread[:messages].each_with_index do |msg, i|
      conversation.direct_messages.create!(
        sender: msg[:sender],
        body: msg[:body],
        created_at: base_time + (i * 5).minutes,
        updated_at: base_time + (i * 5).minutes
      )
    end

    conversation.touch

    puts "Seeded DM conversation between #{thread[:between].map(&:name).join(' and ')}"
  end
end

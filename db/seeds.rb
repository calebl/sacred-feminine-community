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

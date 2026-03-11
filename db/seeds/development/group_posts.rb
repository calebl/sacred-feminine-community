group_post_base_time = 4.days.ago

# Helper to create a group post with comments
def seed_group_post(group, author:, pinned:, body:, comments:, time_offset:)
  post = group.group_posts.create!(
    user: author,
    pinned: pinned,
    body: body,
    created_at: time_offset,
    updated_at: time_offset
  )

  comments.each_with_index do |comment_data, j|
    post.group_post_comments.create!(
      user: comment_data[:user],
      body: comment_data[:body],
      created_at: time_offset + ((j + 1) * 3).hours,
      updated_at: time_offset + ((j + 1) * 3).hours
    )
  end

  post
end

# --- Herbal Medicine Circle ---

seed_group_post groups.herbal_medicine,
  author: users.freya, pinned: true, time_offset: group_post_base_time,
  body: "Welcome to the Herbal Medicine Circle! This is a space to share recipes, ask questions, and deepen our relationship with plant allies.\n\nSome ideas for what to share:\n- Seasonal herbal preparations\n- Wildcrafting finds\n- Book recommendations\n- Questions about herbs and dosages\n\nLet's learn from each other!",
  comments: [
    { user: users.luna,   body: "So happy this group exists. I've been wanting a dedicated space for herbal conversation." },
    { user: users.rowan,  body: "This is wonderful. I'll share my spring tonic recipe soon." },
    { user: users.clover, body: "Excited to be here! I have so many questions about tincture ratios." }
  ]

seed_group_post groups.herbal_medicine,
  author: users.freya, pinned: false, time_offset: group_post_base_time + 14.hours,
  body: "Here's my fire cider recipe as promised:\n\n- 1 quart raw apple cider vinegar\n- 1/2 cup fresh horseradish root, grated\n- 1/4 cup garlic, minced\n- 1/2 cup onion, diced\n- 1/4 cup fresh ginger, grated\n- 2 tbsp turmeric root, grated\n- 2-3 hot peppers, sliced\n- 1 lemon, zested and juiced\n- 2 sprigs fresh rosemary\n\nCombine everything in a jar. Let it infuse for 4-6 weeks, shaking daily. Strain and add raw honey to taste.\n\nTake a tablespoon daily or use it as a salad dressing base!",
  comments: [
    { user: users.luna,   body: "This is incredible. Starting a batch today." },
    { user: users.clover, body: "I add a handful of rose hips to mine for extra vitamin C. Highly recommend!" },
    { user: users.rowan,  body: "The rosemary is a nice touch. I've never added that before." }
  ]

seed_group_post groups.herbal_medicine,
  author: users.rowan, pinned: false, time_offset: group_post_base_time + 28.hours,
  body: "Question for the group: what are your go-to herbs for supporting someone through grief?\n\nI have a friend who recently lost her mother and I want to make her a care package. Thinking hawthorn berry, lemon balm, and rose petal. What else would you add?",
  comments: [
    { user: users.freya,  body: "Motherwort is beautiful for grief that sits in the chest. A few drops of tincture can really help." },
    { user: users.luna,   body: "I'd add mimosa bark. It's sometimes called the 'tree of collective happiness' and it's wonderful for deep sadness." },
    { user: users.clover, body: "Holy basil (tulsi) is also really comforting. It helps the heart feel held." }
  ]

# --- Morning Breathwork ---

seed_group_post groups.breathwork,
  author: users.maya, pinned: true, time_offset: group_post_base_time,
  body: "Welcome to Morning Breathwork! Let's use this space to share our daily practices, support each other's consistency, and explore different techniques.\n\nFeel free to post:\n- What you practiced today\n- How you're feeling\n- Questions about technique\n- Resources and recommendations\n\nNo pressure to practice every day. Show up when you can.",
  comments: [
    { user: users.aria,   body: "Love this! Consistency has been my biggest challenge. Having a group helps so much." },
    { user: users.soleil, body: "I'm newer to breathwork so I might have lots of questions. Thanks for creating this space!" }
  ]

seed_group_post groups.breathwork,
  author: users.aria, pinned: false, time_offset: group_post_base_time + 14.hours,
  body: "Sharing some acupressure points that pair beautifully with breathwork:\n\n1. Lung 7 (Lieque) - inside of the wrist, above the thumb. Opens the chest and supports the lungs.\n2. Conception Vessel 17 (Shanzhong) - center of the chest between the nipples. The 'sea of qi' point.\n3. Kidney 1 (Yongquan) - bottom of the foot. Grounds energy and calms the mind.\n\nTry pressing each point gently for 30 seconds before your breathwork practice. You'll notice a deeper, more open breath.",
  comments: [
    { user: users.maya,   body: "I tried the chest point this morning and it completely changed the quality of my breath. Thank you, Aria!" },
    { user: users.soleil, body: "This is exactly the kind of integration I've been looking for. So helpful." }
  ]

# --- Creative Arts & Expression ---

seed_group_post groups.creative_arts,
  author: users.willow, pinned: true, time_offset: group_post_base_time,
  body: "Welcome to Creative Arts & Expression! This group is for anyone who creates, wants to create, or is curious about creativity as a spiritual practice.\n\nAll forms welcome: visual art, dance, music, writing, fiber arts, ceramics, whatever calls to you.\n\nShare your work, your process, and your questions. There is no judgment here, only encouragement.",
  comments: [
    { user: users.fern,   body: "Thank you for starting this, Willow. Creativity thrives in community." },
    { user: users.dahlia, body: "So glad to have a space for this. Art-making can feel solitary. This helps." }
  ]

seed_group_post groups.creative_arts,
  author: users.fern, pinned: false, time_offset: group_post_base_time + 14.hours,
  body: "I've been experimenting with natural pigments made from local earth and plants. Yesterday I ground red ochre from clay I dug near my studio and mixed it with egg yolk to make a tempera paint.\n\nThe color is rich and warm in a way that manufactured paint never captures. There's something about painting with the actual earth that changes the energy of the work.\n\nHas anyone else worked with natural pigments?",
  comments: [
    { user: users.willow, body: "I use natural dyes for fabric but never thought about painting. The earth-as-medium idea is beautiful." },
    { user: users.dahlia, body: "In ceramics, I use local clay bodies and they always have more character than commercial clay. Same principle!" }
  ]

# --- Book Club ---

seed_group_post groups.book_club,
  author: users.celeste, pinned: true, time_offset: group_post_base_time,
  body: "Welcome to our book club! We're reading 'Women Who Run With the Wolves' by Clarissa Pinkola Estés.\n\nPace: One chapter every two weeks.\n\nHow it works:\n- Read the chapter on your own\n- Share reflections, underlined passages, and personal stories here\n- We'll have a deeper discussion thread each time we finish a chapter\n\nCurrently reading: Chapter 3 - Nosing Out the Facts: The Retrieval of Intuition as Initiation",
  comments: [
    { user: users.sage,  body: "Perfect pace. This book needs slow digestion." },
    { user: users.hazel, body: "I read this years ago but it hits completely differently now. Excited to revisit it with all of you." },
    { user: users.wren,  body: "First time reading it. Already hooked after the introduction." }
  ]

seed_group_post groups.book_club,
  author: users.hazel, pinned: false, time_offset: group_post_base_time + 14.hours,
  body: "Discussion questions for the Bluebeard chapter:\n\n1. What does the 'key' represent in your own life? What doors have you been afraid to open?\n2. Estés writes about the 'naive woman' who must die so the 'knowing woman' can live. When have you experienced this death/rebirth?\n3. How do you recognize the 'predator' energy in your own psyche or relationships?\n\nTake your time with these. They're meant to be sat with, not rushed through.",
  comments: [
    { user: users.celeste, body: "Question 2 stopped me in my tracks. I'm journaling on it before I respond here." },
    { user: users.wren,    body: "The predator question is so important. I think we often externalize it but it lives inside too." },
    { user: users.sage,    body: "I've been carrying question 1 with me all week. The key for me right now is my creative voice. I keep holding it back." }
  ]

seed_group_post groups.book_club,
  author: users.wren, pinned: false, time_offset: group_post_base_time + 28.hours,
  body: "A passage that keeps echoing in me:\n\n'The doors to the world of the wild Self are few but precious. If you have a deep scar, that is a door. If you have an old, old story, that is a door.'\n\nI've been thinking about my scars as doorways rather than wounds. It's completely reframing how I see my own history.",
  comments: [
    { user: users.celeste, body: "This passage changed something in me the first time I read it. Scars as doorways. So powerful." },
    { user: users.hazel,   body: "In my doula work, I see this in birth stories all the time. The hardest births often crack open the deepest wisdom." }
  ]

# --- European Traditions Exchange ---

seed_group_post groups.european_traditions,
  author: users.elara, pinned: true, time_offset: group_post_base_time,
  body: "Welcome to the European Traditions Exchange! This group is for sharing folk healing practices, seasonal rituals, and ancestral wisdom from our European roots.\n\nWhether your traditions are Celtic, Nordic, Mediterranean, Germanic, Slavic, or anything in between, there is room here.\n\nLet's learn from each other and rediscover the old ways together.",
  comments: [
    { user: users.maeve, body: "What a beautiful intention. I have so much to share from the Irish tradition and so much to learn from yours." }
  ]

seed_group_post groups.european_traditions,
  author: users.maeve, pinned: false, time_offset: group_post_base_time + 14.hours,
  body: "In the Celtic tradition, the hawthorn tree is sacred to the goddess and marks the boundary between worlds. In Ireland, lone hawthorn trees in fields are never cut down, as they're believed to be fairy trees.\n\nHawthorn berries are also wonderful heart medicine. I make a tincture every autumn and take it through the winter.\n\nDoes the hawthorn have significance in Nordic traditions too, Elara?",
  comments: [
    { user: users.elara, body: "In Scandinavian folklore, the hawthorn is also associated with protection and fertility. We use the berries similarly in folk medicine. Such a beautiful cross-cultural thread!" }
  ]

puts "Seeded group posts with comments for all groups"

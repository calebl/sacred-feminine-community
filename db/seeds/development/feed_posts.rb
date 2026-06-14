feed_post_base_time = 3.days.ago

# Helper to create a public feed post with comments and reactions.
# reactions is a list of { user:, emoji: } pairs. Several users sharing the
# same emoji is intentional so the hover tooltip lists multiple names.
def seed_feed_post(author:, body:, comments:, reactions:, time_offset:, pinned: false)
  post = author.feed_posts.create!(
    pinned: pinned,
    body: body,
    created_at: time_offset,
    updated_at: time_offset
  )

  comments.each_with_index do |comment_data, j|
    post.feed_post_comments.create!(
      user: comment_data[:user],
      body: comment_data[:body],
      created_at: time_offset + ((j + 1) * 2).hours,
      updated_at: time_offset + ((j + 1) * 2).hours
    )
  end

  reactions.each do |reaction_data|
    post.reactions.create!(user: reaction_data[:user], emoji: reaction_data[:emoji])
  end

  post
end

seed_feed_post author: users.luna, pinned: true, time_offset: feed_post_base_time,
  body: "Welcome to the community feed! This is our shared space — open to everyone, no matter which circle or cohort you're part of. Share what's alive for you: a practice, a question, a moment of beauty from your day.\n\nLet's keep weaving this web of connection together.",
  comments: [
    { user: users.aurora, body: "So grateful for this space. It feels like coming home every time I open it." },
    { user: users.rowan,  body: "Love seeing all the circles come together here." },
    { user: users.maya,   body: "This feed has become part of my morning ritual." }
  ],
  reactions: [
    { user: users.aurora, emoji: "❤️" },
    { user: users.rowan,  emoji: "❤️" },
    { user: users.maya,   emoji: "❤️" },
    { user: users.freya,  emoji: "🙏" },
    { user: users.sage,   emoji: "🙏" },
    { user: users.willow, emoji: "🔥" }
  ]

seed_feed_post author: users.sage, time_offset: feed_post_base_time + 8.hours,
  body: "Watched the sun come up over the Bitterroot this morning and just wept. Some mornings the beauty is almost too much to hold. Wishing you all a tender, spacious day.",
  comments: [
    { user: users.celeste, body: "This made me pause and breathe. Thank you, Sage." },
    { user: users.ivy,     body: "The mountains always know how to crack us open." }
  ],
  reactions: [
    { user: users.celeste, emoji: "❤️" },
    { user: users.ivy,     emoji: "❤️" },
    { user: users.willow,  emoji: "❤️" },
    { user: users.aria,    emoji: "❤️" },
    { user: users.juniper, emoji: "😮" },
    { user: users.dahlia,  emoji: "😮" }
  ]

seed_feed_post author: users.rowan, time_offset: feed_post_base_time + 18.hours,
  body: "Reminder for everyone foraging this season: always leave more than you take, and never harvest the first plant you find. Ask permission, give thanks, and only gather where the stand is abundant.\n\nThe plants are generous, but the relationship is sacred.",
  comments: [
    { user: users.clover, body: "Yes! Tending the relationship is everything. Thank you for this reminder." },
    { user: users.freya,  body: "Saving this. Such important wisdom for the new foragers among us." },
    { user: users.elara,  body: "We say something similar in the Nordic tradition. The forest remembers how you treat it." }
  ],
  reactions: [
    { user: users.clover, emoji: "🙏" },
    { user: users.freya,  emoji: "🙏" },
    { user: users.elara,  emoji: "🙏" },
    { user: users.luna,   emoji: "🙏" },
    { user: users.hazel,  emoji: "👍" },
    { user: users.rowan,  emoji: "👍" }
  ]

seed_feed_post author: users.wren, time_offset: feed_post_base_time + 30.hours,
  body: "Little joy of the day: my two-year-old found me singing in the kitchen and started 'harmonizing' at the top of her lungs. We were both laughing so hard we had to sit on the floor. May we all stay this easily delighted. 🎶",
  comments: [
    { user: users.aurora, body: "This is the best thing I've read all week. 😂" },
    { user: users.noor,   body: "The next generation of singers! So precious." }
  ],
  reactions: [
    { user: users.aurora, emoji: "😂" },
    { user: users.noor,   emoji: "😂" },
    { user: users.maya,   emoji: "😂" },
    { user: users.celeste, emoji: "😂" },
    { user: users.luna,   emoji: "❤️" },
    { user: users.freya,  emoji: "❤️" }
  ]

seed_feed_post author: users.admin, time_offset: feed_post_base_time + 42.hours,
  body: "A gentle note from your hosts: invitations for the spring gatherings are going out this week. Keep an eye on your inbox, and please reach out if you have any questions about logistics, scholarships, or travel.\n\nWe're so glad you're here. 🌹",
  comments: [
    { user: users.willow, body: "Thank you for everything you hold for this community." },
    { user: users.iris,   body: "Counting the days! 🙏" }
  ],
  reactions: [
    { user: users.willow, emoji: "🙏" },
    { user: users.iris,   emoji: "🙏" },
    { user: users.maya,   emoji: "🙏" },
    { user: users.dahlia, emoji: "❤️" },
    { user: users.sage,   emoji: "❤️" },
    { user: users.cosima, emoji: "🔥" }
  ]

puts "Seeded #{FeedPost.count} feed posts with comments and reactions"

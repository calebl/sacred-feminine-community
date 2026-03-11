post_base_time = 5.days.ago

# Helper to create a post with comments
def seed_post(cohort, author:, pinned:, body:, comments:, time_offset:)
  post = cohort.posts.create!(
    user: author,
    pinned: pinned,
    body: body,
    created_at: time_offset,
    updated_at: time_offset
  )

  comments.each_with_index do |comment_data, j|
    post.post_comments.create!(
      user: comment_data[:user],
      body: comment_data[:body],
      created_at: time_offset + ((j + 1) * 2).hours,
      updated_at: time_offset + ((j + 1) * 2).hours
    )
  end

  post
end

# --- Bozeman Spring Retreat 2025 ---

seed_post cohorts.bozeman_spring,
  author: users.luna, pinned: true, time_offset: post_base_time,
  body: "Hey beautiful souls! Here's a suggested packing list for the spring retreat:\n\n- Comfortable layers (mornings are still cool in April)\n- Journal and pen\n- A sacred object for the altar\n- Reusable water bottle\n- Yoga mat or blanket for floor work\n\nPlease also bring any medicines, herbs, or offerings you'd like to share with the group. We'll have a community table set up.\n\nRemember: this is a tech-free retreat. Please plan to leave devices in your room.",
  comments: [
    { user: users.freya,  body: "Great list! I'll also bring extra sage bundles for anyone who wants one." },
    { user: users.rowan,  body: "Should we bring our own towels or are they provided?" },
    { user: users.luna,   body: "Towels are provided! But bring a warm blanket if you like to cocoon during rest time." },
    { user: users.wren,   body: "Can I bring my guitar? Would love to play some songs by the fire." },
    { user: users.sage,   body: "Yes please! Music around the fire is the best part." }
  ]

seed_post cohorts.bozeman_spring,
  author: users.sage, pinned: false, time_offset: post_base_time + 12.hours,
  body: "I just wanted to take a moment to say how grateful I am for each of you. This circle has changed my life in ways I couldn't have imagined when I first joined.\n\nThe wilderness has always been my teacher, but learning alongside all of you has deepened that relationship in beautiful ways. Looking forward to our time together in April.\n\nWith love,\nSage",
  comments: [
    { user: users.luna,   body: "This made me tear up. We're so lucky to have you in this circle, Sage." },
    { user: users.aurora, body: "The feeling is so mutual. This group is home." },
    { user: users.freya,  body: "Love you all so much. Can't wait to be together again." }
  ]

seed_post cohorts.bozeman_spring,
  author: users.rowan, pinned: false, time_offset: post_base_time + 24.hours,
  body: "Spring is the perfect time for liver-supporting herbs. I've been making a daily infusion of:\n\n1. Dandelion root\n2. Burdock root\n3. Nettle leaf\n4. A squeeze of lemon\n\nLet it steep overnight in a mason jar and drink it throughout the morning. Your body will thank you after winter.\n\nI'll bring some dried blends to share at the retreat!",
  comments: [
    { user: users.freya, body: "This is exactly what I needed. My body has been craving greens and bitters." },
    { user: users.wren,  body: "Would this work well combined with a morning breathwork practice?" },
    { user: users.rowan, body: "Absolutely! Drink the infusion about 30 minutes before breathwork for best results." }
  ]

seed_post cohorts.bozeman_spring,
  author: users.freya, pinned: false, time_offset: post_base_time + 36.hours,
  body: "I wanted to share something that's been on my heart. Last month I attended a home birth where the mother used only herbal support and breathwork through labor. It was one of the most powerful things I've witnessed.\n\nIt reminded me why this community matters so much. We're keeping these practices alive for the next generation.\n\nI'd love to lead a conversation about traditional birth practices at the retreat if anyone is interested.",
  comments: [
    { user: users.luna,   body: "Yes, absolutely. This is so important. I'd love to hear more." },
    { user: users.sage,   body: "As a doula-in-training, I would be so grateful for this conversation." },
    { user: users.aurora, body: "Count me in. My grandmother was a traditional midwife in Mexico and I carry her stories." }
  ]

seed_post cohorts.bozeman_spring,
  author: users.wren, pinned: false, time_offset: post_base_time + 48.hours,
  body: "Quick question for the group: would anyone be interested in a song circle on Saturday evening? I've been learning some beautiful chants from different traditions and I think it could be a really grounding way to close the day.\n\nNo experience needed. Just your voice and willingness to be present.",
  comments: [
    { user: users.freya, body: "I love this idea, Wren! Singing together always shifts something deep." },
    { user: users.rowan, body: "Absolutely. I know a few Appalachian folk songs that would fit perfectly." }
  ]

seed_post cohorts.bozeman_spring,
  author: users.aurora, pinned: false, time_offset: post_base_time + 60.hours,
  body: "Sharing a morning practice that's been really supportive for me this season:\n\nBefore getting out of bed, I place both hands on my belly and take three slow breaths. Then I whisper one word that I want to carry through the day. Today's word was \"trust.\"\n\nIt takes less than a minute but it has completely changed how I move through my mornings.",
  comments: [
    { user: users.luna, body: "This is beautiful, Aurora. I'm going to try it tomorrow morning." },
    { user: users.sage, body: "I've been doing something similar. My word today was 'spaciousness.'" },
    { user: users.wren, body: "I started doing this after you mentioned it last week and it's already shifting things for me." }
  ]

# --- Solstice Gathering ---

seed_post cohorts.solstice,
  author: users.willow, pinned: true, time_offset: post_base_time,
  body: "Here's what I'm envisioning for our solstice ceremony:\n\nDawn (5:15 AM) - Gather in silence. Sunrise movement meditation led by me, with Dahlia on drums.\n\nMorning (8 AM) - Breakfast together, then a sharing circle.\n\nAfternoon - Free time for rest, art, or nature walks.\n\nEvening - Fire ceremony led by Ember, followed by singing and stargazing.\n\nPlease feel free to suggest additions or changes!",
  comments: [
    { user: users.ember,   body: "This is beautiful, Willow. I'll prepare the fire space the evening before." },
    { user: users.juniper, body: "Could I do a brief star reading during the stargazing portion?" },
    { user: users.willow,  body: "That would be perfect, Juniper! Let's plan on that." },
    { user: users.aria,    body: "I can offer acupressure sessions during the free afternoon time." }
  ]

seed_post cohorts.solstice,
  author: users.fern, pinned: false, time_offset: post_base_time + 12.hours,
  body: "I've been working on a collaborative art piece for our gathering. The idea is a large sun mandala that we each contribute to during the retreat.\n\nI'll bring:\n- A 4-foot canvas with the base design\n- Acrylic paints in warm tones\n- Brushes for everyone\n\nEach person paints a ray of the sun with whatever colors and symbols feel right. By the end of the retreat, we'll have created something together.",
  comments: [
    { user: users.meadow, body: "I love this idea! Can we add dried flowers to the canvas too?" },
    { user: users.fern,   body: "Yes! Pressed flowers would be gorgeous. Bring whatever natural materials inspire you." },
    { user: users.dahlia, body: "This is going to be so beautiful. I'll bring some gold leaf." }
  ]

seed_post cohorts.solstice,
  author: users.juniper, pinned: false, time_offset: post_base_time + 24.hours,
  body: "I've been tracking the planetary alignments for the week of our gathering and the energy is remarkable. Mars and Venus are in a beautiful trine, which supports both action and receptivity.\n\nI'd recommend everyone spend some time under the night sky in the days leading up to the solstice. The stars are inviting us to release old patterns and step into new ones.\n\nI'll have personal mini-readings available for anyone who wants one during the retreat.",
  comments: [
    { user: users.willow, body: "I've been feeling this shift so strongly. Thank you for naming it, Juniper." },
    { user: users.meadow, body: "I'd love a reading! The stars have been speaking to me loudly this month." },
    { user: users.ember,  body: "This is going to add such a beautiful layer to our fire ceremony." }
  ]

seed_post cohorts.solstice,
  author: users.dahlia, pinned: false, time_offset: post_base_time + 36.hours,
  body: "I've been making ceremonial drums from ethically sourced deer hide and I just finished one specifically for our gathering. The sound is deep and resonant, perfect for outdoor ceremony.\n\nWould anyone else like to bring instruments? I think a spontaneous sound journey by the fire could be really powerful.",
  comments: [
    { user: users.aria,   body: "I have a set of Tibetan singing bowls I could bring." },
    { user: users.willow, body: "I'll bring my rain stick and some rattles." },
    { user: users.fern,   body: "I don't play anything but I'd love to add my voice. Overtone singing has been calling me." }
  ]

seed_post cohorts.solstice,
  author: users.ember, pinned: false, time_offset: post_base_time + 48.hours,
  body: "For the fire ceremony, I'll need some help gathering wood the afternoon before. The best firewood is already seasoned and dry. I know a spot on the property where there's a good supply of juniper and pinon.\n\nAlso, if anyone has sacred items they'd like to burn as an offering or release, please bring them. The solstice fire is a powerful time for letting go.",
  comments: [
    { user: users.dahlia, body: "I'll help with wood gathering. I love that kind of physical, grounding work before ceremony." },
    { user: users.juniper, body: "I have some old journals I've been wanting to release. This feels like the right fire." },
    { user: users.meadow, body: "I wrote letters to my younger self that I'd like to burn. Thank you for holding this space, Ember." }
  ]

seed_post cohorts.solstice,
  author: users.aria, pinned: false, time_offset: post_base_time + 60.hours,
  body: "Offering free acupressure sessions during the afternoon free time. I'll set up in the shade with mats and blankets. Each session is about 20 minutes.\n\nAcupressure works with the same meridian system as acupuncture but uses finger pressure instead of needles. It's wonderful for releasing tension, improving circulation, and supporting emotional balance.\n\nNo sign-up needed, just come find me!",
  comments: [
    { user: users.willow, body: "Aria, your hands are magic. Everyone should take advantage of this!" },
    { user: users.fern,   body: "I'll definitely be stopping by. My shoulders have been holding so much tension." }
  ]

seed_post cohorts.solstice,
  author: users.meadow, pinned: false, time_offset: post_base_time + 72.hours,
  body: "I've been foraging for wildflowers to make flower crowns for everyone at the gathering. So far I have dried lavender, yarrow, and wild rose.\n\nIf anyone sees any beautiful blooms on their walks, please pick a few and bring them! I'll have wire and ribbon so we can make them together.",
  comments: [
    { user: users.willow, body: "This makes my heart so happy. I'll look for some on my hikes this week." },
    { user: users.dahlia, body: "I have a huge patch of chamomile in my garden that would be perfect for this." }
  ]

# --- Mountain Women's Circle ---

seed_post cohorts.mountain_circle,
  author: users.iris, pinned: true, time_offset: post_base_time,
  body: "Welcome to the Mountain Women's Circle! Our September gathering in Whitefish is going to be so special.\n\nThe lodge sits right on the edge of the forest with views of Glacier National Park. We'll have access to hiking trails, a creek for water ceremony, and a beautiful meadow for our circle work.\n\nPlease arrive by Friday evening so we can have a slow dinner together before the weekend begins.",
  comments: [
    { user: users.sage,    body: "This sounds incredible, Iris. I've been longing for mountain time." },
    { user: users.celeste, body: "I'm so excited to be near Glacier. The energy there is unlike anywhere else." },
    { user: users.maya,    body: "Can't wait! I'll bring my breathwork playlist for the morning sessions." }
  ]

seed_post cohorts.mountain_circle,
  author: users.sage, pinned: false, time_offset: post_base_time + 12.hours,
  body: "I want to lead a wilderness awareness walk on Saturday morning. We'll practice what my teacher calls 'fox walking,' moving slowly through the forest and tuning into all our senses.\n\nThe goal isn't to cover distance but to truly arrive in the landscape. We'll stop to observe, listen, touch, and smell. I've found that this practice is one of the fastest ways to drop into presence.\n\nWear shoes you can walk quietly in. We'll be out for about two hours.",
  comments: [
    { user: users.hazel, body: "I love this practice. It completely changes how I experience the forest." },
    { user: users.iris,  body: "This is perfect for our first morning. Thank you, Sage." },
    { user: users.ivy,   body: "I learned something similar from an elder years ago. Beautiful to see it here." }
  ]

seed_post cohorts.mountain_circle,
  author: users.maya, pinned: false, time_offset: post_base_time + 24.hours,
  body: "Offering a breathwork session on Saturday afternoon. We'll do a connected breathing pattern for about 45 minutes followed by integration time.\n\nThis particular practice can bring up strong emotions, memories, and physical sensations. It's all welcome and all part of the process. I'll be there to guide and support.\n\nPlease eat lightly beforehand and bring a blanket and eye mask if you have one.",
  comments: [
    { user: users.clover,  body: "I've been wanting to try this for months. Thank you for offering it, Maya." },
    { user: users.celeste, body: "Maya's breathwork sessions are incredible. Be ready to go deep." },
    { user: users.sage,    body: "I'll bring extra blankets for anyone who needs them." }
  ]

seed_post cohorts.mountain_circle,
  author: users.hazel, pinned: false, time_offset: post_base_time + 36.hours,
  body: "Something I've been sitting with: the womb as a center of creativity, not just reproduction. In my doula practice I work with women across the full spectrum of life stages, and I've learned that womb wisdom doesn't require a physical womb.\n\nI'd love to facilitate a gentle exploration of this at the gathering. We'd use visualization, gentle movement, and sharing.\n\nAnyone interested?",
  comments: [
    { user: users.maya,   body: "So much yes to this, Hazel. This is the kind of conversation we need more of." },
    { user: users.iris,   body: "Beautifully said. I'm in." },
    { user: users.clover, body: "Thank you for holding space for this. It's something I've been wanting to explore." }
  ]

seed_post cohorts.mountain_circle,
  author: users.celeste, pinned: false, time_offset: post_base_time + 48.hours,
  body: "I wrote this haiku on my morning walk today and wanted to share it with you all:\n\nCold creek, mossy stone,\nthe mountain holds what we lose,\nroots remember us.\n\nSee you all in Whitefish soon.",
  comments: [
    { user: users.sage, body: "Oh Celeste, this is so beautiful. You always find the exact right words." },
    { user: users.ivy,  body: "I can feel the mountain in these words. Thank you for sharing." }
  ]

seed_post cohorts.mountain_circle,
  author: users.clover, pinned: false, time_offset: post_base_time + 60.hours,
  body: "I'll be bringing a big batch of my homestead elderberry syrup for everyone. It's made with elderberries from my garden, raw honey from my bees, ginger, and cinnamon.\n\nPerfect for immune support as we head into fall. Take a tablespoon each morning during the retreat and I'll send you home with a small jar.\n\nAlso bringing my sourdough starter for fresh bread at the gathering!",
  comments: [
    { user: users.hazel, body: "Clover, your elderberry syrup is the best I've ever had. So generous of you." },
    { user: users.maya,  body: "Fresh sourdough and elderberry syrup? We're going to be so nourished." },
    { user: users.iris,  body: "This is exactly why I love this circle. Everyone brings their gifts." }
  ]

seed_post cohorts.mountain_circle,
  author: users.ivy, pinned: false, time_offset: post_base_time + 72.hours,
  body: "For anyone arriving early on Friday, I'd love to take a small group up to a viewpoint I know about 30 minutes from the lodge. It's an easy trail and the views of the valley are stunning at sunset.\n\nWe could do a simple opening prayer together up there before heading back down for dinner. Just a quiet way to mark the beginning of our time together.\n\nLet me know if you're interested and I'll plan for it.",
  comments: [
    { user: users.sage,    body: "I'll be there early. Count me in, Ivy." },
    { user: users.celeste, body: "A sunset prayer on the mountain sounds like the perfect way to begin." }
  ]

# --- Desert Rose Retreat ---

seed_post cohorts.desert_rose,
  author: users.ember, pinned: true, time_offset: post_base_time,
  body: "Welcome to the Desert Rose Retreat! Sedona is one of the most energetically powerful places on earth and I'm so honored to host us there.\n\nWe'll be staying at a retreat center near Bell Rock. The property has an outdoor ceremony space, a labyrinth, and views of the red rocks from every room.\n\nImportant: October in Sedona is warm during the day (70s-80s) but can drop to the 40s at night. Bring layers!\n\nI'll share a detailed schedule next week.",
  comments: [
    { user: users.willow, body: "I've wanted to visit Sedona for years. This feels like divine timing." },
    { user: users.dahlia, body: "The energy near Bell Rock is extraordinary. We're in for something special." },
    { user: users.fern,   body: "So excited! Will there be time for a vortex hike?" },
    { user: users.ember,  body: "Absolutely! I'm planning a sunrise vortex hike on Saturday morning." }
  ]

seed_post cohorts.desert_rose,
  author: users.willow, pinned: false, time_offset: post_base_time + 12.hours,
  body: "I'd like to lead an earth-based movement practice on the red rocks if the group is open to it. It's a blend of dance therapy and somatic awareness, designed to help us connect with the energy of the land.\n\nWe'll work barefoot on the earth (weather permitting), using slow, intuitive movement to listen to what the body and the land are communicating. No dance experience needed.\n\nI find that the desert strips away everything unnecessary and leaves us with only what's true.",
  comments: [
    { user: users.ember,  body: "Willow, your movement work is always so profound. I can't think of a better setting for it." },
    { user: users.soleil, body: "I'm new to somatic work but really curious. This sounds like a gentle entry point." },
    { user: users.dahlia, body: "Dancing on red rock earth. I can already feel it calling." }
  ]

seed_post cohorts.desert_rose,
  author: users.dahlia, pinned: false, time_offset: post_base_time + 24.hours,
  body: "I'll be bringing my ceramics supplies to the retreat and would love to lead a hand-building session. We'll work with locally sourced red clay, shaping vessels by hand without a wheel.\n\nThere's something deeply meditative about working with earth from the place you're sitting on. The pieces will need to air dry, so they won't be fired, but they make beautiful altar pieces.\n\nI'll bring enough clay for everyone.",
  comments: [
    { user: users.fern,   body: "Working with Sedona clay? That's such a special idea, Dahlia." },
    { user: users.willow, body: "I love the idea of creating something from the earth of this sacred place." },
    { user: users.soleil, body: "I've never worked with clay before but I'm drawn to try. Thank you for offering this." }
  ]

seed_post cohorts.desert_rose,
  author: users.soleil, pinned: false, time_offset: post_base_time + 36.hours,
  body: "Hello everyone! This is my first retreat with this group and I'm feeling a mix of excitement and nervousness. I've been practicing Kundalini yoga on my own for two years but haven't had a community to share it with.\n\nI'm so grateful to have been invited into this circle. I'm coming with an open heart and a willingness to be changed by whatever unfolds.\n\nIs there anything I should know or prepare for my first gathering?",
  comments: [
    { user: users.ember,  body: "Welcome, Soleil! Just bring yourself exactly as you are. That's always enough." },
    { user: users.willow, body: "You're going to love it. The only preparation needed is openness, and it sounds like you already have that." },
    { user: users.dahlia, body: "We're so happy you're joining us. First retreats are always transformative." },
    { user: users.fern,   body: "I remember my first retreat with this group. It changed everything. Welcome home." }
  ]

seed_post cohorts.desert_rose,
  author: users.fern, pinned: false, time_offset: post_base_time + 48.hours,
  body: "I'm planning to paint during the retreat and would love company. I'll set up an outdoor painting station where anyone can join me during free time. I'll have extra canvases, watercolors, and brushes.\n\nThe desert light in Sedona is unlike anything I've ever painted in. The reds and golds shift constantly throughout the day. Even if you don't consider yourself a painter, come sit with me and play with color.\n\nSometimes the most powerful art comes from people who aren't trying to make art.",
  comments: [
    { user: users.soleil, body: "I haven't painted since I was a child but something about this invitation feels important. I'll be there." },
    { user: users.ember,  body: "Fern's painting sessions are one of my favorite parts of retreat. So healing." }
  ]

# --- Winter Womb Retreat 2026 ---

seed_post cohorts.winter_womb,
  author: users.admin, pinned: true, time_offset: post_base_time,
  body: "Welcome to the Winter Womb Retreat! Here are the logistics:\n\nLocation: Mountain Spirit Lodge, Big Sky, MT\nCheck-in: Friday, January 24th, 3:00 PM\nCheck-out: Monday, January 27th, 11:00 AM\n\nThe cabin has 6 bedrooms (shared), a large gathering room with fireplace, a fully equipped kitchen, and a covered hot tub.\n\nDriving conditions: The road to the cabin is plowed but can be icy. 4WD or chains recommended. I'll send GPS coordinates closer to the date.\n\nReach out if you need help with transportation!",
  comments: [
    { user: users.luna,  body: "This looks amazing! I can offer rides from Bozeman for anyone who needs them." },
    { user: users.celeste, body: "Is there a place to do outdoor meditation? Even in the cold, I love sitting outside." },
    { user: users.ivy,   body: "There's a beautiful clearing behind the lodge. I've been there before, it's magical in snow." },
    { user: users.elara, body: "I'll be flying into Bozeman. Luna, I would love a ride if that's ok!" },
    { user: users.luna,  body: "Of course, Elara! I'll pick you up at the airport. Just send me your flight details." }
  ]

seed_post cohorts.winter_womb,
  author: users.wren, pinned: false, time_offset: post_base_time + 12.hours,
  body: "For those who haven't experienced a cacao ceremony before, here's a little about what to expect:\n\nCeremonial cacao is different from regular chocolate. It's minimally processed and contains theobromine, which gently opens the heart and enhances introspection.\n\nTo prepare:\n- Eat lightly the day of the ceremony\n- Hydrate well\n- Set an intention for what you'd like to release or invite in\n\nI'll be using organic Guatemalan ceremonial-grade cacao. The ceremony will last about 90 minutes.",
  comments: [
    { user: users.aurora, body: "Thank you for explaining this, Wren. I've been curious and a little nervous. This helps!" },
    { user: users.wren,   body: "No need to be nervous at all. It's very gentle. You'll feel supported the whole time." },
    { user: users.rowan,  body: "Wren's cacao ceremonies are incredible. You're all in for a treat." },
    { user: users.noor,   body: "I've done cacao ceremonies in Spain and they're transformative. So excited for this!" }
  ]

seed_post cohorts.winter_womb,
  author: users.celeste, pinned: false, time_offset: post_base_time + 24.hours,
  body: "I've been working on a piece for our opening ceremony. Here's a preview:\n\n\"In the hush of winter's hold,\nwe gather close, we gather bold.\nRoot to root beneath the snow,\nthe seeds of spring already know.\"\n\nWould anyone else like to share a reading or poem? I think it would be powerful to have multiple voices in our opening.",
  comments: [
    { user: users.freya, body: "This is gorgeous, Celeste. I have a passage from a Mary Oliver poem I'd love to share." },
    { user: users.aria,  body: "I'd like to share a short meditation verse. Can I go after you?" },
    { user: users.celeste, body: "Yes to both! Let's create a beautiful flow of voices." }
  ]

seed_post cohorts.winter_womb,
  author: users.aria, pinned: false, time_offset: post_base_time + 36.hours,
  body: "I've been preparing a yin yoga sequence specifically designed for winter. It focuses on the kidney and bladder meridians, which correspond to the water element and are most active in the cold months.\n\nWe'll hold poses for 3-5 minutes each, giving the connective tissue time to release. I'll guide a meditation alongside the physical practice.\n\nWould Sunday morning work for everyone? I find the body is most receptive to deep stretching early in the day.",
  comments: [
    { user: users.luna, body: "Sunday morning is perfect. I love how yin yoga makes me feel so spacious inside." },
    { user: users.ivy,  body: "I've been needing this kind of slow, deep practice. Thank you, Aria." },
    { user: users.noor, body: "I do yin regularly at home but never with meridian guidance. Really looking forward to this." }
  ]

seed_post cohorts.winter_womb,
  author: users.ivy, pinned: false, time_offset: post_base_time + 48.hours,
  body: "I scouted the property last weekend and wanted to share some photos (coming soon). The snow is absolutely beautiful right now. The clearing behind the lodge has about two feet of fresh powder and the trees are crystallized with ice.\n\nFor those who want to do outdoor meditation, I found a sheltered spot under a stand of old-growth pines where the wind doesn't reach. We could set up cushions there and it would be surprisingly comfortable even in the cold.\n\nAlso, the hot tub is working great. Perfect for stargazing after ceremony.",
  comments: [
    { user: users.luna,  body: "This sounds magical, Ivy. Outdoor meditation in the snow is one of my favorite practices." },
    { user: users.wren,  body: "Hot tub under the stars after cacao ceremony? Yes please." },
    { user: users.elara, body: "Coming from Stockholm, I'm very used to the cold. Can't wait to sit in the snow with you all!" }
  ]

seed_post cohorts.winter_womb,
  author: users.aurora, pinned: false, time_offset: post_base_time + 60.hours,
  body: "I've been organizing a community meal plan so we can nourish ourselves well without anyone spending the whole retreat in the kitchen.\n\nHere's what I'm thinking:\n- Friday dinner: I'll prepare a big pot of pozole (my grandmother's recipe)\n- Saturday breakfast/lunch: Potluck style, everyone contributes one dish\n- Saturday dinner: Wren and Luna are cooking together\n- Sunday brunch: Simple and easy, eggs and sourdough\n\nPlease let me know about any allergies or dietary needs!",
  comments: [
    { user: users.freya,   body: "Your grandmother's pozole is legendary, Aurora. I'll bring fresh tortillas." },
    { user: users.rowan,   body: "I'll make a big batch of bone broth for anyone who wants it throughout the weekend." },
    { user: users.wren,    body: "Luna and I will handle Saturday dinner! Planning a warming curry." },
    { user: users.celeste, body: "This is so well organized. Thank you for taking this on, Aurora." }
  ]

seed_post cohorts.winter_womb,
  author: users.elara, pinned: false, time_offset: post_base_time + 72.hours,
  body: "Hello from Sweden! I'm Elara and this will be my first retreat with this group. Cosima from the European circle encouraged me to join and I'm so glad I did.\n\nA little about me: I'm a foraging guide and I study Nordic folk healing traditions. I'll be bringing some dried cloudberries and lingonberries from my summer harvest, along with a birch bark tea blend that's been a staple in Scandinavian women's medicine for centuries.\n\nSo excited to meet you all in person!",
  comments: [
    { user: users.luna,  body: "Welcome, Elara! We've heard so much about you from Cosima. So happy you're joining us." },
    { user: users.rowan, body: "Nordic herb traditions! I'd love to learn more about the birch bark tea. Welcome!" },
    { user: users.freya, body: "Cloudberries! I've only read about them. Can't wait to try them. Welcome to the circle." }
  ]

# --- European Sisters Circle ---

seed_post cohorts.european_sisters,
  author: users.cosima, pinned: true, time_offset: post_base_time,
  body: "I've secured a beautiful villa just outside the city center for our Florence gathering. It has:\n\n- A garden with olive trees perfect for outdoor ceremony\n- A large open room with natural light for our circle\n- A kitchen where we can cook together\n- Views of the Tuscan hills\n\nThe villa is a 20-minute bus ride from Santa Maria Novella train station. I'll share the exact address and directions soon.\n\nI'm planning to source food from the local market for our meals. If anyone has dietary needs, please let me know!",
  comments: [
    { user: users.elara, body: "This sounds absolutely dreamy, Cosima! I can help with cooking." },
    { user: users.maeve, body: "I'm vegetarian but very flexible. I can bring Irish soda bread recipe to share!" },
    { user: users.lina,  body: "I'd love to help in the kitchen too. I make a great German apple cake." },
    { user: users.noor,  body: "And I'll bring Spanish olive oil and manchego. We're going to eat so well!" }
  ]

seed_post cohorts.european_sisters,
  author: users.elara, pinned: false, time_offset: post_base_time + 12.hours,
  body: "One thing I love about this circle is that we each carry different folk traditions. I'd love for us to each share a practice from our heritage:\n\nMy offering: I'll lead a Nordic herb walk and teach about Scandinavian plant folk wisdom. In Sweden, we believe the forest has its own intelligence, and I'd love to share how my grandmother taught me to listen to it.\n\nWhat traditions would each of you like to share?",
  comments: [
    { user: users.maeve,  body: "I'd love to lead a Celtic blessing ceremony. The Brigid traditions are so relevant for women's circles." },
    { user: users.cosima, body: "I can share Italian herbal remedies passed down in my family. My nonna was a village healer." },
    { user: users.lina,   body: "I'll share a breathwork practice rooted in Germanic wellness traditions." },
    { user: users.noor,   body: "Flamenco has deep roots in feminine expression. I could teach a short movement piece." },
    { user: users.elara,  body: "This is going to be so beautiful. What a rich tapestry we're weaving together." }
  ]

seed_post cohorts.european_sisters,
  author: users.maeve, pinned: false, time_offset: post_base_time + 24.hours,
  body: "I wanted to share a practice I do every Imbolc that I think we could adapt for our Florence gathering. In the Celtic tradition, Brigid is the goddess of the hearth, of poetry, and of healing.\n\nOn the eve of Imbolc, we make Brigid's crosses from rushes and hang them over doorways for protection. I'll bring materials so we can each make one.\n\nThe cross has four arms spiraling outward, representing the turning of the seasons. Even though we'll be gathering in May, Brigid's energy of creative fire feels so right for our circle.",
  comments: [
    { user: users.cosima, body: "I love how you carry these traditions, Maeve. In Italy we have similar protective symbols woven from wheat." },
    { user: users.noor,   body: "Brigid's fire and creative energy is exactly what I feel in this group." },
    { user: users.elara,  body: "This is going to be such a meaningful craft to take home." }
  ]

seed_post cohorts.european_sisters,
  author: users.noor, pinned: false, time_offset: post_base_time + 36.hours,
  body: "I've been thinking about our gathering and I want to offer a flamenco workshop. Not the performance kind, but the roots of it. The duende, the deep song.\n\nFlamenco originated with women in kitchens and courtyards, stomping their grief and joy into the earth. It was never meant for stages. It was a language of the body when words weren't enough.\n\nI'll teach basic footwork and hand movements. We'll work with rhythm and breath. No experience needed, just willingness to feel.\n\nBring shoes with a hard sole if you have them.",
  comments: [
    { user: users.lina,   body: "Noor, I've always been drawn to flamenco but intimidated. The way you describe it makes it feel so accessible." },
    { user: users.maeve,  body: "Stomping grief into the earth. What a beautiful and necessary practice." },
    { user: users.cosima, body: "We can do this in the garden! The stone patio would be perfect for footwork." }
  ]

seed_post cohorts.european_sisters,
  author: users.lina, pinned: false, time_offset: post_base_time + 48.hours,
  body: "Question for the group: how are we handling travel to Florence? I was thinking of taking the train from Berlin and could coordinate with anyone coming from central or northern Europe.\n\nThe route through the Alps is stunning and I'd love travel companions. We could make the journey part of the experience, maybe share a cabin on the overnight train.\n\nAlso, I found a wonderful organic market near the villa that's open Saturday mornings. Could be a lovely outing for anyone who arrives early.",
  comments: [
    { user: users.elara,  body: "I could fly to Berlin and we take the train together! That sounds wonderful." },
    { user: users.cosima, body: "The Saturday market is one of my favorites. I'll take anyone who wants to go." },
    { user: users.noor,   body: "I'm taking the train from Barcelona through the south of France. It's a beautiful ride along the coast." }
  ]

seed_post cohorts.european_sisters,
  author: users.cosima, pinned: false, time_offset: post_base_time + 60.hours,
  body: "I spent yesterday in my nonna's garden collecting herbs and thinking about all of you. She passed three years ago but her rosemary, sage, and thyme bushes are still thriving.\n\nShe used to say that every herb has a spirit and if you listen, they'll tell you how they want to be used. I learned everything I know about plant medicine from watching her hands.\n\nI'm drying bundles of her herbs to bring to Florence. It feels like the right way to honor her and to share her medicine with this circle.",
  comments: [
    { user: users.maeve, body: "What a beautiful tribute, Cosima. Your nonna's medicine will be with us in the circle." },
    { user: users.elara, body: "Ancestral plant wisdom passed through women's hands. This is exactly why we gather." },
    { user: users.lina,  body: "I got chills reading this. Thank you for sharing her legacy with us." },
    { user: users.noor,  body: "My abuela had the same relationship with her garden. These grandmothers are still teaching us." }
  ]

puts "Seeded posts with comments for all cohorts"

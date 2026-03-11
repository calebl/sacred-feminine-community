base_time = 3.days.ago

dm_threads = [
  {
    between: [users.luna, users.freya],
    messages: [
      { sender: users.luna,  body: "Freya, do you have that recipe for the postpartum tea blend?" },
      { sender: users.freya, body: "Yes! It's red raspberry leaf, nettle, oat straw, and a little rose petal." },
      { sender: users.luna,  body: "Thank you so much. My neighbor just had her baby and I want to make her a batch." },
      { sender: users.freya, body: "That's so sweet. Add a pinch of chamomile too if she's having trouble sleeping." },
      { sender: users.luna,  body: "Will do. You're the best." },
      { sender: users.freya, body: "Anytime, sister. Let me know how she likes it!" }
    ]
  },
  {
    between: [users.aria, users.willow],
    messages: [
      { sender: users.aria,   body: "Willow, I loved your movement piece at the last gathering." },
      { sender: users.willow, body: "Thank you, Aria! Your meditation at the end was so grounding." },
      { sender: users.aria,   body: "I was thinking we could collaborate on something. Movement and acupressure combined." },
      { sender: users.willow, body: "I would LOVE that. When can we meet to plan?" },
      { sender: users.aria,   body: "How about next Tuesday afternoon? I could come to Ashland." },
      { sender: users.willow, body: "Perfect. I'll make us lunch and we can brainstorm after." },
      { sender: users.aria,   body: "See you then!" }
    ]
  },
  {
    between: [users.elara, users.cosima],
    messages: [
      { sender: users.elara,  body: "Cosima, I'm so looking forward to the Florence gathering." },
      { sender: users.cosima, body: "Me too, Elara! I've been scouting locations around the city." },
      { sender: users.elara,  body: "Is there anything I can help with from here?" },
      { sender: users.cosima, body: "Actually, could you connect me with Maeve? I'd love to include some Celtic elements." },
      { sender: users.elara,  body: "Of course! I'll introduce you two." },
      { sender: users.cosima, body: "Wonderful. This is going to be such a rich weaving of traditions." }
    ]
  },
  {
    between: [users.admin, users.luna],
    messages: [
      { sender: users.admin, body: "Luna, just wanted to check in on the Spring Retreat logistics." },
      { sender: users.luna,  body: "Everything's on track! Venue is confirmed, meal plan is set." },
      { sender: users.admin, body: "Great. Do you need me to send out any reminders to the group?" },
      { sender: users.luna,  body: "That would be helpful. Maybe a reminder about arrival times and what to bring?" },
      { sender: users.admin, body: "I'll draft something tonight and send it out tomorrow." },
      { sender: users.luna,  body: "Thank you for all your support with this." }
    ]
  }
]

dm_threads.each do |thread|
  conversation = Conversation.between(thread[:between][0], thread[:between][1])

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

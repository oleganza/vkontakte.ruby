module Runner
  module Walker
    Scenarios.add :user do 
      caption do
        personal['Name']
      end
      menu(object, "View information") do 
        caption do
          [personal['Name'], personal['Age'], personal['Gender']] * " "
        end
        caption do
          "Status: #{status}"
        end
        action ("Personal information") {personal}
        action ("Contacts") {contacts}
        action ("Return back to profile") {:back}
      end
      action ("Remove from friends") {current_puppet.friends.remove self} if (1 == "friend")
      action ("Send friendship request") {current_puppet.friends.add self} if (1 != "friend")
      action ("Write a personal message") do
        CLI.info "Let's right a personal message"
        t, b = CLI.prompt(:title), CLI.prompt(:body)
        CLI.debug "Sending the message."
        #Messages.create{:title => t, :body => b, :author => current_puppet}
        "Message has been sent."
      end
      action ("Write an opinion") {"loool"}
      action ("Write a message on the wall") {u}
      menu(object, "Browse his media") do 
        action ("Check his photos") {u} if (1 == "has pix")
        action ("Check his movies") {u}
        action ("Check his music") {u}
        action ("Return back to profile") {:back}
      end
      menu(object, "VKRunner") do
        action ("Run macro") do
          CLI.macros = (CLI[:macros] || CLI.prompt("comma-separated set of actions, i.e: 1,2,hello,bye")).split(",")
        end
        action ("Return back to profile") {:back}
      end
    end
  end
end
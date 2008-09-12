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
      
      menu(object, "Write him...") do
        action ("Writer him a message") do
          CLI.info "Let's right a personal message"
          t, b = CLI.prompt(:title), CLI.prompt(:body)
          CLI.debug "Sending the message."
          #Messages.create{:title => t, :body => b, :author => current_puppet}
          "Message has been sent."
        end
        action ("Writer him something on the wall") {"Yada-yada, Ima writin on teh wall"}
        action ("Writer him an anonymous opinion") {"loool"}
        action ("Return back to profile") {:back}
      end
      menu(object, "Browse his media...") do 
        action ("Browse his photos") {u}
        action ("Browse his movies") {u}
        action ("Browse his music") {u}
        action ("Browse his notes") {u}
        action ("Return back to profile") {:back}
      end
      menu(object, lambda{"My... [#{$user.personal['Name']}]"}) do
        action ("My profile") {$user}
        action ("My messages") {u}
        action ("My photos") {u}
        action ("Return back to profile") {:back}
      end
      menu(object, "Runner thingies") do
        action ("Run macro") do
          CLI.macros = (CLI[:macros] || CLI.prompt("comma-separated set of actions, i.e: 1,2,hello,bye")).split(",")
        end
        action ("Return back to profile") {:back}
      end
    end
  end
end
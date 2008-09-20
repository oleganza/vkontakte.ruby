module Runner
  module Walker
    
    class Item
      attr_writer :title
      
      def title
        Proc === @title ? @title.call : @title
      end
    end
    
    class Action < Item
      attr_accessor :logic
      def initialize(title, &blk)
        @title = title
        @logic = blk
      end
    end
  
    class Scenarios
      @scenarios = {}
    
      def self.add(cls, &blk)
        @scenarios[cls.to_sym] = blk
      end
    
      def self.for(which)
        (find_for(which) || find(which))
      end
    
      def self.find(which)
        @scenarios[which.to_sym]
      end
    
      def self.find_for(model)
        find model.class.name.split("::").last.downcase
      end
    end

    class Menu < Item
      attr_accessor :items, :scenarios, :object, :blk
      
      def initialize(object, title = nil, &blk)
        @blk, @object, @title = (self.class === object) ? [object.blk, object.object, object.title] : [blk, object, title]       
        @items = []       
        instance_eval(&(@blk || Scenarios.find_for(@object)))
        self
      end
    
      def caption(text = nil, &blk)
        @items << (blk ? @object.instance_eval(&blk) : text)
        self
      end
    
      def action(title, &blk)
        @items << Action.new(title, &blk)
        self
      end
    
      def menu(*args, &blk)
        @items << Menu.new(*args, &blk)
        self
      end
    
      def choose(i)
        set_history = false
        
        i = i.to_i - 1
        if (i == -1)
          result = @object
        else
          result = (@items - @items.grep(String))[i]
          result = @object.instance_eval(&result.logic) if (Action === result)
          if result == :back 
            result = CLI.stack.slice!(-1)
          else
            if [String, Symbol, Hash, Array].any?{|c| c === result}
              CLI.print(result) 
              result = self
            else
              set_history = true
            end
          end
        end
        
        CLI.queued = result
        CLI.stack << self if (set_history)
      end
    
      def to_select
        menu = @items
        i = 0
        menu.map {|item| String === item ? item : CLI.colorize("#{i+=1}) #{item.title}") } * "\n"
      end
    end
  end
end

require File.join(File.dirname(__FILE__), '/scenarios/user')
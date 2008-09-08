module Runner
  class Declaration < OpenStruct
    def initialize(command, description = nil, options = {}, &condition)
      super({
        :command => command.to_sym, #Command itself, i.e. "delay", it'll create --delay & -d
        :shorthand => command.to_s.slice(0, 1),
        :description => description, 
        :condition => condition, #Use this block to invalidate user input
        :arguments => Array === options ? options : [], #You may pass a class as a validation
        :default => nil, 
        :tail => false  #Should program exit if it gets this option? Useful for --help or --version
      }.merge(Hash === options ? options : {}))
    end
  end

  class Input 
    attr_accessor :declarations, :messages
  
    def initialize(messages = {}, &blk)
      self.declarations = []
      self.messages = {
        :invalid => "%s Try something else?",
        :error => "Error: %s"
      }.merge(messages)
      instance_eval(&blk) if blk
    end 
  
    def declare(*args, &block)
      self.declarations << Declaration.new(*args, &block)
    end
  
    private    
    def declaration_of(what)
      declarations.find{|d| d.command == what}
    end

    def validate(value, what)
      what = declaration_of(what) if (Symbol === what)
      if (what.condition && (result = what.condition[value]) && !result.nil?)
        if String === result
          raise what && what.tail ? StandardError : ArgumentError, result 
        end
      end
    end

    def handle(format = :error)
      begin
        yield
      rescue ArgumentError => msg
        CLI.warn(self.messages[format] % msg.message) if self.messages[format]
        :retry
      rescue => msg
        CLI.info msg.message
        exit
      end
    end
  
    def ask(what, explaination = nil)
      CLI.info(explaination) if explaination
      value = ""
      while (!value || (value =~ /^\s*$/) || handle(:invalid) {validate(value, what)} == :retry)
        value = request
      end
      value
    end
  
    def request
      print "> "
      if macro = CLI.next_macro
        print "macro","\n"
        macro
      else
        CLI.gets
      end
    end
  end

  class Options < Input
    attr_accessor :values, :options
  
    def initialize(messages = {}, argv = [], &blk)
      if (Array === messages)
        argv = messages
        messages = {}         
      end
      super(messages, &blk)
      self.values = {}
    
      return if argv.empty?
      handle do
        parse_argv(argv)
      end
    
      self
    end
  
    def []=(what, with)
      self.values[what] = with
    end
  
    def [](what)
      get(what) || declaration_of(what).default || ask(what, "Please enter #{declaration_of(what).description}.")
    end
  
    def get(what)
      self.values[what]
    end
  
    private
    def parse_argv(args)
      self.options = OptionParser.new do |o|
        o.banner = "Usage: #{Name} [options]"
        self.declarations.each do |d|
          o.send(d.tail ? :on_tail : :on, "-#{d.shorthand}", !d.tail && "--#{d.command} [#{d.default || d.command.to_s.upcase}]", d.description, *d.arguments) do |v|
            handle { validate(v, d) }
            self[d.command] = v
          end
        end
      end
      self.options.parse!(args)
    end
  
    def ask(what, explaination = nil)
      self[what] = super(what, explaination)
    end
  end

  class Actions < Input
    def method_missing(what, *args)
      action = declaration_of(what)
      return super unless action
      ask(action, Proc === action.description ? action.description[*args] : action.description % args.first)
    end
  
    def notify(level, message)
      CLI.send(level, message)
    end
  end
end


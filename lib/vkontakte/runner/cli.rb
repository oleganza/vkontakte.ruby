module Runner
  module CLI
    class << self
      attr_accessor :options, :actions, :logger, :queued, :macros, :stack
      
      def set_logger(*args, &blk)
        @logger = Logger.new(*args, &blk)
        formatter = Logger::Formatter.new
        formatter.instance_eval do
          def call(severity, datetime, progname, msg)
            @last_severity ||= severity
            str = ((@last_severity != severity) ? "\n" : "") + "  " + msg2str(msg).gsub("\n", "\n  ") + "\n"
            @last_severity = severity
            str
          end
        end
        @logger.formatter = formatter
      end
    
      def set_options(*args, &blk)
        @options = Options.new(*args, &blk)
      end

      def set_actions(*args, &blk)
        @actions = Actions.new(*args, &blk)
      end
    
      def set_tails
        Tails.new(*args, &blk)
      end
  
      def method_missing(m, *args, &blk)
        obj = [:fatal, :error, :warn, :info, :debug].include?(m) ? @logger : @actions
        obj.send(m, *args, &blk)
      end
  
      def [](what)
        @options[what]
      end
  
      def []=(what, with)
        @options[what, with]
      end
    
      def gets
        Object.send(:gets).chomp
      end
      
      def asyncronous(message = nil)
        Thread.new do
          yield
          debug message if message          
        end
      end
      
      def print(obj)
        msg =  
        case obj
        when String
          obj
        when Symbol
          obj.to_s
        when Array
          obj * ", "
        when Hash
          size = obj.keys.max{|a, b| a.to_s.size <=> b.to_s.size}.size
          obj.map do |k, v|
            k.to_s.rjust(size) + ": " + v.to_s
          end.join("\n")
        end
        CLI.info msg + "\n"
      end
      
      def menu_for(menu)
        menu = Walker::Menu.new(menu)
        menu.choose CLI.menu(menu)        
      end
      
      def queued
        q = @queued; @queued = nil; q
      end
      
      def next_macro
        @macros.slice!(0) if @macros && Array === @macros
      end  
    end
    
    self.macros = []
    self.stack = []
  end
end
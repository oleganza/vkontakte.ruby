module Runner
  module CLI
    class << self
      attr_accessor :options, :actions, :logger, :queued, :macros, :stack, :color
      
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
          if obj.all?{|i| Array === i}
            sizes = (0..obj.first.size - 1).map do |i|
              obj.map{|o| o[i]}.max{|a, b| a.to_s.size <=> b.to_s.size}.size
            end
            obj.map do |columns|
              i = -1
              columns.map do |value|
                value.to_s.ljust(sizes[i+=1])
              end.join(" " * 3)
            end.join("\n")
          else
            obj * ", "
          end
        when Hash
          return print(obj.to_a)
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
      
      def colorize(text)
        CLI[:color] && "\e[#{CLI[:color]}m#{text}\e[0m"
      end
    end
    
    self.macros = []
    self.stack = []
  end
end
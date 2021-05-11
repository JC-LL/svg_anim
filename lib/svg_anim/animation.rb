require "nokogiri"
require_relative "template"

module SVG

  class Animation
    attr_reader :width, :height
    attr_reader :layers
    attr_reader :current_frame
    attr_reader :background
    attr_accessor :dir
    attr_accessor :framerate
    attr_accessor :simple_objects
    attr_accessor :symbols,:instances

    def initialize(name,width, height)
      puts "designing animation : '#{name}'"
      @film_name=name
      @width= width
      @height= height
      @symbols=[]
      @instances=[]
      @simple_objects=[]
      @max_frame=0
      @background=[]
      @frame_callbacks={}
      @start_time=Time.now
    end

    def frame(n,&block)
      puts "defining frame #{n}"
    end

    def add_background svg_filename
      puts "add background      : #{svg_filename}"
      @background=read_svg(svg_filename).to_s
    end

    def create_background color="white"
      @background="<rect width=\"#{@width}\" height=\"#{@height}\" id=\"background\" fill=\"#{color}\"/>"
    end

    def read_svg svg_filename
      raise "file '#{svg_filename}' not found " unless File.exist?(svg_filename)
      xml=Nokogiri.parse(IO.read(svg_filename))
      xml.xpath('//xmlns:g').first
    end

    def add_symbol symbol
      @symbols << symbol
    end

    def instanciate_as symbol,id
      instance=SymbolInstance.new(id,symbol)
      @symbols << symbol
      @symbols.uniq!
      @instances << instance
      instance
    end

    def add(obj)
      case obj
      when SVG::Symbol
        @symbols << obj
      else
        @simple_objects << obj
      end
      obj
    end

    def frame(n,&block)
      fill_upto(n)
      @frame_callbacks[n]=[]
      @frame_callbacks[n] << block
      @max_frame=n
    end

    def fill_upto n
      ary=@frame_callbacks[@max_frame]
      (@max_frame+1..n-1).each do |f|
        @frame_callbacks[f]=[]
      end
    end

    BAR_SIZE=50

    def create
      Dir.rmrf(@film_name) rescue nil
      Dir.mkdir(@film_name) rescue nil
      @nb_frames=@frame_callbacks.size
      puts "#frames ".ljust(20)+ ": "+@nb_frames.to_s
      @nb_frames.times do |n|
        percent=100.0*(n+1)/@nb_frames
        printf("\rcreating            : %3d %%", percent.round(2))
        render(n)
      end
      puts
    end

    def frame_id(frame, digits)
      sprintf("%.#{digits}d", frame)
    end

    def render(frame)
      @frame_callbacks[frame].each{|callback| callback.call(frame)} if @frame_callbacks[frame]
      parameters={width:width,height:height,background:background}
      parameters.merge!(symbols:symbols,instances:instances)
      parameters.merge!(simple_objects:simple_objects)
      @current_frame=frame #for ERB
      @digits = @max_frame.to_s.size
      file = frame_id(frame, @digits)
      filename = File.join(@film_name, file)
      File.open("#{filename}.svg", "w") do |file|
        file.write(Template.new.apply(parameters))
      end
    end

    def objbinding
      binding
    end

    def encode encoder=:ffmpeg
      print "encoding".ljust(20)+": "
      @target="#{@film_name}/#{@film_name}.mp4"
      system("rm -rf  #{@target}")
      th=Thread.new do
        estimated_time_per_frame=38.0/3000
        @nb_frames.times do |n|
          percent=100.0*(n+1)/@nb_frames
          printf("\rencoding            : %3d %%", percent.round(2))
          sleep(estimated_time_per_frame)
        end
      end
      system "ffmpeg -hide_banner -loglevel error -framerate 25 -i #{@film_name}/%0#{@digits}d.svg -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p #{@target}"
      printf("\rencoding            : %3d %%", 100)
      th.kill
      puts
      puts "saved as".ljust(20)+": "+@target
      execution_time = (Time.now - @start_time).round(2)
      puts "process took        : #{execution_time}s"
    end

    def clean
      puts "cleaning".ljust(20)+": done"
      system("rm -rf  #{@target}/*.svg")
    end

    def run looping=1
      looping=looping==:forever ? "0" : looping
      puts "running"
      system "mplayer -loop #{looping} #{@target} > /dev/null 2>&1"
    end
  end
end

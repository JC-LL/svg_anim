module SVG

  Point=Struct.new(:x,:y)

  class Object
    attr_accessor :attrs
    def initialize(name, attrs={})
      @name = name
      @attrs = attrs
      @attrs[:transform]=""
      @contents = []
    end

    def [](key)
      @attrs[key]
    end

    def []=(key, value)
      @attrs[key] = value
    end

    def add(obj)
      @contents.push(obj)
      self
    end

    def render(frame=0)
      attrs = @attrs.map{|k, v| %Q{#{k}="#{v}"} }.join(' ')
      body = @contents.map{|obj| obj.render(frame) }.join("\n")
      return %Q{<#{@name} #{attrs}>#{body}</#{@name}>}
    end

    def move_by(xd, yd)
      raise "Has no coordinates" unless @attrs[:x] && @attrs[:y]
      @attrs[:x] +=xd
      @attrs[:y] +=yd
      return self
    end

    def move_to(x, y)
      @attrs[:x] = x
      @attrs[:y] = y
      return self
    end

    #transform="rotate(45)"
    def rotate angle
      @attrs[:transform]+="rotate(#{angle} #{attrs[:x]} #{attrs[:y]})"
    end

    # matrix  a b c d e f
    # a c e
    # b d f
    # 0 0 1

    def scale val
      #@attrs[:transform]+="scale(#{val})"
      #scale
      a=val
      b=0
      c=0
      d=val
      e=0
      f=0
      @attrs[:transform]+="maxtix(#{a},#{b},#{c},#{d},#{e},#{f})"
    end
  end

  class Group < SVG::Object
  end

  class Symbol < SVG::Object
    attr_accessor :name,:group

    def initialize name,group=nil
      super("symbol")
      @name=name
      @group=group
    end

    def self.from filename
      id=File.basename(filename,".svg")
      doc=Nokogiri.parse(IO.read(filename))
      elements=doc.children.select{|child| child.is_a? Nokogiri::XML::Element}
      svg=elements.find{|e| e.name=="svg"}
      svg_text=svg.children.map{|c| c.to_xml}.join("\n")
      puts "creating symbol     : #{id.capitalize!} from #{filename}"
      SVG::Symbol.new(id,svg_text)
    end

    def render frame=0
      code=Code.new
      code << "<symbol id=\"#{@name}\">\n"
      code.indent=2
      code << group
      code.indent=0
      code << "</symbol>"
      code.finalize
    end

    private
    def Symbol.load_groups filename
      raise "file '#{filename}' not found" unless File.exist?(filename)
      xml=Nokogiri.parse(IO.read(filename))
      groups=xml.xpath('//xmlns:g')
      return groups
    end

    def Symbol.load_group_with_id(filename,id)
      load_groups(filename).each do |group|
        if val=group.attributes["id"]
          return group if val.to_s==id
        end
      end
      nil
    end
  end

  class SymbolInstance < SVG::Object
    attr_accessor :id
    def initialize id, symbol
      @symbol=symbol
      @id=id
      attrs={}
      attrs[:x] = 0
      attrs[:y] = 0
      puts "creating instance   : #{@id} of #{symbol.name}"
      super("id",attrs)
    end

    def render frame=0
      code=Code.new
      code << "<use id=\"#{@id}\" xlink:href=\"\##{@symbol.name}\" x=\"#{self[:x]}\" y=\"#{self[:y]}\" transform=\"#{self[:transform]}\"/>"
      code
    end
  end

  class Rect < SVG::Object
    def initialize(x=0, y=0, width=100, height=100, attrs={})
      attrs[:x] = x
      attrs[:y] = y
      attrs[:width] = width
      attrs[:height] = height
      super(:rect, attrs)
    end

    def rotate angle
      x=attrs[:x]+attrs[:width]/2
      y=attrs[:y]+attrs[:height]/2
      @attrs[:transform]="rotate(#{angle} #{x} #{y})"
    end
  end

  #<circle fill="greenyellow" r="20" cx="25" cy="70"/>
  class Circle < SVG::Object
    def initialize(x=0, y=0, r=5, attrs={})
      attrs[:cx] = x
      attrs[:cy] = y
      attrs[:r]=r
      super(:circle, attrs)
    end

    def move_by(xd, yd)
      raise "Has no coordinates" unless @attrs[:cx] && @attrs[:cy]
      @attrs[:cx]+=xd
      @attrs[:cy]+=yd
      return self
    end

    def move_to(x, y)
      @attrs[:cx] = x
      @attrs[:cy] = y
      return self
    end
  end
  #<text x="250" y="150"
  #      font-family="Verdana"
  #      font-size="55">
  #  Bonjour tout le monde!
  #</text>

  class Text < SVG::Object
    def initialize(x=0, y=0, text="?", attrs={})
      attrs[:x] = x
      attrs[:y] = y
      attrs[:"font-family"]||="Verdana"
      attrs[:"font-size"]  ||="55"
      super(:text, attrs)
      add(text)
    end

    def render
      attrs = @attrs.map{|k, v| %Q{#{k}="#{v}"} }.join(' ')
      code=Code.new
      code << "<text #{attrs}>"
      code.indent=2
      code << "#{@contents.first}"
      code.indent=0
      code << "</text>"
      code.finalize
    end
  end
end

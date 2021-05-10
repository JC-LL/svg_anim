require_relative "code"

class Template

  attr_accessor :params

  def initialize
    @params={}
  end

  def apply params
    @params=params
    code=Code.new
    code << "<svg xmlns:xlink=\"http://www.w3.org/1999/xlink\" xmlns=\"http://www.w3.org/2000/svg\" width=\"#{params[:width]}\" height=\"#{params[:height]}\">"
    code.indent=2
    code << gen_background()
    code << gen_defs()
    code.newline
    code << gen_instances()
    code << gen_simple_objects()
    code.indent=0
    code << "</svg>"
    code.finalize
  end

  def gen_background
    @params[:background]
  end

  def gen_defs
    code=Code.new
    code << "<defs>"
    code.indent=2
    @params[:symbols].each do |sym|
      code << sym.render
    end
    code.indent=0
    code << "</defs>"
    code
  end

  def gen_instances
    code=Code.new
    code.indent=2
    @params[:instances].each do |inst|
      code << inst.render
    end
    code.indent=0
    code
  end

  def gen_simple_objects
    code=Code.new
    code.indent=2
    @params[:simple_objects].each do |obj|
      code << obj.render
    end
    code.indent=0
    code
  end


end

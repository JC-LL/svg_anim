require_relative "../../lib/svg_anim/ast.rb"
require_relative "../../lib/svg_anim/animation.rb"

include Math

WIDTH,HEIGHT=800,600

film=SVG::Animation.new("group_1",WIDTH,HEIGHT)
film.add_background "background.svg"
film.add rect=SVG::Rect.new(10,10,100,50,fill:"purple",stroke:"black")
film.add text1=SVG::Text.new(200,100,"hello svg!",:"font-size" => 20)

180.times do |t|
  film.frame(t) do |t|
    text1.rotate(t*4) #degres !
    rect.move_by 4,4
    rect.rotate t*10
  end
end

film.create
film.encode
film.run

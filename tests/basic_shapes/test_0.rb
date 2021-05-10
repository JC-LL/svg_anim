require_relative "../../lib/svg_anim/ast.rb"
require_relative "../../lib/svg_anim/animation.rb"

include Math

WIDTH,HEIGHT=800,600

film=SVG::Animation.new("test_1",WIDTH,HEIGHT)
film.add_background "background.svg"
film.add rect=SVG::Rect.new(10,10,100,50,fill:"purple",stroke:"black")

NB_CIRCLES_OUT=30
NB_CIRCLES_IN =10
RAYON_1=200
RAYON_2=100
CENTER=SVG::Point.new(WIDTH/2,HEIGHT/2)


circles_out=NB_CIRCLES_OUT.times.map{|i|
  x=CENTER.x+RAYON_1*sin((2*PI/NB_CIRCLES_OUT)*i)
  y=CENTER.y+RAYON_1*cos((2*PI/NB_CIRCLES_OUT)*i)
  film.add SVG::Circle.new(cx=x,cy=y,r=10,fill:"red",stroke:"black")
}

circles_in=NB_CIRCLES_IN.times.map{|i|
  x=CENTER.x+RAYON_2*sin((2*PI/NB_CIRCLES_IN)*i)
  y=CENTER.y+RAYON_2*cos((2*PI/NB_CIRCLES_IN)*i)
  film.add SVG::Circle.new(cx=x,cy=y,r=20,fill:"orange",stroke:"black")
}


180.times do |t|
  film.frame(t) do |t|
    rect.move_by 5,5
    rad=(PI/180)*t/2
    circles_out.each_with_index{|c,i|
      x=CENTER.x+RAYON_1*sin((2*PI/NB_CIRCLES_OUT)*i+rad)
      y=CENTER.y+RAYON_1*cos((2*PI/NB_CIRCLES_OUT)*i+rad)
      c.move_to(x,y)
    }
    rad*=8
    circles_in.each_with_index{|c,i|
      x=CENTER.x+RAYON_2*sin((2*PI/NB_CIRCLES_IN)*i+rad)
      y=CENTER.y+RAYON_2*cos((2*PI/NB_CIRCLES_IN)*i+rad)
      c.move_to(x,y)
    }
  end
end

film.create
film.encode
film.run

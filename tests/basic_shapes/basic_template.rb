require "../../lib/svg_anim"

film=SVG::Film.new("example",800,600)
film.add_background "background.svg"
film.add rect=SVG::Rect.new(10,10,100,50,fill:"purple",stroke:"black")

180.times do |t|
  film.frame(t) do |t|
    rect.rotate(2*t) #degres !
    rect.move_by 4,4
  end
end

film.create
film.encode #using ffmpeg
film.run    # using mplayer

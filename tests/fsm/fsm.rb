require_relative "../../lib/svg_anim/ast.rb"
require_relative "../../lib/svg_anim/animation.rb"

WIDTH,HEIGHT=1200,800

film=SVG::Animation.new("fsm_0",WIDTH,HEIGHT)
film.create_background "lightgrey"
film.add symb_fsm=SVG::Symbol.from("fsm.svg")
film.add fsm     =SVG::SymbolInstance.new("fsm",symb_fsm)

fsm.scale(2)
film.frame(0) do
  fsm.move_to 50,50
end

film.frame(3) do
end

film.frame(6) do
end

film.frame(9) do
end

film.create
film.encode
film.run

require_relative "../../lib/svg_anim/ast.rb"
require_relative "../../lib/svg_anim/animation.rb"

include Math

WIDTH,HEIGHT=1200,800
SQUARE_SIZE=50
DELTA_X=5
DELTA_Y=5
squares=[]

film=SVG::Animation.new("chess_0",WIDTH,HEIGHT)
film.add_background "background_grey.svg"

# prepare chess board
('a'..'h').each_with_index do |col,colnum|
  lx=(colnum+1)*(SQUARE_SIZE)+SQUARE_SIZE*0.5-DELTA_X
  ly=SQUARE_SIZE*9+SQUARE_SIZE/2
  film.add letter=SVG::Text.new(lx,ly,col, :"font-size" => 20,fill:"greenyellow")
  lx=SQUARE_SIZE*0.5
  (1..8).each do |row|
    ly=SQUARE_SIZE*row+SQUARE_SIZE/2+DELTA_Y
    film.add letter=SVG::Text.new(lx,ly,9-row, :"font-size" => 20,fill:"greenyellow")
    color=((colnum+row) % 8).even? ? "tan" : "darkolivegreen" # or "saddlebrown"
    x=(colnum+1)*SQUARE_SIZE
    y=(9-row)*SQUARE_SIZE
    squares << square=SVG::Rect.new(x,y,SQUARE_SIZE,SQUARE_SIZE,fill:color)
    film.add square
  end
end

scale=2
['w','b'].each do |color|
  ['p','r','n','b','q','k'].each do |piece|
    name="#{piece}#{color}"
    film.add_symbol symbol=SVG::Symbol.from("#{name}_45.svg")
    y=(color=="b") ? 1*SQUARE_SIZE : 8*SQUARE_SIZE
    case piece
    when 'r'
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 1*SQUARE_SIZE,y
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 8*SQUARE_SIZE,y
    when 'n'
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 2*SQUARE_SIZE,y
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 7*SQUARE_SIZE,y
    when 'b'
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 3*SQUARE_SIZE,y
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 6*SQUARE_SIZE,y
    when 'q'
      film.add piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 4*SQUARE_SIZE,y
    when 'k'
      film.add @king=piece=SVG::SymbolInstance.new(name,symbol)
      piece.scale(scale)
      piece.move_to 5*SQUARE_SIZE,y
    when 'p'
      (1..8).each do |i|
        film.add pawn=SVG::SymbolInstance.new(name,symbol)
        pawn.scale(scale)
        y=(color=="b") ? 2*SQUARE_SIZE : 7*SQUARE_SIZE
        pawn.move_to i*SQUARE_SIZE,y
      end
    end
  end
end

7.times do |t|
  film.frame(t*30) do
    dx=rand(-1..1)*SQUARE_SIZE
    dy=1*SQUARE_SIZE
    @king.move_by dx,dy
  end
end
film.create
film.encode
film.run

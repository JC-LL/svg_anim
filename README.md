# Animator : a Ruby script for offline SVG animation

## Introduction

Animator is a simple utility to animate SVG drawings _offline_. Offline means that the animation will not appear in your browser, as for classical SVG animations. Instead, Animator create a _film_ using FFMPEG. It will instantaneously run it using Mplayer. This works like a charm on Linux. For SVG creation I only use Inkscape here.

## How to instal
gem install animator

## How to use

Let us create a rectangle that moves from top left to bottom right (roughly), and also rotates on itself. We also put a background using a plain external SVG :
```ruby
  require "svg_anim"

  film=SVG::Animation.new("example",800,600)
  film.add_background "background.svg" # some background are provided in the test dir.
  film.add rect=SVG::Rect.new(10,10,100,50,fill:"purple",stroke:"black")

  180.times do |t|
    film.frame(t) do |t|
      rect.rotate(2*t) #degres !
      rect.move_by 4,4
    end
  end

  film.create
  film.encode # using ffmpeg
  film.run    # using mplayer
```
As shown, this script creates 180 frames. A block is passed to the frame method : under the hood, it is registered as a callback and run later, when __create__ method is called.


## technical features

* **support of classical SVG shapes** :
  - rectangle
  - ellipses
  - circle
  - text
- **how to create a background** : create a rectangle of the proper size. **Warning** : check in Inkscape that the view port is correctly set to the same dimension as the background itself (800x600 for instance). If not set properly, your rectangle background may appear smaller than expected and will not act as background.
* **creating and animating _symbols_**
* animating external SVG (icons, shapes etc) :


## How fast it it ?
Animator is written in Ruby, which is fast enough to manage te creation of such SVG images or their assembly. The real magic comes from FFMPEG. The estimation on my Linux box is rougly 80 frames/s.

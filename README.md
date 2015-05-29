## Ustinator

This is a processing sketch to mimic some of the awesome works of [Ustina Yakovleva](http://ustina-yakovleva.isoverse.us/work)

![Example Image](http://img.isoverse.us/site_static/df5f65e77f0149f190056a2efa3e0bb3/ustina-yakovleva/works/other%20works/black%20ink%20on%20canvas%2050x60sm.jpg?w=500)

### Usage

Load up the sketch in [Processing](http://processing.org) and run it. Left-click to add a few helper points, right-click when you're done. A "worm" should appear. You can draw more "worms" on top of each other.

### How it works

The sketch takes the helper points and generates spline points in between them. For each of those points, a "segment" of lines is drawn that is basically a half-circle of random radius in the (negative?) Z plane. Between segments, the lines are connected, while lenghtening and displacing them differently to give it the look of connected segments.    

### TODO

- clean up
- make generational parameters configurable
- extract a `Worm` class for easier anmation
- add some wobble animations to make it really scary

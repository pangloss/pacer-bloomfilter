# Pacer Bloomfilter plugin (pacer-bloomfilter)

This plugin adds set filtering using [bloom filters](http://en.wikipedia.org/wiki/Bloom_filter) to the [Pacer](https://github.com/pangloss/pacer) graph and streaming data processing library.

This plugin is also meant to serve as an example of how easy it is to build a plugin for Pacer.

## Usage

The bloomfilter method is added to the core route object in Pacer,
which means that it will be available to all routes. The method takes 2
arguments and a block:

- false_positive_probability: between 0 and 1 with a lower number
  indicating a lower chance of different keys being considered equal
- expected_count: the maximum number of elements you think will be added to the bloom filter. The more accurate this number is the more accurate your false_positive_probability will be.
- block: The block should map the elements that will be iterated over to
  a value that will be used by the filter. You should return a string.
  This block does not affect the actual output of the route.
  If no block is given, to_s on the element itself will used for the
  filter.

### Example

Map the vertices to names and then filter by name:

    graph.v[:name].bloomfilter(0.001, 10).except(['sam', 'bob']) 

    "steve" "gary"
    Total: 2
    => #<GraphV -> Obj(name) -> Obj-Bloom>

Wrong! There is no way to map the vertices to the name, all vertices
pass through:

    graph.v.bloomfilter(0.001, 10).except(['sam', 'bob']) 

    #<V[0]> #<V[1]> #<V[2]> #<V[3]>
    Total: 4
    => #<GraphV -> V-Bloom>

That's better. Here we tell the bloomfilter how to map the vertices to
the name field (we switched it to #only though just to get more mileage
out of the example):

    graph.v.bloomfilter(0.001, 10) { |v| v[:name] }.only(['sam', 'bob']) 

    #<V[0]> #<V[3]>
    Total: 2
    => #<GraphV -> V-Bloom>

And for completeness, the uniq method is pretty self explanitory I hope:

    graph.v[:type].bloomfilter(0.001, 10).uniq

    "band member"
    Total: 1
    => #<GraphV -> V-Bloom>

## Is it Fast?

I don't know. This plugin is currently only a proof of concept and has not been
optimized, profiled or benchmarked! If you want to spend a couple of
hours to make it blazing fast, I'll be quite impressed!

## Contributing to pacer-bloomfilter
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Darrick Wiebe. See LICENSE.txt for
further details.


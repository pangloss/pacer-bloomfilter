module PacerBloomFilter
  unless const_defined? :VERSION
    PATH = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    VERSION = File.read(PATH + '/VERSION').chomp

    $: << File.dirname(__FILE__)
    require File.dirname(__FILE__) + '/../vendor/java-bloomfilter.jar'
  end

  def self.reload!
    Dir[File.dirname(__FILE__) + '/**/*.rb'].each do |file|
      puts file
      load file
    end
    nil
  end
end

require 'pacer/pipe/bloomfilter_reject'
require 'pacer/filter/bloomfilter'


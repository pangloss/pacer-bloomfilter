module Pacer
  module Core
    module Route
      def bloomfilter(false_pos_prob, expected_count, opts = {}, &block)
        chain_route :filter => :bloom,
          :false_pos_prob => false_pos_prob,
          :expected_count => expected_count,
          :bloomfilter => opts[:bloomfilter],
          :block => block
      end
    end
  end

  module Filter
    module BloomFilter
      attr_accessor :false_pos_prob, :expected_count, :block, :bloomfilter

      def uniq
        @except ||= []
        @uniq = true
        self
      end

      def except(others)
        @except ||= []
        @except << others
        self
      end

      def only(others)
        @only ||= []
        @only << others
        self
      end

    protected

      def attach_pipe(pipe)
        pipe = except_pipe(pipe) if @except
        pipe = only_pipe(pipe) if @only
        pipe
      end

    private

      def except_pipe(pipe)
        bfp = Pacer::Pipes::BloomFilter::RejectPipe.new false_pos_prob, expected_count, sideline_pipe
        bfp.accumulate if @uniq
        prepare_pipe(bfp, @except, pipe)
      end

      def only_pipe(pipe)
        bfp = Pacer::Pipes::BloomFilter::SelectPipe.new false_pos_prob, expected_count, sideline_pipe
        prepare_pipe(bfp, @except, pipe)
      end

      def prepare_pipe(bfp, all_items, pipe)
        bfp.bloomfilter = bloomfilter if bloomfilter
        all_items.each do |items|
          if items.is_a? Enumerable
            bfp.addAll items
          else
            bfp.addAll [items]
          end
        end
        bfp.setStarts pipe if pipe
        bfp
      end

      def sideline_pipe
        if block
          Pacer::Route.pipeline Pacer::Route.empty(self).map(&block)
        end
      end
    end
  end
end

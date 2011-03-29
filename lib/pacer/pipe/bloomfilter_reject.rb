module Pacer
  module Pipes
    class SideliningPipe < AbstractPipe
      def initialize(pipe)
        super()
        @sideline = pipe
        @sidelineExpando = ExpandableIterator.new(java.util.ArrayList.new.iterator);
        @sideline.setStarts(@sidelineExpando);
      end

    protected

      def sidelineValue(value)
        if @sideline
          @sideline.reset
          @sidelineExpando.add value
          @sideline.next
        else
          value
        end
      rescue NativeException => e
        if e.cause.getClass == Pacer::NoSuchElementException.getClass
          nil
        else
          raise e
        end
      end
    end

    class BloomFilterReject < SideliningPipe
      import com.skjegstad.utils.BloomFilter
      field_accessor :starts

      def initialize(false_pos_prob, expected_count, sideline_pipe = nil)
        super(sideline_pipe)
        @filter = BloomFilter.new(false_pos_prob, expected_count)
      end

      def addAll(elements)
        @filter.addAll(elements)
      end

      def accumulate
        @accumulate = true
      end

    protected

      def processNextStart()
        while raw_element = starts.next
          value = sidelineValue(raw_element)
          unless @filter.contains? value.to_s
            @filter.add(value) if @accumulate
            return raw_element
          end
        end
      rescue NativeException => e
        if e.cause.getClass == Pacer::NoSuchElementException.getClass
          raise e.cause
        else
          raise e
        end
      end
    end

    class BloomFilterSelect < SideliningPipe
      import com.skjegstad.utils.BloomFilter
      field_accessor :starts

      def initialize(false_pos_prob, expected_count, sideline_pipe = nil)
        super(sideline_pipe)
        @filter = BloomFilter.new(false_pos_prob, expected_count)
      end

      def addAll(elements)
        @filter.addAll(elements)
      end

    protected

      def processNextStart()
        while raw_element = starts.next
          value = sidelineValue(raw_element)
          if @filter.contains? value.to_s
            return raw_element
          end
        end
      rescue NativeException => e
        if e.cause.getClass == Pacer::NoSuchElementException.getClass
          raise e.cause
        else
          raise e
        end
      end
    end

  end
end

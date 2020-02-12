class BerryTime
    include Comparable

    attr_reader :samples

    def initialize(samples = 0)
        @samples = samples
    end

    def -(time)
        case time
        when BerryTime
            return BerryDuration.new(@samples - time.samples)
        when BerryDuration
            return BerryTime.new(@samples - time.samples)
        end
    end

    def +(duration)
        case duration
        when BerryDuration
            return BerryTime.new(@samples + duration.samples)
        end
    end

    def <=>(time)
        return @samples <=> time.samples
    end

    def to_s
        return @samples.to_s
    end

end

class BerryDuration
    include Comparable

    attr_reader :samples

    def initialize(samples)
        @samples = samples
    end

    def -(time)
        case time
        when BerryDuration
            return BerryDuration.new(@samples - time.samples)
        end
    end

    def +(duration)
        case duration
        when BerryDuration
            return BerryDuration.new(@samples + time.samples)
        end
    end

    def <=>(time)
        return @samples <=> time.samples
    end

end
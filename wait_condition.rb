class WaitCondition
end

class TimeWaitCondition < WaitCondition

    attr_reader :time

    def initialize(time)
        @time = time
    end

end

class DurationWaitCondition < WaitCondition

    attr_reader :duration

    def initialize(duration)
        @duration = duration
    end

end

class EventWaitCondition < WaitCondition

    attr_reader :event

    def initialize(event)
        @event = event
    end

end

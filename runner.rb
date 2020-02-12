require 'fiber'

require_relative 'wait_condition'
require_relative 'times'

class BerryProcess

    def initialize(id, block, looping=false)
        @id = id
        @block = block
        @looping = looping
        @fiber = Fiber.new do
            begin
                if looping
                    loop(&block)
                else
                    block.call
                end
            rescue StandardError => e
                puts e
                puts e.backtrace
            end
        end
        @finished = (not @fiber.alive?)
    end

    # TODO: Define WITH_FX here and add it to the process's cache

    def finished?
        @finished
    end

    def resume
        condition = @fiber.resume
        return condition
    rescue FiberError => e
        @finished = true
        return nil
    end

    def advance_temporal_objects(duration)

    end

end

class BerryRunner

    attr_reader :global_time

    def initialize
        @global_time = BerryTime.new(0)
        @all_processes = {}
        @running_processes = []
        @queued_processes = []
        @queued_process_times = []
        @event_subscriptions = {}
        @running = false
    end

    def add_process(block, looping=false)
        id = @all_processes.size + 1
        process = BerryProcess.new(id, block, looping)
        @all_processes[id] = process
        @running_processes.push(id)
    end

    def run
        @running = true
        while @running
            tick
            sleep(0.01)
        end
    end

    def tick
        if @all_processes.empty?
            @running = false
            return
        end
        advance_processes
        poll_events
        advance_time
    end

    def advance_processes
        @running_processes.each do |process_id|
            process = @all_processes[process_id]
            if process.finished?
                @all_processes[process_id] = nil
            end
            condition = process.resume
            case condition
            when TimeWaitCondition
                raise "Not Yet Implemented"
                queue_process(process_id, condition.time)
            when DurationWaitCondition
                queue_process(process_id, @global_time + condition.duration)
            when EventWaitCondition
                raise "Not Yet Implemented"
                subscribe_process(process, condition.event)
            end
        end
        @running_processes = []
    end

    def poll_events
        # TODO:
    end

    def advance_time
        if @queued_processes.empty?
            @running = false
            return
        end

        next_time = @queued_process_times.first
        until @queued_process_times.empty? || (@queued_process_times.first != next_time)
            @queued_process_times.shift
            @running_processes.push(@queued_processes.shift)
        end

        duration = @global_time - next_time
        @running_processes.each do |process_id|
            process = @all_processes[process_id]
            process.advance_temporal_objects(duration)
        end

        @global_time = next_time
    end

    def queue_process(process_id, time)
        if time < @global_time
            raise "Waiting for time in the past"
        end
        i = @queued_process_times.index { |t| t > time } || @queued_process_times.size
        @queued_process_times.insert(i, time)
        @queued_processes.insert(i, process_id)
    end

    def subscribe_process(process, event)
        @event_subscriptions[event].push(process)
    end

end

module Berry

    @@runner = BerryRunner.new

    def self.runner
        return @@runner
    end

    module Track

        def self.new(&block)
            Berry.runner.add_process(block)
        end

        def self.loop(&block)
            Berry.runner.add_process(block, true)
        end

    end

end
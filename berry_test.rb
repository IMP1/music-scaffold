require_relative 'runner'

module VST
    
    instrument = const_set("DrumKit", Class.new)
    instrument.define_singleton_method("kick")     { return "drum-kit:kick" }
    instrument.define_singleton_method("high_hat") { return "drum-kit:high_hat" }
    instrument.define_singleton_method("snare")    { return "drum-kit:snare" }
    instrument.define_singleton_method("tom_high") { return "drum-kit:tom_1" }

    instrument = const_set("BassGuitar", Class.new)
    instrument.define_singleton_method("E") { |fret| return "bass-guitar:E+#{fret}" }
    instrument.define_singleton_method("A") { |fret| return "bass-guitar:A+#{fret}" }
    instrument.define_singleton_method("D") { |fret| return "bass-guitar:D+#{fret}" }
    instrument.define_singleton_method("G") { |fret| return "bass-guitar:G+#{fret}" }

    instrument = const_set("Piano", Class.new)
    instrument.define_singleton_method("key") { |note| return "piano:#{note}" }

end



def advance(time, units=:samples)
    SAMPLES_PER_SECOND = 1
    SECONDS_PER_MINUTE = 60
    case units
    when :samples, :sample
        condition = DurationWaitCondition.new(BerryDuration.new(time))
    when :seconds, :second, :s
        condition = DurationWaitCondition.new(BerryDuration.new(time * SAMPLES_PER_SECOND))
    when :minutes, :minute, :m
        condition = DurationWaitCondition.new(BerryDuration.new(time * SAMPLES_PER_SECOND * SECONDS_PER_MINUTE))
    end
    Fiber.yield condition
end


#==========#
#----------#
# - - - - -#
#----------#
#==========#

$OUTPUT = []

def scale(instrument, root_note, delay)
    [2, 4, 5, 7, 9, 11, 12].each do |offset|
        play(instrument.call(root_note + offset))
        advance(delay)
    end
end

def play(sample)
    time = Berry.runner.global_time.to_s
    $OUTPUT.push("#{time} :: #{sample}")
end

Berry::Track.loop do
    play(VST::DrumKit.high_hat)
    play(VST::DrumKit.kick)
    advance(1/4r)
    play(VST::DrumKit.high_hat)
    advance(1/4r)
    play(VST::DrumKit.high_hat)
    play(VST::DrumKit.snare)
    advance(1/4r)
    play(VST::DrumKit.high_hat)
    advance(1/4r)
end

# Berry::Track.loop do
#     with_fx(:reverb) do
#         play(VST::BassGuitar.E(3))
#         advance(0.4)
#     end
# end

Berry::Track.new do
    scale(VST::Piano.method(:key), 14, 4/10r)
end



puts "Running"
begin
    puts "Press CTRL + C to Stop"
    $stdout.flush
    Berry.runner.run
rescue Interrupt => e
    puts "Stopping"
end
puts
puts "Output:"
$stdout.flush
puts $OUTPUT
$stdout.flush
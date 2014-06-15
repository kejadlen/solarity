require 'fileutils'

require_relative 'sun_day'

module Solarity
  class Daemon
    attr_reader :buffer, :span, :interval, :lat, :long

    def initialize(buffer:, span:, interval:, lat:, long:)
      @buffer = buffer
      @span = span
      @interval = interval
      @lat = lat
      @long = long
    end

    def run
      init

      while true
        cleanup

        # event = next_event
        event = ((Time.now+5)..(Time.now+5+span))

        wait_for_event(event)

        take_time_lapse(event)
        process_time_lapse
        post_time_lapse

        exit
      end
    end

    def init
      FileUtils.mkdir(buffer)
    end

    def cleanup
      FileUtils.rm(Dir["#{buffer}/*"])
    end

    def wait_for_event(event)
      sleep(event.begin - Time.now)
    end

    def take_time_lapse(event)
      i = 0
      while event.cover?(Time.now)
        path = "%s/%03d.jpg" % [buffer, i]
        exit_status = system("imagesnap #{path}")
        fail 'Unable to take photo' unless exit_status
        sleep(interval)
        i += 1
      end
    end

    def process_time_lapse
      cmd = "ffmpeg -i #{buffer}/%03d.jpg -r 24 -vcodec mpeg4 -q:v 1 -s 640x480 #{buffer}/out.avi"
      exit_status = system(cmd)
      fail 'Unable to create video' unless exit_status
    end

    def post_time_lapse
    end

    def next_event
      today = SunDay.new(time: Time.now, lat: lat, long: long)
      tomorrow = SunDay.new(time: Time.now + 24*60*60, lat: lat, long: long)

      events = today.events + tomorrow.events
      events.map! {|e| ((e-span)..(e+span)) }

      events.find {|e| e.begin > Time.now }
    end
  end
end

if __FILE__ == $0
  # span: 60*60, # 1 hour
  # interval: 15, # 15 seconds
  Solarity::Daemon.new(
    buffer: File.expand_path('../buffer', __FILE__),
    span: 60,
    interval: 2,
    lat: 47.6097,
    long: 122.3331,
  ).run
end

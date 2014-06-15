require 'fileutils'

require_relative 'sun_day'

module Solarity
  class Daemon
    attr_reader :buffer, :calendar, :interval

    def initialize(buffer:, calendar:, interval:)
      @buffer = buffer
      @calendar = calendar
      @interval = interval
    end

    def run
      init

      while true
        cleanup

        event = calendar.next_event

        wait_for_event(event)

        take_time_lapse(event)
        process_time_lapse
        post_time_lapse

        exit
      end
    end

    def init
      FileUtils.mkdir(buffer)
    rescue Errno::EEXIST
      # Purposeful no-op
    end

    def cleanup
      FileUtils.rm(Dir["#{buffer}/*"])
    end

    def wait_for_event(event)
      until event.ongoing?
        sleep(interval)
      end
    end

    def take_time_lapse(event)
      i = 0
      while event.ongoing?
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
  end

  class Calendar
    ONE_DAY = 24*60*60

    attr_reader :span, :lat, :long

    def initialize(span:, lat:, long:)
      @span = span
      @lat = lat
      @long = long
    end

    def next_event(time=nil)
      time ||= Time.now
      today = SunDay.new(time: time, lat: lat, long: long)
      tomorrow = SunDay.new(time: time + ONE_DAY, lat: lat, long: long)

      events = today.events + tomorrow.events
      events.map! {|e| ((e-span)..(e+span)) }

      Event.new(events.find {|e| e.begin > time })
    end
  end

  class Event
    attr_reader :range

    def initialize(range)
      @range = range
    end

    def start_time
      range.begin
    end

    def stop_time
      range.end
    end

    def ongoing?(time=nil)
      time ||= Time.now
      range.cover?(time)
    end

    def over?(time=nil)
      time ||= Time.now
      stop_time < time
    end
  end
end

if __FILE__ == $0
  require 'ostruct'

  # calendar = Solarity::Calendar.new(
  #   span: 60*60, # 1 hour
  #   lat: 47.6097,
  #   long: 122.3331,
  # )
  calendar = OpenStruct.new(
    next_event: Solarity::Event.new(((Time.now+5)..(Time.now+5+60)))
  )
  Solarity::Daemon.new(
    buffer: File.expand_path('../buffer', __FILE__),
    calendar: calendar,
    interval: 2,
  ).run
end

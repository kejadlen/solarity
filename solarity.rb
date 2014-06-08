require 'fileutils'

require_relative 'sun_day'

module Solarity
  module Daemon
    BUFFER = File.expand_path('../buffer', __FILE__)
    # SPAN = 60*60 # 1 hour
    # INTERVAL = 15 # 15 seconds
    SPAN = 60
    INTERVAL = 2
    LAT = 47.6097
    LONG = 122.3331

    def self.run
      init

      while true
        cleanup

        # event = next_event
        event = ((Time.now+5)..(Time.now+5+SPAN))

        wait_for_event(event)

        take_time_lapse(event)
        process_time_lapse
        post_time_lapse

        exit
      end
    end

    def self.init
      # FileUtils.mkdir(BUFFER)
    end

    def self.cleanup
      FileUtils.rm(Dir["#{BUFFER}/*"])
    end

    def self.wait_for_event(event)
      # sleep(event.begin - Time.now)
      sleep(10)
    end

    def self.take_time_lapse(event)
      i = 0
      while event.cover?(Time.now)
        # path = "#{BUFFER}/#{Time.now.strftime('%Y%m%d%H%M%S.jpg')}"
        path = "%s/%03d.jpg" % [BUFFER, i]
        exit_status = system("imagesnap -q #{path}")
        fail 'Unable to take photo' unless exit_status
        sleep(INTERVAL)
        i += 1
      end
    end

    def self.process_time_lapse
      cmd = "ffmpeg -i #{BUFFER}/%03d.jpg -r 24 -vcodec mpeg4 -q:v 1 -s 640x480 #{BUFFER}/out.avi"
      exit_status = system(cmd)
      fail 'Unable to create video' unless exit_status
    end

    def self.post_time_lapse
    end

    def self.next_event
      today = SunDay.new(time: Time.now, lat: LAT, long: LONG)
      tomorrow = SunDay.new(time: Time.now + 24*60*60, lat: LAT, long: LONG)

      events = today.events + tomorrow.events
      events.map! {|e| ((e-SPAN)..(e+SPAN)) }

      events.find {|e| e.begin > Time.now }
    end
  end
end

if __FILE__ == $0
  Solarity::Daemon.run
end

module Solarity
  class SunDay
    # References:
    #   http://aa.quae.nl/en/reken/zonpositie.html
    #   http://en.wikipedia.org/wiki/Sunrise_equation
    #   http://users.electromagnetic.net/bu/astro/sunrise-set.php

    attr_reader :j_date, :l_w, :phi

    # @param time [Time]
    # @param l_w [Integer] west longitude in degrees
    # @param phi [Integer] north latitude in degrees
    def initialize(time: nil, l_w:, phi:)
      time ||= Time.now
      @j_date = time.to_datetime.ajd
      @l_w = l_w.to_f
      @phi = phi
    end

    def rise
      DateTime.jd(chronological_jd(j_rise))
    end

    def set
      DateTime.jd(chronological_jd(j_set))
    end

    # because Ruby's DateTime.jd method takes chronological Julian dates
    def chronological_jd(jd)
      jd + 0.5
    end

    ### Equations for sun event calculations

    # current julian cycle
    def n
      (j_date - 2451545.0009 - l_w/360).floor
    end

    # approximate solar noon
    def j_star
      2451545.0009 + l_w/360 + n
    end

    # solar mean anomaly
    def m
      j_2000 = 2451545
      (357.5291 + 0.98560028*(j_star - 2451545.0009)) % 360
    end

    # equation of center
    def c
      1.9148*sin(m) + 0.02*sin(2*m) + 0.0003*sin(3*m)
    end

    # ecliptical longitude
    def λ
      (m + 102.9372 + c + 180) % 360
    end

    # solar transit
    def j_transit
      j_star + 0.0053*sin(m) - 0.0069*sin(2*λ)
    end

    # declination of sun
    def 𝛿
      asin(sin(λ) * sin(23.45))
    end

    # hour angle
    def w_0
      # TODO Implement elevation? Add (-1.15*sqrt(elevation in feet)/60) to -0.83
      acos((sin(-0.83) - sin(phi)*sin(𝛿)) / (cos(phi)*cos(𝛿)))
    end

    # sunset
    def j_set
      2451545.0009 + (w_0+l_w)/360 + n + 0.0053*sin(m) - 0.0069*sin(2*λ)
    end

    # sunrise
    def j_rise
      j_transit - (j_set - j_transit)
    end

    ### Helpers for doing maths

    def acos(x)
      deg(Math.acos(x))
    end

    def asin(x)
      deg(Math.asin(x))
    end

    def cos(x)
      Math.cos(rad(x))
    end

    def sin(x)
      Math.sin(rad(x))
    end

    def rad(degree)
      (Math::PI * degree / 180) % (2*Math::PI)
    end

    def deg(radian)
      (180 * radian / Math::PI) % 360
    end
  end
end

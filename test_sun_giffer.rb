require 'minitest/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sun_giffer'

class TestSunGiffer < Minitest::Test
  def setup
    @time = Time.parse('1 April 2004 12:00 UTC')
    @l_w = -5
    @phi = 52
  end

  def test_t_transit
    assert_in_delta(11*60 + 45, SunGiffer.t_transit(l_w: @l_w, date: @time), 1)
    p SunGiffer.t_rise(l_w: @l_w, phi: @phi, date: @time).divmod(60)
  end

  def test_mean_anomaly
    assert_in_delta(87.1807, SunGiffer.mean_anomaly(date: @time), 0.01)
  end

  def test_l_sun
    assert_in_delta(10.1179, SunGiffer.l_sun(date: @time), 0.01)
  end

  def test_hour_angle
    assert_in_delta(97.4785, SunGiffer.hour_angle(phi: @phi), 0.01)
  end
end

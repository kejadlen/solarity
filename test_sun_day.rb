require 'minitest/autorun'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sun_day'
include Solarity

class TestSunDay < Minitest::Test
  attr_reader :sun_day

  def setup
    @sun_day = SunDay.new(
      time: Time.parse('1 April 2004 12:00 UTC'),
      lat: 52,
      long: -5
    )
  end

  # def test_seattle
  #   (1..7).each do |i|
  #     sun_day = SunDay.new(
  #       time: Time.parse("#{i} June 2014 22:28 UTC"),
  #       lat: 47.6097,
  #       long: 122.3331
  #     )
  #     puts "#{sun_day.rise.to_time.localtime}, #{sun_day.set.to_time.localtime}"
  #   end
  # end

  def test_sun_set
    assert_in_delta(
      DateTime.parse('1 April 2004 18:15 UTC'),
      sun_day.set,
      0.001
    )
  end

  def test_j_date
    assert_equal(2453097, sun_day.j_date)
  end

  def test_n
    assert_equal(1552, sun_day.n)
  end

  def test_m
    assert_in_delta(87.1807, sun_day.m, 0.05)
  end

  def test_c
    assert_in_delta(1.9142, sun_day.c, 0.01)
  end

  def test_λ
    assert_in_delta(12.0321, sun_day.λ, 0.05)
  end

  def test_𝛿
    assert_in_delta(4.7585, sun_day.𝛿, 0.05)
  end

  def test_w_0
    assert_in_delta(97.4785, sun_day.w_0, 0.01)
  end

  def test_j_transit
    assert_in_delta(2453096.9895, sun_day.j_transit, 0.01)
  end

  def test_j_set
    assert_in_delta(2453097.2606, sun_day.j_set, 0.01)
  end
end

module SunGiffer
  include Math
  extend self

  # Simplified assuming we're on the Earth and are looking for the Sun.
  #
  # Formulae taken from here: http://aa.quae.nl/en/reken/zonpositie.html
  #
  # Seattle: 47.6097° N, 122.3331° W

  # trise ≈ ttransit − H/15° ≈ 6h00m + lw/15° + 24 * (J₀ + J₁ sin M + J₂ sin 2 LSun) − (H₁ tan φ sin LSun + H₃ tan φ (3 + (tan φ)²) (sin LSun)³)/15° 
  #       = 6h01m + lw/15° + 7.6m sin M − 9.9m sin 2 LSun − (1h31m tan φ sin LSun + 2.2m tan φ (3 + (tan φ)²) (sin LSun)³ + ∆H/15°)
  def t_rise(l_w:, phi:, date:)
    t_transit(l_w: l_w, date: date) - hour_angle(phi: phi) / 15
  end

  # tset ≈ ttransit + H/15° ≈ 18h00m + lw/15° + 24 * (J₀ + J₁ sin M + J₂ sin 2 LSun) + (H₁ tan φ sin LSun + H₃ tan φ (3 + (tan φ)²) (sin LSun)³)/15°
  #      = 18h01m + lw/15° + 7.6m sin M − 9.9m sin 2 LSun + (1h31m tan φ sin LSun + 2.2m tan φ (3 + (tan φ)²) (sin LSun)³ + ∆H/15°)

  # ttransit ≈ 12h00m + lw/15° + 24 * (J₀ + J₁ sin M + J₂ sin 2 LSun)
  #          = 12h01m + lw/15° + 7.6m sin M − 9.9m sin 2 LSun
  def t_transit(l_w:, date:)
    p ((12*60 + 1) + 60*((l_w/15.0) % 1)).divmod(60)
    p 7.6*sin(rad(mean_anomaly(date: date)))
    p l_sun(date: date)
    p 9.9*sin(rad(2*l_sun(date: date)))
    p 7.6*sin(rad(mean_anomaly(date: date))) - 9.9*sin(rad(2*l_sun(date: date)))
    (12*60 + 1) + 60*((l_w/15.0) % 1) + 7.6*sin(rad(mean_anomaly(date: date))) - 9.9*sin(rad(2*l_sun(date: date)))
  end

  # M = M₀ + M₁*(J − J2000)
  # J2000 = 2451545
  def mean_anomaly(date:)
    j = date.to_datetime.ajd
    j_2000 = 2451545
    (357.5291 + 0.98560028 * (j - j_2000)) % 360
  end

  # Lsun = M + Π + 180°
  def l_sun(date:)
    (mean_anomaly(date: date) + 102.9372 + 180) % 360
  end

  # H = arccos((sin h₀ − sin φ sin δ)/(cos φ cos δ))
  # h₀ = -0.83
  # δSun = 4.7585°
  def hour_angle(phi:)
    phi = rad(phi)
    h_0 = rad(-0.83)
    delta = rad(4.7585)
    deg(acos((sin(h_0) - (sin(phi)*sin(delta)))/(cos(phi)*cos(delta))))
  end

  def rad(degree)
    (PI * degree / 180) % (2*PI)
  end

  def deg(radian)
    (180 * radian / PI) % 360
  end
end

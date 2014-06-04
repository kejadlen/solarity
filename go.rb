# This is just a test script to try out taking photos, making videos, etc.

$LOAD_PATH.unshift '.'
ENV['ENV'] ||= 'development'

require 'config'
require 'camera'
require 'stitcher'

include Solarity

CONFIG = Solarity::Config.new


FileUtils.mkdir('photos')

(1..30).each do |i|
  Camera.take_photo("photos/photo#{ i }.jpg")
  sleep 0.5
end

Stitcher.make_video('photos/photo%d.jpg', 'video.avi')

# 地点を示すクラス
class Waypoint
  attr_accessor :lat, :lon, :name, :wait, :chargespot_id

  def initialize(lat, lon, name, wait)
    @lat = lat
    @lon = lon
    @name = name
    @wait = wait
  end
end

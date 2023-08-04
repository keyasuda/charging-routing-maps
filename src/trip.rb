require 'fast_polylines'
require 'gis/distance'
require_relative './waypoint'

# 旅程を格納するクラス
class Trip
  attr_accessor :waypoints
  attr_reader :route

  def initialize
    @waypoints = []
  end

  # 経路をデコードし格納する
  def route=(polylines)
    @route = polylines.flat_map { |polyline| FastPolylines.decode(polyline, 6) }
  end

  # 経路取得用のクエリを返す
  # query should be like following:
  # {"locations":[{"lat":35.6812362,"lon":139.7671248},{"lat":35.6820933,"lon":139.7752856}],"costing":"auto","directions_options":{"units":"km"}}
  def route_query
    {
      'locations' => @waypoints.map { |wp| { 'lat' => wp.lat, 'lon' => wp.lon } },
      'costing' => 'auto',
      'directions_options' => {
        'units' => 'km',
      },
    }.to_json
  end

  # 指定した位置から指定した距離離れた経路上の点を返す
  # point = [lat, lon]
  def point_on_route(point, distance)
    # find the index of the point from @route
    start_index = @route.index { |po| po == point }
    (start_index..(@route.size - 2)).each do |i|
      s = @route[i]
      e = @route[i + 1]
      d = GIS::Distance.new(*(s + e).flatten)
      distance -= d.distance
      return e if distance <= 0
    end

    nil
  end
end

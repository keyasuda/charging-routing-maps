require_relative '../src/trip'

describe Trip do
  let(:polylines) {
    open('./spec/polylines.txt').read.split("\n")
  }
  let(:waypoints) {
    [
      [34.63547883223782, 135.2248929594471],
      [34.68949372227777, 134.87127789026457],
      [35.00431310040219, 134.99683698676907],
    ].map.with_index { |src, i| Waypoint.new(src.first, src.last, "w#{i}", 0) }
  }

  describe '#route=' do
    it 'joins applied all polylines and set it' do
      expected = polylines.flat_map { |p| FastPolylines.decode(p, 6) }

      trip = Trip.new
      trip.route = polylines
      expect(trip.route).to eq expected
    end
  end

  describe '#route_query' do
    it 'returns route query' do
      trip = Trip.new
      trip.waypoints = waypoints

      expected = { 'locations' => waypoints.map { |w|
                                    { 'lat' => w.lat, 'lon' => w.lon }
                                  }, 'costing' => 'auto', 'directions_options' => { 'units' => 'km' } }

      expect(trip.route_query).to eq expected.to_json
    end
  end

  describe '#point_on_route' do
    let(:trip) {
      Trip.new.tap do |t|
        t.route = polylines
        t.waypoints = waypoints
      end
    }

    it 'returns the point on route' do
      actual = trip.point_on_route(trip.route.first, 20)
      expect(actual).to eq [34.578273, 135.15935]
    end

    it 'returns nil if the route is shorter than the distance' do
      actual = trip.point_on_route(trip.route.first, 1000)
      expect(actual).to be_nil
    end
  end
end

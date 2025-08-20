# frozen_string_literal: true

module SeedData
  module_function

  def make_core_data!
    # Cities
    @nyc = City.find_or_create_by!(name: 'NYC')

    # Neighborhoods
    @nabe1 = Neighborhood.find_or_create_by!(name: 'Williamsburg', city: @nyc)
    @nabe2 = Neighborhood.find_or_create_by!(name: 'Bushwick',     city: @nyc)
    @nabe3 = Neighborhood.find_or_create_by!(name: 'Brighton Beach', city: @nyc)

    # Users (names matter where specs assert them)
    @katie   = User.find_or_create_by!(name: 'Katie')
    @amanda  = User.find_or_create_by!(name: 'Amanda')
    @tristan = User.find_or_create_by!(name: 'Tristan')
    @avi     = User.find_or_create_by!(name: 'Avi')
    @logan   = User.find_or_create_by!(name: 'Logan')

    # Listings (attributes used in specs)
    @listing1 = Listing.find_or_create_by!(
      address: '123 Main Street',
      listing_type: 'private room',
      title: 'Shared room in apartment',
      description: "share a room with me because I'm poor",
      price: 250.00, # total_price expectation = 250.00 for 5 nights below
      neighborhood: @nabe1,
      host: @amanda
    )

    @listing2 = Listing.find_or_create_by!(
      address: '456 Broadway',
      listing_type: 'shared room',
      title: 'Foo',
      description: 'Foo',
      price: 15.00,
      neighborhood: @nabe1,
      host: @amanda
    )

    @listing3 = Listing.find_or_create_by!(
      address: '789 Ocean Pkwy',
      listing_type: 'private room',
      title: 'Foo',
      description: 'Foo',
      price: 150.00,
      neighborhood: @nabe3,
      host: @amanda
    )

    # Reservations used by specs
    # Matches: checkin 2014-04-25, checkout 2014-04-30, guest: @logan, listing: @listing1, status accepted
    @reservation1 = Reservation.find_or_create_by!(
      listing: @listing1,
      guest: @logan,
      checkin: Date.parse('2014-04-25'),
      checkout: Date.parse('2014-04-30'),
      status: 'accepted'
    )

    # Additional reservation on listing1 during May 1–5 to make listing1 unavailable for that window
    @reservation_block_may = Reservation.find_or_create_by!(
      listing: @listing1,
      guest: @avi,
      checkin: Date.parse('2014-05-01'),
      checkout: Date.parse('2014-05-02'),
      status: 'accepted'
    )

    # Reservation used to assert trips for @tristan
    @reservation2 = Reservation.find_or_create_by!(
      listing: @listing2,
      guest: @tristan,
      checkin: 10.days.ago.to_date,
      checkout: 8.days.ago.to_date,
      status: 'accepted'
    )

    # Reviews used by specs
    @review1 = Review.find_or_create_by!(
      reservation: @reservation1,
      guest: @logan,
      rating: 5,
      description: 'This place was great!'
    )

    # Another review so host_reviews/has many reviews assertions have data
    @review3 = Review.find_or_create_by!(
      reservation: @reservation2,
      guest: @avi,
      rating: 4,
      description: 'also good'
    )
  end

  # Called by specs expecting to “flip” the winner city/neighborhood
  def make_denver
    denver = City.find_or_create_by!(name: 'Denver')
    lakewood = Neighborhood.find_or_create_by!(name: 'Lakewood', city: denver)

    host = User.find_or_create_by!(name: 'Denver Host')
    guest = User.find_or_create_by!(name: 'Denver Guest')

    l1 = Listing.find_or_create_by!(
      address: '1 Colfax Ave',
      listing_type: 'private room',
      title: 'Mile High Stay',
      description: 'Cozy',
      price: 100.00,
      neighborhood: lakewood,
      host: host
    )
    l2 = Listing.find_or_create_by!(
      address: '2 Colfax Ave',
      listing_type: 'private room',
      title: 'Mile High Stay 2',
      description: 'Cozy',
      price: 120.00,
      neighborhood: lakewood,
      host: host
    )

    # Stack more reservations in Denver to push ratios/most_res over NYC
    [
      { listing: l1, checkin: Date.parse('2014-05-01'), checkout: Date.parse('2014-05-03') },
      { listing: l1, checkin: 20.days.ago.to_date, checkout: 18.days.ago.to_date },
      { listing: l2, checkin: 15.days.ago.to_date, checkout: 14.days.ago.to_date }
    ].each do |attrs|
      Reservation.find_or_create_by!(attrs.merge(guest: guest, status: 'accepted'))
    end
  end
end

RSpec.configure do |config|
  # Build once, reference everywhere
  config.before(:suite) do
    SeedData.make_core_data!
  end

  config.include SeedData

  # Ensure instance variables exist in every example (some specs reference @vars directly)
  config.before(:each) do
    # Cities & neighborhoods
    @nyc ||= City.find_by(name: 'NYC')
    @nabe1 ||= Neighborhood.find_by(name: 'Williamsburg', city: @nyc)
    @nabe2 ||= Neighborhood.find_by(name: 'Bushwick', city: @nyc)
    @nabe3 ||= Neighborhood.find_by(name: 'Brighton Beach', city: @nyc)

    # Users
    @katie   ||= User.find_by(name: 'Katie')
    @amanda  ||= User.find_by(name: 'Amanda')
    @tristan ||= User.find_by(name: 'Tristan')
    @avi     ||= User.find_by(name: 'Avi')
    @logan   ||= User.find_by(name: 'Logan')

    # Listings
    @listing1 ||= Listing.find_by(address: '123 Main Street')
    @listing2 ||= Listing.find_by(address: '456 Broadway')
    @listing3 ||= Listing.find_by(address: '789 Ocean Pkwy')

    # Reservations
    @reservation1 ||= Reservation.find_by(listing: @listing1, guest: @logan, checkin: Date.parse('2014-04-25'))
    @reservation2 ||= Reservation.find_by(listing: @listing2, guest: @tristan)
  end
end

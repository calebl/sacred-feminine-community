Geocoder.configure(
  lookup: :nominatim,
  language: :en,
  use_https: true,
  http_headers: { "User-Agent" => "SacredFeminine/1.0" },
  units: :km,
  cache: Rails.cache,
  cache_options: { expiration: 1.week }
)

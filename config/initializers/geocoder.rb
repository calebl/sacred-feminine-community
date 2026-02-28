Geocoder.configure(
  lookup: :nominatim,
  language: :en,
  use_https: true,
  http_headers: { "User-Agent" => "SacredFeminine/1.0 (community@sacredfeminine.com)" },
  units: :km,
  cache: Rails.cache,
  cache_options: { expiration: 1.week }
)

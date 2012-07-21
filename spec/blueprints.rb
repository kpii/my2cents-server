require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.gtin do
  (1..13).map { (0..9).to_a.rand.to_s }.join
end

User.blueprint do
  twitter_login { "someone" }
  twitter_id { 12345 }
end

User.blueprint(:facebook) do
  twitter_id { nil }
  facebook_id { 444 }
end

Product.blueprint do
  gtin { Sham.gtin }
end

Comment.blueprint do
  body { Faker::Lorem::sentence }
  user { User.make }
  product { Product.first || Product.make }
  product_key { Sham.gtin }
end

CodecheckResponse.blueprint do
end

OpeneanResponse.blueprint do
end

BestbuyInfo.blueprint do
end

UpcDatabaseInfo.blueprint do
end

AmazonUsResponse.blueprint do
end

AmazonJpResponse.blueprint do
end

AmazonDeResponse.blueprint do
end

AmazonUkResponse.blueprint do
end

AmazonFrResponse.blueprint do
end

AffiliNetResponse.blueprint do
end

Rating.blueprint do
  product { Product.make }
  value { "like" }
end

AffiliNetInfo.blueprint do
end

Scan.blueprint do
  user { User.first || User.make }
  product { Product.make }
  gtin { product ? product.gtin : Sham.gtin }
end

ClientToken.blueprint do
  token { ActiveSupport::SecureRandom.hex }
  user { User.make }
end

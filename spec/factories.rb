# frozen_string_literal: true

FactoryBot.define do
  factory :accounts, class: Spotify::Accounts do
    client_id { Digest::SHA1.hexdigest([Time.now, rand].join) }
    client_secret { Digest::SHA1.hexdigest([Time.now, rand].join) }
    redirect_uri "http://localhost/callback"

    skip_create

    initialize_with do
      new(client_id:     client_id,
          client_secret: client_secret,
          redirect_uri:  redirect_uri)
    end
  end

  factory :session, class: Spotify::Accounts::Session do
    association :accounts, factory: :accounts
    access_token { SecureRandom.base64(100) }
    expires_in 3600
    refresh_token { SecureRandom.base64(100) }
    scopes ["user-read-private"]

    skip_create

    initialize_with do
      new(accounts, access_token, expires_in, refresh_token, scopes)
    end
  end

  factory :sdk, class: Spotify::SDK do
    association :session, factory: :session
    skip_create
    initialize_with { new(session) }
  end

  factory :base, class: Spotify::SDK::Base do
    association :parent, factory: :sdk
    skip_create
    initialize_with { new(parent) }
  end

  factory :album, class: Spotify::SDK::Album do
    association :parent, factory: :base

    skip_create
    initialize_with { new(attributes, parent) }
  end

  factory :item, class: Spotify::SDK::Item do
    association :parent, factory: :base

    skip_create
    initialize_with { new(attributes, parent) }
  end

  factory :image, class: Spotify::SDK::Image do
    association :parent, factory: :base
    url { "https://i.scdn.co/image/%s" % Digest::SHA1.hexdigest([Time.now, rand].join) }
    width 640
    height 640

    skip_create

    initialize_with { new(attributes, parent) }
  end
end

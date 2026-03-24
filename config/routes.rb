# frozen_string_literal: true

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Decidim::Core::Engine => "/"

  # create a route for the subscribe page
  get "/subscribe", to: "static#subscribe", as: :subscribe_static
end

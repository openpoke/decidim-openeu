# frozen_string_literal: true

require "sidekiq/web"
require "sidekiq/cron/web"

Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  namespace :admin do
    resources :iframe, only: [:index]
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  mount Decidim::Core::Engine => "/"
end

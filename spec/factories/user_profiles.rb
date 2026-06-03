# frozen_string_literal: true

FactoryBot.define do
  factory :user_profile do
    name { 'MyString' }
    background { 'MyText' }
    available_days { 1 }
    github_url { 'MyString' }
    linkedin_url { 'MyString' }
  end
end

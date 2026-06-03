# frozen_string_literal: true

FactoryBot.define do
  factory :scout_run do
    user_profile { nil }
    goal { 'MyText' }
    status { 'MyString' }
    wallet_address { 'MyString' }
    somnia_request_id { 'MyString' }
    tx_hash { 'MyString' }
    callback_tx_hash { 'MyString' }
    result_hash { 'MyString' }
  end
end

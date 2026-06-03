# frozen_string_literal: true

FactoryBot.define do
  factory :somnia_request do
    scout_run { nil }
    agent_id { 'MyString' }
    request_id { 'MyString' }
    status { 'MyString' }
    request_tx_hash { 'MyString' }
    callback_tx_hash { 'MyString' }
    payload { '' }
    response { '' }
  end
end

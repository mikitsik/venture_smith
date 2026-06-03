# frozen_string_literal: true

class ScoutRun < ApplicationRecord
  STATUSES = %w[draft requested processing completed failed].freeze

  belongs_to :user_profile

  validates :goal, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :somnia_request_id, uniqueness: true, allow_blank: true

  validates :wallet_address,
            format: { with: /\A0x[a-fA-F0-9]{40}\z/ },
            allow_blank: true

  validates :tx_hash,
            format: { with: /\A0x[a-fA-F0-9]{64}\z/ },
            allow_blank: true

  validates :callback_tx_hash,
            format: { with: /\A0x[a-fA-F0-9]{64}\z/ },
            allow_blank: true
end

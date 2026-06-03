# frozen_string_literal: true

class SomniaRequest < ApplicationRecord
  STATUSES = %w[draft requested processing completed failed].freeze
  TX_HASH_FORMAT = /\A0x[a-fA-F0-9]{64}\z/

  belongs_to :scout_run

  validates :agent_id, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :request_id, uniqueness: true, allow_blank: true

  validates :request_tx_hash,
            format: { with: TX_HASH_FORMAT },
            allow_blank: true

  validates :callback_tx_hash,
            format: { with: TX_HASH_FORMAT },
            allow_blank: true
end

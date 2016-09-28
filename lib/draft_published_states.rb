module DraftPublishedStates
  extend ActiveSupport::Concern

  included do
    scope :by_kind,   -> (kind) { where(:kind => kind) }
    scope :by_state,  -> (state) { where(:state => state) }
    scope :draft,     -> { with_state(:draft) }
    scope :moderating,-> { with_state(:moderating) }
    scope :published, -> { with_state(:published) }
    scope :archive,   -> { with_state(:archive) }

    state_machine :initial => :draft do
      after_transition any => :published do |object, transition|
        object.send(:set_slug)
      end

      after_transition :from => :published do |object, transition|
        object.feed.destroy if object.is_a?(Afisha) && object.feed
      end

      after_transition :archive => :published do |object, transition|
        object.send(:update_attribute, :starts_at, Time.zone.now)
        object.send(:update_attribute, :ends_at, Time.zone.now + 1.month)
        object.send(:copies).map(&:for_sale!)
        object.send(:index!)
      end

      after_transition any => :archive do |object, transition|
        object.send(:update_attribute, :archived_at, Time.zone.now)
      end

      event :to_published do
        transition [:payment, :moderating, :draft, :archive] => :published
      end

      event :to_archive do
        transition :published => :archive
      end

      event :to_moderating do
        transition :draft => :moderating
      end

      event :to_payment do
        transition [:published, :moderating] => :payment
      end

      event :to_draft do
        transition [:published, :moderating] => :draft
      end

      state :published do
        validates_presence_of :showings, :if => Proc.new { |record| record.is_a?(Afisha) && !record.movie? && !record.affiche_schedule.present? }
      end
    end
  end
end

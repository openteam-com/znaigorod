class FullSchedule < ActiveRecord::Base
  attr_accessible :monday, :tuesday, :breaks_attributes, :wednesday, :thursday, :friday, :saturday, :sunday, :from, :to, :free
  has_many :breaks
  belongs_to :schedulable, polymorphic: true, foreign_type: :schedulable_type, foreign_key: :schedulable_id
  accepts_nested_attributes_for :breaks, :reject_if => :all_blank, :allow_destroy => true

  def get_mode
    "#{!free ? from.strftime("%H:%M")+ ' - ' + to.strftime("%H:%M") : 'Выходные'}  #{mode_days}"
  end

  def days_array
    %w(monday tuesday wednesday thursday friday saturday sunday)
  end

  def mode_days
    array = []
    days_array.each_with_index do |d, index|
      if self.attributes[d] == true
        array << short_days[index]
      end
    end
    array.join(', ')
  end

  def short_days
    %w(Пн Вт Ср Чт Пт Сб Вс)
  end
end

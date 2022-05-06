# frozen_string_literal: true

# https://stackoverflow.com/a/37530131/992630
module ChangesTrackeable
  extend ActiveSupport::Concern

  included do
    # expose the details if consumer wants to do more
    attr_reader :saved_changes_history, :saved_changes_unfiltered

    after_initialize :reset_saved_changes
    after_save :track_saved_changes
  end

  # on initialize, but useful for fine grain control
  def reset_saved_changes
    @saved_changes_unfiltered = {}
    @saved_changes_history = []
  end

  # filter out any changes that result in the original value
  def saved_changes
    @saved_changes_unfiltered.reject { |_, value| value[0] == value[1] }
  end

  private

  # on save
  def track_saved_changes
    # maintain an array of ActiveModel::Dirty.changes
    @saved_changes_history << changes.dup
    # accumulate the most recent changes
    @saved_changes_history.last.each_pair { |key, value| track_saved_change key, value }
  end

  # value is an an array of [prev, current]
  def track_saved_change(key, value)
    if @saved_changes_unfiltered.key? key
      @saved_changes_unfiltered[key][1] = track_saved_value value[1]
    else
      @saved_changes_unfiltered[key] = value.dup
    end
  end

  # type safe dup inspred by http://stackoverflow.com/a/20955038
  def track_saved_value(value)
    value.dup
  rescue TypeError
    value
  end
end

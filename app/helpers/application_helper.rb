module ApplicationHelper
  def round_to_quarter(value)
    (value / 0.25).round * 0.25
  end
end

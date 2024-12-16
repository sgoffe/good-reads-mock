module ApplicationHelper
  def round_to_quarter(value)
    (value / 0.25).round * 0.25
  end

  def render_star_rating(book)
    if book.rating.nil?
      content_tag(:p, "No ratings yet", class: "ms-1 text-sm font-medium text-gray-500 dark:text-gray-400")
    else
      rounded_rating = round_to_quarter(book.rating)
      content_tag(:div, class: "flex items-center") do
        (1..5).each do |i|
          if rounded_rating >= i
            concat content_tag(:i, '', class: "fas fa-star text-yellow-300 me-1")
          elsif rounded_rating > (i - 1) && rounded_rating < i
            concat content_tag(:i, '', class: "fas fa-star-half-alt text-yellow-300 me-1")
          else
            concat content_tag(:i, '', class: "fas fa-star text-gray-300 me-1")
          end
        end
        concat content_tag(:p, "#{book.rating.round(2)} stars", class: "ms-1 text-sm font-medium text-gray-500 dark:text-gray-400")
      end
    end
  end
end

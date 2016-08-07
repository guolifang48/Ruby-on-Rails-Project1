module OrdersHelper

  def format_date(date, options = {})
    return '' if date.blank?
    ## If event was less than a week ago  then time ago
    ## If event was last year, include year
    if options[:time]
      date.strftime('%b %d %Y %l:%M%P')
    else
      date.strftime("%b #{date.day.ordinalize}#{' %Y' if options[:year]}")
    end
  end

  def min_date
    Time.zone.now + 3.days
  end

  def checkbox_icon_boolean value
    if value.blank?
      html = "<span class='text-bold text-danger fa fa-times'></span>"
    else
      html = "<span class='text-bold text-success fa fa-check'></span>"
    end
    html.html_safe
  end

end

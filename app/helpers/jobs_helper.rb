module JobsHelper 
  def status_badge(status) 
    normalized = status.to_s.downcase.strip 
    case normalized 
    when "applied" 
      content_tag(:span, "📩 Applied", class: "badge status-badge applied") 
    when "interview" 
      content_tag(:span, "📞 Interview", class: "badge status-badge interview") 
    when "offer" 
      content_tag(:span, "✅ Offer", class: "badge status-badge offer") 
    when "rejected" 
      content_tag(:span, "❎ Rejected", class: "badge status-badge rejected") 
    else 
      content_tag(:span, "Unknown", class: "badge bg-secondary") 
    end 
  end 
end
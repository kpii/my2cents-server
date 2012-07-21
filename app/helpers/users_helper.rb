module UsersHelper
  
  def user_profile_sentence(user)
    things = []
    
    unless user.comments.empty?
      things << [
        "left",
        pluralize(user.comments.count, 'comment'),
        "on",
        pluralize(user.commented_products.count, 'product'),
      ].join(" ")
    end
    
    unless user.scans.empty?
      things << [
        "scanned",
        pluralize(user.scans.count, 'barcode')      
      ].join(" ")
    end

    unless user.ratings.likes.empty?
      things << [
        "liked",
        pluralize(user.ratings.likes.count, 'product')
      ].join(" ")
    end
    
    unless user.ratings.dislikes.empty?
      things << [
        "disliked",
        pluralize(user.ratings.dislikes.count, 'product')
      ].join(" ")
    end

    result = [
      user.name,
      "discovered my2cents.mobi",
      time_ago_in_words(user.created_at),
      "ago"
    ].join(" ")
    
    if things.empty?
      [result, "but didn't do much since then."].join(" ")
    else
      [result, "and", things.to_sentence(:last_word_connector => ' and '), "since then."].join(" ")
    end
  end
end

class AfishaKind
  def tomsk
    [:child, :movie, :concert, :party, :spectacle, :exhibition, :training, :masterclass, :sportsevent, :competition, :other, :excursions]
  end

  def sevastopol
    [:child, :movie, :concert, :party, :spectacle, :exhibition, :training, :masterclass, :sportsevent, :competition, :other, :excursions]
  end

  def tomsk_url
    [ ["child", "deti"], ["movie", "kinoafisha"], ["concert", "concerts"], ["party", "vecherinki"], ["spectacle", "afisha-teatrov"],
      ["exhibition", "vystavki"], ["training", "treningi-i-kursy"], ["masterclass", "masterclasses"], ["sportsevent", "sportsevents"],
      ["competition", "konkursy"], ["other", "others"], ["excursions", "ekskursii_tomska"] ]
  end

  def sevastopol_url
    [ ["child", "deti"], ["movie", "kinoafisha"], ["concert", "concerts"], ["party", "vecherinki"], ["spectacle", "afisha-teatrov"],
      ["exhibition", "vystavki"], ["training", "treningi-i-kursy"], ["masterclass", "masterclasses"], ["sportsevent", "sportsevents"],
      ["competition", "konkursy"], ["other", "others"], ["excursions", "ekskursii_sevastopolja"] ]
  end
end

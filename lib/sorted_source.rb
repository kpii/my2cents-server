module SortedSource

  def <=>(other)
    importance <=> other.importance
  end

  def importance
    [ CodecheckResponse, AffiliNetResponse, AmazonUsResponse, AmazonDeResponse, AmazonUkResponse, 
      AmazonFrResponse, AmazonJpResponse, AffiliNetInfo, OpeneanResponse,
      BestbuyInfo, UpcDatabaseInfo ].
      each_with_index do |klass, index|
      return index if klass === self
    end
  end
end

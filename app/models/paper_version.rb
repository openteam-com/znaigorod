class PaperVersion < PaperTrail::Version
  scope :for_reviews, -> { where(:item_type => 'Review') }
  self.table_name = :paper_versions
  self.sequence_name = :post_versions_id_seq
end

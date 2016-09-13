class PaperVersion < PaperTrail::Version
  self.table_name = :paper_versions
  self.sequence_name = :post_versions_id_seq
end

desc 'Delete old version for review'
task :review_delete_old_versions => :environment do
  pb = ProgressBar.new(PaperVersion.where('item_type' => 'Review').count)

  PaperVersion.where('item_type' => 'Review').each do |version|
    version.delete if DateTime.now.to_date - version.created_at.to_date > 3
    pb.increment!
  end
end

desc 'Delete old version for review'
task :review_delete_old_versions => :environment do
  pb = ProgressBar.new(Version.where('versionable_type' => 'Review').count)

  Version.where('versionable_type' => 'Review').each do |version|
    version.delete if DateTime.now.to_date - version.created_at.to_date > 3
    pb.increment!
  end
end

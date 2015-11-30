require 'spec_helper'

describe MapProject do
  pending "add some examples to (or delete) #{__FILE__}"
end

# == Schema Information
#
# Table name: map_projects
#
#  id                        :integer          not null, primary key
#  title                     :string(255)
#  slug                      :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  cluster_icon_url          :string(255)
#  cluster_icon_file_name    :string(255)
#  cluster_icon_content_type :string(255)
#  cluster_icon_file_size    :string(255)
#  amount                    :integer          default(300)
#


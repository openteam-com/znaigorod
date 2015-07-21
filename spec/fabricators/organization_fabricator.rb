Fabricator :organization do
  title 'Some cool organization'
  priority_suborganization_kind 'meal'
  phone_for_sms '+7-(999)-999-9999'
end

# == Schema Information
#
# Table name: organizations
#
#  id                            :integer          not null, primary key
#  title                         :text
#  site                          :text
#  email                         :text
#  description                   :text
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  phone                         :text
#  vfs_path                      :string(255)
#  organization_id               :integer
#  logotype_url                  :text
#  slug                          :string(255)
#  rating                        :float
#  non_cash                      :boolean
#  priority_suborganization_kind :string(255)
#  comment                       :text
#  additional_rating             :integer
#  yandex_metrika_page_views     :integer
#  vkontakte_likes               :integer
#  subdomain                     :string(255)
#  user_id                       :integer
#  status                        :string(255)
#  total_rating                  :float
#  primary_organization_id       :integer
#  ability_to_comment            :boolean          default(TRUE)
#  fb_likes                      :integer
#  odn_likes                     :integer
#  poster_vk_id                  :string(255)
#  situated_at                   :integer
#  page_meta_description         :text
#  page_meta_keywords            :text
#  page_meta_title               :text
#  positive_activity_date        :datetime
#  og_description                :text
#  og_title                      :text
#  site_link_counter             :integer          default(0)
#  photo_block_title             :string(255)      default("Фото")
#  discounts_block_title         :string(255)      default("Скидки")
#  afisha_block_title            :string(255)      default("Афиша")
#  reviews_block_title           :string(255)      default("Обзоры")
#  comments_block_title          :string(255)      default("Отзывы")
#  barter_status                 :string(255)      default("no_information")
#  discounts_navigation_title    :string(255)
#  photos_navigation_title       :string(255)
#  afishas_navigation_title      :string(255)
#  reviews_navigation_title      :string(255)
#  address_navigation_title      :string(255)
#  csv_id                        :integer
#  gis_title                     :string(255)
#  show_custom_balloon_icon      :boolean          default(FALSE)
#


# encoding: utf-8

class SocialLikes

  def initialize
    @vk_client = VkontakteApi::Client.new
  end

  def url(item)
    resource = case item
    when Afisha
      'afisha'
    when Discount
      'discounts'
    when Review
      'reviews'
    else
      item.class.name.underscore.pluralize
    end

    URI.escape("#{Settings[:app][:url]}/#{resource}/#{item.slug}")
  end

  def damn_likes(item)
    [:vkontakte_likes, :fb_likes, :odn_likes].each do |method|
      self.send(method, item)
    end
  end

  def change_votes(item, like_count, item_like_count, type)
    if like_count >= item_like_count
      (like_count - item_like_count).times do
        vote = item.votes.new(like: true, source: type)
        vote.save(validate: false)
      end
    else
      item.votes.source(type).without_user.limit(item_like_count - like_count).destroy_all
    end
  end

  def vkontakte_likes(item)
    if item.slug?
      begin
        likes = @vk_client.likes.get_list(:type => 'sitepage', :owner_id => '3136085', :page_url => url(item), :filter => 'likes', :friends_only => '0', :extended => '0', :offset => '0', :count => '100')
        uids = likes['users'].map!(&:to_s)
        count = 0
        uids.each do |uid|
          if User.find_by_uid(uid)
            item.votes.find_or_create_by_user_id(user_id: User.find_by_uid(uid).id, like: true, source: :vk)
            count += 1
          end
        end
        vote_ids = item.votes.source(:vk).with_user.map(&:user_id)
        vote_uids = User.where(id: vote_ids).pluck(:uid)
        (vote_uids - uids).each do |e|
          if User.find_by_uid(e)
            item.votes.find_by_user_id(User.find_by_uid(e)).try(:destroy)
          end
        end
        item_like_count = item.votes.source(:vk).without_user.count
        change_votes(item, likes['count'] - count, item_like_count, :vk)
      rescue VkontakteApi::Error => e
        return
      end
    end
  end

  def fb_likes(item)
    if item.slug?
      data = Curl.get("http://graph.facebook.com/?ids=#{url(item)}").body_str
      return unless data.is_json?
      data = JSON.parse(data)
      like_count = (data.try(:[], url(item)).try(:[], 'shares')).to_i || 0
      item_like_count = item.votes.source(:fb).count
      change_votes(item, like_count, item_like_count, :fb)
    end
  end

  def odn_likes(item)
    if item.slug?
      begin
        data = Curl.get("http://www.odnoklassniki.ru/dk?st.cmd=shareData&cb=mailru.share.ok.init&ref=#{url(item)}").body_str
        like_count = JSON.parse(data.match('\{.+\}').to_s)['count'].to_i
        item_like_count = item.votes.source(:odn).count
        change_votes(item, like_count, item_like_count, :odn)
      rescue
        return
      end
    end
  end
end

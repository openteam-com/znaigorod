$ ->
  init_common()
  init_preload_images()
  init_datetime_picker()

  if typeof VK != 'undefined'
    init_vk_like() if $('#vk_like').length
    init_vk_recommended() if $('#vk_recommended').length
    init_vk_comments() if $('#vk_comments').length
    init_vk_organization_comments() if $('#vk_organization_comments').length
    init_vk_group_thin() if $('#vk_group_thin').length
    init_vk_group_thick() if $('#vk_group_thick').length
    init_vk_group_news() if $('#vk_group_news').length
    init_vk_group_subscribers() if $('#vk_group_subscribers').length

  init_show_tipsy() if $('.show_tipsy') && $.fn.tipsy

  init_invitations()
  init_invitation_list_popup()
  init_additional_info()
  init_login()
  init_back_to_top()
  init_change_city()
  init_afisha_extend() if $('.afisha_show .photogallery').length
  init_main_page_reviews_toggler() if $('.reviews_main_page .reviews_toggler').length
  init_main_page_reviews_carousel() if $('.reviews_main_page .reviews_carousel').length
  init_afisha_extend() if $('.afisha_show .trailer')
  init_afisha_filter() if $('.filters .by_date .daily').length
  init_social_actions() if $('.afisha_show').length
  init_social_actions() if $('.organization_show').length
  init_bets() if $('.afisha_show .auction').length
  init_bets_payment() if $('.account_show .bet_actions').length
  init_discount_members() if $('.discount_show').length
  init_discount_into_filter() if $('.filters_wrapper .more_wrapper_toggler').length
  init_payment() if $('a.payment_link').length || $('.feeds').length
  init_tabs() if $('.content .tabs').length
  init_poster() if $('.content .left .image a img').length
  init_distribution() if $('.content .distribution').length
  init_galleria() if $('.content .gallery_container').length
  init_cooperation() if $('.cooperation').length
  init_menu_colorbox() if $('.menus .info .details a img').length
  init_filter_handler() if $('.js-filters-wrapper').length
  init_organization_jump_to_afisha() if $('.organization_show').length
  init_section_show_full_description() if $('.js-show-section-description').length
  init_more_categories_menu() if $('.filters .more_link').length
  init_organization_show_phone() if $('.js-show-phone').length
  init_organization_site_link() if $('.js-site-link').length
  init_sauna_advanced_filter() if $('.js-extended-search').length
  init_sauna_halls_scroll() if $('.need_scrolling').length
  init_iconize_info() if $('.organization_show .show_description_link').length
  init_virtual_tour_link() if $('.organization_show .virtual_tour_link').length
  init_review_gallery() if $('.js-gallery, .review_show').length
  handleReviewGallerySort() if $('.js-gallery').length
  initUlToggle() if $('.js-ul-toggler')
  init_photogallery() if $('.photogallery').length && !$('.photogalleries_show').length && !$('.works_new').length && !$('.works_add').length
  init_pagination() if $('nav.pagination').length or $('.feed_pagination').length or !$('#events_filter').length
  initButtonPagination() if $('.js-button-pagination').length || $('.button_pagination').length
  init_visitors_pagination() if $('.content .left .social_actions .pagination').length
  init_discounts_account_tabs() if $('#discounts_filter').length || $('#reviews_filter').length
  init_account_extend() if $('.account_show').length
  init_account_social_actions() if $('.account_show, .accounts_list').length
  init_account_filter_with_avatar() if $('.filters_wrapper .account #with_avatar').length
  init_messages() if $('#messages_filter').length || $('#notifications').length || $('#invites').length
  init_messages_tabs() if $('#messages_filter').length
  init_list_settings() if $('.content_wrapper .presentation_filters').length
  init_sms_claims() if $('a.sms_claim_link').length || $('.feeds').length
  init_sms_claims_by_hash() if window.location.hash.match(/^#new_sms_claim/)
  init_swfkrpano() if $('#krpano').length
  init_trailers() if $('.afisha_show .trailer p').length
  init_add_webcam() if $('.webcams .add_webcam').length
  init_my_afisha() if $('.my_wrapper').length
  init_file_upload() if $('.file_upload').length
  init_ajax_delete() if $('.ajax_delete').length
  init_select_tags() if $('.select_tags').length
  init_afisha_tabs() if $('#events_filter').length
  init_addresses_side_map() if $('.results_with_map').length
  init_votes() if $('.votes_wrapper, .user_actions').length
  init_comments() if $('.comments').length
  init_pagination_dialogs() if $('#dialogs').length
  init_help() if $('.gallery_help_wrapper').length
  init_email_form() if $('#email_request_form').length
  init_account_edit() if $('.properties_form #edit_account').length
  init_offer_price() if $('.offer_price').length
  init_sweets_carousel() if $('#sweets_carousel').length
  init_contests() if $('.contest .work').length
  init_contest_agreement() if $('.upload_work_wrapper').length
  init_auth_for_contest() if $('.new_work_wrapper').length
  initMyReviews() if $('.review_form').length
  initMyQuestions() if $('.questions_form').length
  initReviewVideoPreview() if $('.reviews_index').length || $('.contests_show').length
  init_next_image() if $('.js-next-image').length
  init_toggle() if $('.photogalleries_show').length
  upload_works() if $('.works_add').length
  i_agree_with_u() if $('.works_add').length
  initMyReviewSubmitWithJs() if $('.review_photo_form').length
  initMyReviewVideoHelp() if $('.js-video-help').length
  initEditAttachmentDescription() if $('.js-gallery .js-edit-attachment-description').length
  apply_unauthorized_action()
  process_change_message_status() if $('#notifications').length

  handleWorkAddition() if $('.new_work', '.upload_work_wrapper').length
  handleBanners() if $('.banners_wrapper').length

  disableAvatarWrapperLinkClick() if $('.avatar-wrapper').length
  init_similar_afishas() if $('#afisha_title').length
  loadRelatedAfishas() if $('.relations').length
  initMyDiscount() if $('.js-toggle-forms').length

  init_banner_stat() if $('.js-banner a').length
  init_right_block_stat()

  init_banners_shuffle() if $('.banner12').length
  init_collapse() if $('.js-slider').length

  init_focus_for_search_button() if $('.js-search-field').length

  init_delimiter_on_sections() if $('.js-opener-btn').length

  true

$(window).load ->
  init_affix() if $('.js-sidebar').length
  init_fixed_menu() if $('.js-fixed-menu').length
  init_3dtourme_stat() if $('a.3dtourme').length
  init_afisha_map() if $('.show_map_link').length || $('.feeds').length
  init_afisha_yandex_map() if $('.yandex_map .map').length
  init_auth() if ('.auth_links').length
  init_countdown() if $('.countdown').length
  init_crop()
  init_discount_map() if $('.discount').length
  init_menus() if $('.menus')
  init_move_to_top() if $('a.move_to_top').length
  init_potential_banner_stat() if $('.js-stat-potential').length
  init_krasavitsa_banner_stat() if $('.js-stat-krasavitsa-2014').length
  init_services() if $('.services')
  init_tickets_stat() if $('.tickets_list li a.payment_link, .affiche .tickets a.payment_link').length
  init_top_banner_stat() if $('.top_headline').length
  init_webcam_map() if $('.webcams .webcam_map').length
  init_map_project() if $('.map_wrapper .map').length
  init_organization_list_view_map() if $('.suborganizations_map_wrapper .map').length

  true

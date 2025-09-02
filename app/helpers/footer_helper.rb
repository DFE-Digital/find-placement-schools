module FooterHelper
  def footer_meta_items
    [
      { text: t(".accessibility"), href: accessibility_path },
      { text: t(".cookies"), href: cookies_path },
      { text: t(".privacy_policy"), href: privacy_path },
      { text: t(".terms_and_conditions"), href: terms_and_conditions_path }
    ]
  end
end
